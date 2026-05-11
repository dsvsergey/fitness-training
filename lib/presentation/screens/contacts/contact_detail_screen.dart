import 'package:auto_route/auto_route.dart';
import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../../core/bloc/bloc_application/application_bloc.dart';
import '../../../core/router/router.dart';
import '../../../domain/entities/fitness/fitness.dart';
import '../../../domain/usecases/fitness/fitness.dart';
import '../../utils/dialogs_utils.dart';
import '../../widgets/user_avatar_widget.dart';
import '../programs/program_screen/bloc/program_screen_bloc.dart';

/// Detail screen for a single trainee (contact). Shows profile info and the
/// trainee's recent completed trainings, and lets the coach start a new one.
@RoutePage()
class ContactDetailScreen extends StatefulWidget {
  const ContactDetailScreen({required this.trainee, super.key});

  final TraineeEntity trainee;

  @override
  State<ContactDetailScreen> createState() => _ContactDetailScreenState();
}

class _ContactDetailScreenState extends State<ContactDetailScreen> {
  late TraineeEntity _trainee;
  List<WorkoutAppointmentEntity> _appointments = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _trainee = widget.trainee;
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() => _loading = true);
    try {
      final coach =
          context.read<ApplicationBloc>().state.user?.coach;
      final coachIds = coach?.id != null
          ? ListBuilder<int>([coach!.id!])
          : ListBuilder<int>();
      // Look back a year for recent completed trainings with this client.
      final startDate = DateTime.now().subtract(const Duration(days: 365));
      final result = await GetIt.I<WorkoutAppointmentUsecase>()
          .getAllWorkoutAppointments(
        filter: WorkoutAppointmentFilterEntity((p) => p
          ..startDate = startDate.toString()
          ..coachIds = coachIds),
      );
      final mine = (result.appointments ?? const <WorkoutAppointmentEntity>[])
          .where((a) =>
              a.trainee.id == _trainee.id &&
              a.status == AppointmentStatusEnumEntity.completed)
          .toList()
        ..sort((a, b) => b.startAt.compareTo(a.startAt));
      if (!mounted) return;
      setState(() {
        _appointments = mine.take(10).toList();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _appointments = const [];
        _loading = false;
      });
    }
  }

  void _openPrograms() {
    context
        .read<ApplicationBloc>()
        .add(SelectTraineeEvent(selectedTrainee: _trainee));
    BlocProvider.of<ProgramScreenBloc>(context)
        .add(UpdateTraineeEvent(trainee: _trainee));
    AutoRouter.of(context).push(const ProgramRoute());
  }

  Future<void> _openEdit() async {
    if (_trainee.id == null) return;
    final updated = await DialogUtils.showEditTraineeDialog(
      context: context,
      trainee: _trainee,
    );
    if (updated == null || !mounted) return;
    try {
      final saved =
          await GetIt.I<TraineeUsecase>().updateTrainee(_trainee.id!, updated);
      if (!mounted) return;
      setState(() => _trainee = saved);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update trainee')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = _trainee;
    final fullName = t.fullName.trim();
    final initials = fullName
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0] : '')
        .take(2)
        .join();

    return Scaffold(
      backgroundColor: context.theme.colors.background,
      appBar: AppBar(
        backgroundColor: context.theme.colors.background,
        foregroundColor: context.theme.colors.foreground,
        elevation: 0,
        title: Text(fullName.isEmpty ? 'Contact' : fullName),
        actions: [
          IconButton(
            tooltip: 'Edit',
            onPressed: _openEdit,
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            _ProfileHeader(trainee: t, initials: initials),
            const SizedBox(height: 16),
            _InfoCard(trainee: t),
            const SizedBox(height: 20),
            FButton(
              onPress: _openPrograms,
              child: const Text('Start training'),
            ),
            const SizedBox(height: 24),
            Text(
              'Recent trainings',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: context.theme.colors.foreground,
              ),
            ),
            const SizedBox(height: 8),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: FCircularProgress()),
              )
            else if (_appointments.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'No trainings yet.',
                  style: TextStyle(color: context.theme.colors.mutedForeground),
                ),
              )
            else
              ..._appointments.map((a) => _AppointmentRow(appointment: a)),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.trainee, required this.initials});

  final TraineeEntity trainee;
  final String initials;

  @override
  Widget build(BuildContext context) {
    final avatar = UserAvatarWidget(
      photoUrl: trainee.photoUrl,
      initials: initials.isEmpty ? 'NA' : initials,
      size: 72,
      textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
    );

    return Row(
      children: [
        avatar,
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                trainee.fullName.trim().isEmpty
                    ? 'No Name'
                    : trainee.fullName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: context.theme.colors.foreground,
                ),
              ),
              if (trainee.email != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    trainee.email!,
                    style: TextStyle(
                        fontSize: 13,
                        color: context.theme.colors.mutedForeground),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.trainee});

  final TraineeEntity trainee;

  @override
  Widget build(BuildContext context) {
    final rows = <_InfoRow>[
      if (trainee.mobilePhone != null && trainee.mobilePhone!.isNotEmpty)
        _InfoRow(icon: FIcons.phone, label: 'Phone', value: trainee.mobilePhone!),
      if (trainee.weight != null)
        _InfoRow(
            icon: FIcons.dumbbell,
            label: 'Weight',
            value: '${trainee.weight} kg'),
      if (trainee.height != null)
        _InfoRow(
            icon: FIcons.user, label: 'Height', value: '${trainee.height} cm'),
      if (trainee.notes != null && trainee.notes!.isNotEmpty)
        _InfoRow(
            icon: FIcons.notebookPen, label: 'Notes', value: trainee.notes!),
    ];
    if (rows.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: context.theme.colors.secondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.theme.colors.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i < rows.length - 1)
              Divider(height: 14, color: context.theme.colors.border),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: context.theme.colors.mutedForeground),
        const SizedBox(width: 10),
        SizedBox(
          width: 64,
          child: Text(
            label,
            style: TextStyle(
                fontSize: 12, color: context.theme.colors.mutedForeground),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
                fontSize: 13, color: context.theme.colors.foreground),
          ),
        ),
      ],
    );
  }
}

class _AppointmentRow extends StatelessWidget {
  const _AppointmentRow({required this.appointment});

  final WorkoutAppointmentEntity appointment;

  String _fmtTime(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat.MMMEd().format(appointment.startAt);
    final timeStr =
        '${_fmtTime(appointment.startAt)} – ${_fmtTime(appointment.endAt)}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: FTile(
        prefix: const Icon(FIcons.calendar),
        title: Text(dateStr),
        subtitle: Text(timeStr),
        suffix: Text(
          '${appointment.duration}m',
          style: TextStyle(
              fontSize: 12, color: context.theme.colors.mutedForeground),
        ),
      ),
    );
  }
}
