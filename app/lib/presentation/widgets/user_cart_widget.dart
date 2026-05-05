import 'package:fitness_training/core/resources/localization/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../../domain/entities/fitness/fitness.dart';

class UserCardWidget extends StatelessWidget {
  const UserCardWidget({super.key, required this.model, this.onNotesEdited});

  final TraineeEntity model;
  final ValueChanged<String>? onNotesEdited;

  @override
  Widget build(BuildContext context) {
    final age = model.birthDate != null
        ? '${((DateTime.now().difference(model.birthDate!).inDays) / 365).floor()}'
        : '—';
    final weight = model.weight != null
        ? model.weight!.toStringAsFixed(1)
        : '—';
    final height = model.height != null
        ? model.height!.toStringAsFixed(0)
        : '—';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              _StatCard(label: 'Weight', value: weight, unit: 'kg'),
              const SizedBox(width: 10),
              _StatCard(label: 'Height', value: height, unit: 'cm'),
              const SizedBox(width: 10),
              _StatCard(label: 'Age', value: age, unit: 'yrs'),
            ],
          ),
          if (model.mobilePhone?.isNotEmpty == true) ...[
            const SizedBox(height: 10),
            _InfoRow(icon: FIcons.phone, text: model.mobilePhone!),
          ],
          if (model.notes?.trim().isNotEmpty == true) ...[
            const SizedBox(height: 8),
            _InfoRow(
              icon: FIcons.notebookPen,
              text: model.notes!.trim(),
              onTap: onNotesEdited == null
                  ? null
                  : () => _editNotes(context, model.notes!.trim()),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _editNotes(BuildContext context, String currentNotes) async {
    final controller = TextEditingController(text: currentNotes);
    final result = await showDialog<String>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        contentPadding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
        actionsPadding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        title: const Text(
          'Notes',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E1E1E),
          ),
        ),
        content: SizedBox(
          width: 480,
          child: FTextField.multiline(
            control: FTextFieldControl.managed(controller: controller),
            hint: 'Notes',
            minLines: 4,
            maxLines: 8,
            autofocus: true,
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () =>
                  Navigator.of(dialogCtx).pop(controller.text.trim()),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E1E1E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: Text(
                AppLocalizations.of(context)!.save,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
          ),
          const SizedBox(height: 2),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10)),
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: const TextStyle(
                  color: Color(0xFF9E9E9E),
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
    if (result != null) onNotesEdited!(result);
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final isEmpty = value == '—';
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: context.theme.typography.xl.copyWith(
                fontWeight: FontWeight.w700,
                color: isEmpty
                    ? const Color(0xFFBDBDBD)
                    : const Color(0xFF1E1E1E),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              isEmpty ? label : '$label, $unit',
              style: context.theme.typography.xs.copyWith(
                color: const Color(0xFF9E9E9E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text, this.onTap});

  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF9E9E9E)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: context.theme.typography.sm.copyWith(
                color: const Color(0xFF1E1E1E),
              ),
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: content,
      ),
    );
  }
}
