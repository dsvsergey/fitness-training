import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../core/bloc/bloc_application/application_bloc.dart';
import '../../domain/entities/fitness/fitness.dart';
import '../../domain/usecases/fitness/fitness.dart';
import '../screens/calendar/bloc/calendar_bloc.dart';
import 'time_slot_picker.dart';

/// Bottom sheet that lets a coach schedule a new workout appointment.
///
/// Opened from:
/// * the calendar screen (FAB) — `prefilledTrainee` is null, user picks a trainee
/// * the contact detail screen — `prefilledTrainee` is set, picker is hidden
///
/// Caller is expected to provide [existingAppointments] so the sheet can warn
/// about overlaps before hitting the network. The server is the source of
/// truth and will return HTTP 409 if a conflict slips through.
Future<bool?> showCreateAppointmentSheet(
  BuildContext context, {
  TraineeEntity? prefilledTrainee,
  DateTime? prefilledDate,
  required List<WorkoutAppointmentEntity> existingAppointments,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetCtx) => BlocProvider.value(
      // Keep CalendarBloc available so the sheet can dispatch a refresh
      // when the new appointment is saved.
      value: BlocProvider.of<CalendarBloc>(context),
      child: _CreateAppointmentSheet(
        prefilledTrainee: prefilledTrainee,
        prefilledDate: prefilledDate,
        existingAppointments: existingAppointments,
      ),
    ),
  );
}

class _CreateAppointmentSheet extends StatefulWidget {
  const _CreateAppointmentSheet({
    this.prefilledTrainee,
    this.prefilledDate,
    required this.existingAppointments,
  });

  final TraineeEntity? prefilledTrainee;
  final DateTime? prefilledDate;
  final List<WorkoutAppointmentEntity> existingAppointments;

  @override
  State<_CreateAppointmentSheet> createState() =>
      _CreateAppointmentSheetState();
}

class _CreateAppointmentSheetState extends State<_CreateAppointmentSheet> {
  static const _durationOptions = <int>[15, 30, 45, 60, 90];

  TraineeEntity? _trainee;
  ProgramFitnessEntity? _program;
  late DateTime _date;
  TimeOfDay _time = const TimeOfDay(hour: 10, minute: 0);
  int _durationMinutes = 30;
  final _notesCtrl = TextEditingController();
  final _customDurationCtrl = TextEditingController();

  bool _submitting = false;
  String? _error;

  // List of trainees sourced for the picker, populated lazily on first tap.
  List<TraineeEntity>? _availableTrainees;
  bool _loadingTrainees = false;

  // Programs for the currently selected trainee. Reloaded whenever the trainee
  // changes; cleared if no trainee is selected.
  List<ProgramFitnessEntity> _programs = const [];
  bool _loadingPrograms = false;

  // Appointments already booked for the *selected date* by the current coach.
  // Drives both the local overlap check and the time-slot picker.
  late List<WorkoutAppointmentEntity> _busy;
  bool _loadingBusy = false;

