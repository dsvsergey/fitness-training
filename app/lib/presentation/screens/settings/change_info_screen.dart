import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/bloc/bloc_application/application_bloc.dart';
import '../../../domain/entities/fitness/coach_entity.dart';
import '../../../domain/usecases/fitness/fitness.dart';
import '../../widgets/image_user_widget.dart';
import '../../widgets/user_avatar_widget.dart';

@RoutePage()
class ChangeInfoScreen extends StatefulWidget {
  final CoachEntity coach;

  const ChangeInfoScreen({super.key, required this.coach});

  @override
  State<ChangeInfoScreen> createState() => _ChangeInfoScreenState();
}

class _ChangeInfoScreenState extends State<ChangeInfoScreen> {
  late CoachEntity _coach = widget.coach;

  final _picker = ImagePicker();
  bool _uploadingAvatar = false;

  late final _firstNameCtrl =
      TextEditingController(text: widget.coach.firstName ?? '');
  late final _lastNameCtrl =
      TextEditingController(text: widget.coach.lastName ?? '');
  late final _phoneCtrl =
      TextEditingController(text: widget.coach.mobilePhone ?? '');
  late final _emailCtrl =
      TextEditingController(text: widget.coach.email ?? '');
  late final _notesCtrl =
      TextEditingController(text: widget.coach.note ?? '');

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar(ImageSource source) async {
    if (_uploadingAvatar) return;

    // Not `final`: assigning inside the try block would leave it only
    // conditionally assigned as far as definite-assignment analysis is
    // concerned, and the analyzer rejects that.
    XFile? picked;
    try {
      picked = await _picker.pickImage(source: source, imageQuality: 85);
    } catch (e) {
      _reportAvatarError(e);
      return;
    }
    if (picked == null) return;

    // Bytes rather than a path: XFile.path is a blob URL on web.
    final bytes = await picked.readAsBytes();
    final filename = picked.name;
    await _runAvatarRequest(
      () => GetIt.I<CoachUsecase>().uploadAvatar(bytes, filename),
    );
  }

  Future<void> _deleteAvatar() =>
      _runAvatarRequest(() => GetIt.I<CoachUsecase>().deleteAvatar());

  Future<void> _runAvatarRequest(Future<CoachEntity> Function() request) async {
    setState(() => _uploadingAvatar = true);
    try {
      final updated = await request();
      if (!mounted) return;
      setState(
        () => _coach = _coach.rebuild((b) => b..imageUrl = updated.imageUrl),
      );
      // Keeps the avatar on SettingsScreen in step with this one.
      context.read<ApplicationBloc>().add(UpdateCoachInfoEvent(coach: _coach));
    } catch (e) {
      _reportAvatarError(e);
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  void _reportAvatarError(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not update photo: $error')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initials = [
      if ((_coach.firstName ?? '').isNotEmpty) _coach.firstName![0],
      if ((_coach.lastName ?? '').isNotEmpty) _coach.lastName![0],
    ].join();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          backgroundColor: context.theme.colors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: context.theme.colors.foreground),
            onPressed: () => AutoRouter.of(context).pop(),
          ),
          title: Text(
            'Edit Profile',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: context.theme.colors.foreground,
            ),
          ),
          centerTitle: true,
        ),
      ),
      backgroundColor: context.theme.colors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            // ── Avatar ──────────────────────────────────────────────────
            Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  UserAvatarWidget(
                    photoUrl: _coach.imageUrl,
                    initials: initials.isEmpty ? '?' : initials,
                    size: 120,
                    textStyle: context.theme.typography.xl2
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (_uploadingAvatar)
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: context.theme.colors.background
                              .withValues(alpha: 0.6),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                  Positioned(
                    right: -4,
                    bottom: -4,
                    child: ImageUserWidget(
                      hasPhoto: (_coach.imageUrl ?? '').isNotEmpty,
                      onSourceSelected: _pickAvatar,
                      onDelete: _deleteAvatar,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── Fields ──────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _Field(
                    label: 'First name',
                    controller: _firstNameCtrl,
                    onChanged: (v) => setState(
                      () => _coach =
                          _coach.rebuild((b) => b..firstName = v.trim()),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Field(
                    label: 'Last name',
                    controller: _lastNameCtrl,
                    onChanged: (v) => setState(
                      () => _coach =
                          _coach.rebuild((b) => b..lastName = v.trim()),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Field(
              label: 'Phone number',
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              onChanged: (v) => setState(
                () => _coach =
                    _coach.rebuild((b) => b..mobilePhone = v.trim()),
              ),
            ),
            const SizedBox(height: 16),
            _Field(
              label: 'Email',
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              onChanged: (v) => setState(
                () => _coach = _coach.rebuild((b) => b..email = v.trim()),
              ),
            ),
            const SizedBox(height: 16),
            _Field(
              label: 'Notes',
              controller: _notesCtrl,
              maxLines: 3,
              onChanged: (v) => setState(
                () => _coach = _coach.rebuild((b) => b..note = v),
              ),
            ),

            const SizedBox(height: 32),

            // ── Save button ─────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  GetIt.I<CoachUsecase>()
                      .updateCoach(_coach.id ?? 0, _coach)
                      .then((_) {
                    context
                        .read<ApplicationBloc>()
                        .add(UpdateCoachInfoEvent(coach: _coach));
                    AutoRouter.of(context).pop();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.theme.colors.primary,
                  foregroundColor: context.theme.colors.primaryForeground,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Save changes',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    this.onChanged,
    this.keyboardType,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: context.theme.colors.mutedForeground,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(fontSize: 15, color: context.theme.colors.foreground),
          decoration: InputDecoration(
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            filled: true,
            fillColor: context.theme.colors.secondary,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  BorderSide(color: context.theme.colors.foreground, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
