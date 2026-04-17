import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:get_it/get_it.dart';

import '../../../core/bloc/bloc_application/application_bloc.dart';
import '../../../domain/entities/fitness/coach_entity.dart';
import '../../../domain/usecases/fitness/fitness.dart';
import '../../widgets/image_user_widget.dart';

@RoutePage()
class ChangeInfoScreen extends StatefulWidget {
  final CoachEntity coach;

  const ChangeInfoScreen({super.key, required this.coach});

  @override
  State<ChangeInfoScreen> createState() => _ChangeInfoScreenState();
}

class _ChangeInfoScreenState extends State<ChangeInfoScreen> {
  late CoachEntity _coach = widget.coach;

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

  @override
  Widget build(BuildContext context) {
    final initials = [
      if ((widget.coach.firstName ?? '').isNotEmpty) widget.coach.firstName![0],
      if ((widget.coach.lastName ?? '').isNotEmpty) widget.coach.lastName![0],
    ].join();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1E1E1E)),
            onPressed: () => AutoRouter.of(context).pop(),
          ),
          title: const Text(
            'Edit Profile',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E1E1E),
            ),
          ),
          centerTitle: true,
        ),
      ),
      backgroundColor: Colors.white,
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
                  widget.coach.imageUrl != null
                      ? FAvatar(
                          image: NetworkImage(widget.coach.imageUrl!),
                          fallback: Text(initials),
                          size: 120,
                        )
                      : FAvatar.raw(
                          size: 120,
                          child: Text(
                            initials.isEmpty ? '?' : initials,
                            style: context.theme.typography.xl2
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                  const Positioned(
                    right: -4,
                    bottom: -4,
                    child: ImageUserWidget(),
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
                  backgroundColor: const Color(0xFF1E1E1E),
                  foregroundColor: Colors.white,
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
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6E6E6E),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 15, color: Color(0xFF1E1E1E)),
          decoration: InputDecoration(
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
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
                  const BorderSide(color: Color(0xFF1E1E1E), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