  @override
  void initState() {
    super.initState();
    _trainee = widget.prefilledTrainee;
    final now = DateTime.now();
    _date = widget.prefilledDate ?? DateTime(now.year, now.month, now.day);
    // Seed from whatever the caller already loaded so the first paint isn't
    // empty; refreshed below for the chosen date.
    _busy = _filterBusyForDate(widget.existingAppointments, _date);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBusyForDate();
      if (_trainee?.id != null) _loadProgramsFor(_trainee!);
    });
  }

  static List<WorkoutAppointmentEntity> _filterBusyForDate(
    List<WorkoutAppointmentEntity> all,
    DateTime date,
  ) {
    return all.where((a) {
      if (a.status == AppointmentStatusEnumEntity.cancelled ||
          a.status == AppointmentStatusEnumEntity.lateCancelled ||
          a.status == AppointmentStatusEnumEntity.noShow ||
          a.status == AppointmentStatusEnumEntity.noneStatus) {
        return false;
      }
      return a.startAt.year == date.year &&
          a.startAt.month == date.month &&
          a.startAt.day == date.day;
    }).toList();
  }

  Future<void> _loadBusyForDate() async {
    final coachId =
        context.read<ApplicationBloc>().state.user?.coach?.id;
    if (coachId == null) return;
    setState(() => _loadingBusy = true);
    try {
      final result = await GetIt.I<WorkoutAppointmentUsecase>()
          .getAllWorkoutAppointments(
        filter: WorkoutAppointmentFilterEntity((p) => p
          ..startDate = _date.toString()
          ..coachIds = ListBuilder<int>([coachId])),
      );
      if (!mounted) return;
      setState(() {
        _busy = _filterBusyForDate(
            result.appointments?.toList() ?? const [], _date);
        _loadingBusy = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingBusy = false);
    }
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    _customDurationCtrl.dispose();
    super.dispose();
  }

  DateTime get _startAt => DateTime(
        _date.year,
        _date.month,
        _date.day,
        _time.hour,
        _time.minute,
      );

  DateTime get _endAt => _startAt.add(Duration(minutes: _durationMinutes));

  /// Local check against currently loaded appointments. The server enforces
  /// the same rule authoritatively, but a client-side check gives instant
  /// feedback and lets us highlight which existing appointment conflicts.
  WorkoutAppointmentEntity? _findLocalOverlap() {
    final start = _startAt;
    final end = _endAt;
    for (final a in _busy) {
      if (a.startAt.isBefore(end) && a.endAt.isAfter(start)) {
        return a;
      }
    }
    return null;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() => _date = picked);
    await _loadBusyForDate();
  }

  Future<void> _pickTime() async {
    final ranges = _busy
        .map((a) => BusyRange(
              start: a.startAt,
              end: a.endAt,
              label: a.trainee.fullName.trim().isEmpty
                  ? null
                  : a.trainee.fullName,
            ))
        .toList();
    final picked = await showTimeSlotPicker(
      context,
      date: _date,
      durationMinutes: _durationMinutes,
      busy: ranges,
      initial: _time,
    );
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _pickTrainee() async {
    if (_availableTrainees == null) {
      setState(() => _loadingTrainees = true);
      try {
        final result =
            await GetIt.I<TraineeUsecase>().getTrainees(skip: 0, limit: 200);
        _availableTrainees = result.trainees?.toList() ?? [];
      } catch (_) {
        _availableTrainees = [];
      } finally {
        if (mounted) setState(() => _loadingTrainees = false);
      }
    }
    if (!mounted) return;
    final picked = await showModalBottomSheet<TraineeEntity>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final list = _availableTrainees ?? [];
        if (list.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Text('No contacts available.'),
          );
        }
        return SafeArea(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final t = list[i];
              return FTile(
                title: Text(t.fullName.isEmpty ? 'No Name' : t.fullName),
                subtitle: Text(t.email ?? ''),
                onPress: () => Navigator.of(ctx).pop(t),
              );
            },
          ),
        );
      },
    );
    if (picked != null) {
      setState(() {
        _trainee = picked;
        _program = null;
        _programs = const [];
      });
      await _loadProgramsFor(picked);
    }
  }

  Future<void> _loadProgramsFor(TraineeEntity trainee) async {
    if (trainee.id == null) return;
    setState(() => _loadingPrograms = true);
    try {
      final all =
          await GetIt.I<ProgramFitnessUsecase>().getPrograms(trainee.id!);
      // Skip archived/deleted programs — coach shouldn't schedule against them.
      final active = all
          .where((p) => p.isArchive != true && p.isDelete != true)
          .toList();
      if (!mounted) return;
      setState(() {
        _programs = active;
        // Auto-select if exactly one program — saves a tap in the common case.
        if (active.length == 1) _program = active.first;
        _loadingPrograms = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _programs = const [];
        _loadingPrograms = false;
      });
    }
  }

  Future<void> _pickProgram() async {
    if (_programs.isEmpty) return;
    final picked = await showModalBottomSheet<ProgramFitnessEntity>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: _programs.length,
          itemBuilder: (_, i) {
            final p = _programs[i];
            return FTile(
              prefix: const Icon(FIcons.dumbbell),
              title: Text(p.name ?? 'Program #${p.number ?? p.id}'),
              subtitle: p.number != null ? Text('#${p.number}') : null,
              onPress: () => Navigator.of(ctx).pop(p),
            );
          },
        ),
      ),
    );
    if (picked != null) setState(() => _program = picked);
  }

  void _setDuration(int minutes) {
    setState(() {
      _durationMinutes = minutes;
      _customDurationCtrl.clear();
    });
  }

  void _onCustomDurationChanged(String text) {
    final v = int.tryParse(text.trim());
    if (v != null && v > 0) {
      setState(() => _durationMinutes = v);
    }
  }

  Future<void> _submit() async {
    setState(() => _error = null);

    if (_trainee == null) {
      setState(() => _error = 'Please select a contact.');
      return;
    }
    if (_program == null && _programs.isNotEmpty) {
      setState(() => _error = 'Please pick a program.');
      return;
    }
    if (_durationMinutes <= 0) {
      setState(() => _error = 'Duration must be greater than 0.');
      return;
    }
    final coach = context.read<ApplicationBloc>().state.user?.coach;
    if (coach == null || coach.id == null) {
      setState(() => _error = 'No coach context — please re-login.');
      return;
    }

    final localConflict = _findLocalOverlap();
    if (localConflict != null) {
      final t =
          '${_fmtTime(localConflict.startAt)}–${_fmtTime(localConflict.endAt)}';
      setState(() => _error = 'Overlaps existing training at $t.');
      return;
    }

    final entity = WorkoutAppointmentEntity((b) => b
      ..trainee = _trainee!.toBuilder()
      ..coach = coach.toBuilder()
      ..programId = _program?.id
      ..duration = _durationMinutes
      ..status = AppointmentStatusEnumEntity.booked
      ..startAt = _startAt
      ..endAt = _endAt
      ..notes = _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim());

    setState(() => _submitting = true);
    try {
      await GetIt.I<WorkoutAppointmentUsecase>()
          .createWorkoutAppointment(entity);
      if (!mounted) return;
      BlocProvider.of<CalendarBloc>(context).add(RefreshAppointments());
      Navigator.of(context).pop(true);
    } on DioException catch (e) {
      final msg = _extractConflictMessage(e) ??
          'Could not save appointment. Please try again.';
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = msg;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = 'Could not save appointment. Please try again.';
      });
    }
  }

  String? _extractConflictMessage(DioException e) {
    if (e.response?.statusCode != 409) return null;
    final detail = e.response?.data is Map ? e.response!.data['detail'] : null;
    if (detail is Map) {
      final c = detail['conflict'];
      if (c is Map && c['start_at'] != null && c['end_at'] != null) {
        try {
          final s = DateTime.parse(c['start_at'] as String).toLocal();
          final f = DateTime.parse(c['end_at'] as String).toLocal();
          return 'Overlaps existing training at ${_fmtTime(s)}–${_fmtTime(f)}.';
        } catch (_) {}
      }
      return detail['message'] as String? ?? 'Time slot is taken.';
    }
    return 'Time slot is taken.';
  }

  String _fmtTime(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'New Training',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  icon: const Icon(Icons.close, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTraineeRow(),
            if (_trainee != null) ...[
              const SizedBox(height: 10),
              _buildProgramRow(),
            ],
            const SizedBox(height: 14),
            _buildDateTimeRow(),
            const SizedBox(height: 16),
            const Text(
              'Duration',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6E6E6E),
              ),
            ),
            const SizedBox(height: 8),
            _buildDurationChips(),
            const SizedBox(height: 14),
            const Text(
              'Notes',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6E6E6E),
              ),
            ),
            const SizedBox(height: 6),
            FTextField(
              control: FTextFieldControl.managed(controller: _notesCtrl),
              hint: 'Anything to remember about this session',
              maxLines: 3,
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFFD32F2F)),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FButton(
                onPress: _submitting ? null : _submit,
                child: _submitting
                    ? const FCircularProgress()
                    : const Text('Schedule training'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTraineeRow() {
    final isLocked = widget.prefilledTrainee != null;
    final label = _trainee?.fullName.trim().isNotEmpty == true
        ? _trainee!.fullName
        : 'Select contact';
    return InkWell(
      onTap: isLocked || _loadingTrainees ? null : _pickTrainee,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(FIcons.user, size: 18, color: Color(0xFF6E6E6E)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  color: _trainee == null
                      ? const Color(0xFF9E9E9E)
                      : const Color(0xFF1E1E1E),
                ),
              ),
            ),
            if (_loadingTrainees)
              const SizedBox(
                width: 16,
                height: 16,
                child: FCircularProgress(),
              )
            else if (!isLocked)
              const Icon(Icons.chevron_right, color: Color(0xFF9E9E9E)),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramRow() {
    final String label;
    final bool isPlaceholder;
    if (_loadingPrograms) {
      label = 'Loading programs…';
      isPlaceholder = true;
    } else if (_programs.isEmpty) {
      label = 'No active programs for this contact';
      isPlaceholder = true;
    } else if (_program != null) {
      label =
          _program!.name ?? 'Program #${_program!.number ?? _program!.id}';
      isPlaceholder = false;
    } else {
      label = 'Select program';
      isPlaceholder = true;
    }
    final tappable = !_loadingPrograms && _programs.isNotEmpty;
    return InkWell(
      onTap: tappable ? _pickProgram : null,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(FIcons.dumbbell, size: 18, color: Color(0xFF6E6E6E)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  color: isPlaceholder
                      ? const Color(0xFF9E9E9E)
                      : const Color(0xFF1E1E1E),
                ),
              ),
            ),
            if (_loadingPrograms)
              const SizedBox(
                  width: 16, height: 16, child: FCircularProgress())
            else if (tappable)
              const Icon(Icons.chevron_right, color: Color(0xFF9E9E9E)),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeRow() {
    final dateText = DateFormat.yMMMEd().format(_date);
    final timeText = _time.format(context);
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _PickerTile(
            icon: FIcons.calendar,
            text: dateText,
            onTap: _pickDate,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: _PickerTile(
            icon: FIcons.clock,
            text: timeText,
            onTap: _pickTime,
          ),
        ),
      ],
    );
  }

  Widget _buildDurationChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final m in _durationOptions)
          _DurationChip(
            label: '${m}m',
            selected: _durationMinutes == m && _customDurationCtrl.text.isEmpty,
            onTap: () => _setDuration(m),
          ),
        SizedBox(
          width: 88,
          child: TextField(
            controller: _customDurationCtrl,
            keyboardType: TextInputType.number,
            onChanged: _onCustomDurationChanged,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Custom',
              hintStyle: const TextStyle(color: Color(0xFFBDBDBD)),
              suffixText: 'm',
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Color(0xFF1E1E1E)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  final IconData icon;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF6E6E6E)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 14, color: Color(0xFF1E1E1E)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DurationChip extends StatelessWidget {
  const _DurationChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1E1E1E) : Colors.white,
          border: Border.all(
            color: selected
                ? const Color(0xFF1E1E1E)
                : const Color(0xFFE0E0E0),
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : const Color(0xFF1E1E1E),
          ),
        ),
      ),
    );
  }
}
