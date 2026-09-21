import "package:fitness_training/core/resources/localization/l10n/app_localizations.dart";
import "package:flutter/material.dart";
import "package:forui/forui.dart";

/// Editable note for a machine in a program.
///
/// Owns its [TextEditingController] so that parent rebuilds (e.g. the
/// keyboard changing `MediaQuery`) never wipe out what the coach is typing.
/// The field only resyncs from [savedNote] while there are no local edits.
class ProgramNoteCard extends StatefulWidget {
  final String? savedNote;
  final Future<void> Function(String note) onSave;

  const ProgramNoteCard({
    super.key,
    required this.savedNote,
    required this.onSave,
  });

  @override
  State<ProgramNoteCard> createState() => _ProgramNoteCardState();
}

class _ProgramNoteCardState extends State<ProgramNoteCard> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.savedNote ?? '',
  );
  bool _saving = false;

  bool get _isDirty => _controller.text != (widget.savedNote ?? '');

  @override
  void didUpdateWidget(covariant ProgramNoteCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.savedNote != widget.savedNote && !_saving) {
      _controller.text = widget.savedNote ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    try {
      await widget.onSave(_controller.text.trim());
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save the note')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _cancel() {
    FocusScope.of(context).unfocus();
    setState(() => _controller.text = widget.savedNote ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;

    return FCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.note,
            style: context.theme.typography.lg.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            minLines: 5,
            maxLines: 8,
            enabled: !_saving,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: l10n.noteHint,
              hintStyle: TextStyle(color: colors.mutedForeground),
              filled: true,
              fillColor: colors.muted,
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colors.primary),
              ),
            ),
          ),
          if (_isDirty || _saving) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FButton(
                    onPress: _saving ? null : _cancel,
                    variant: FButtonVariant.outline,
                    child: Text(l10n.cancel),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FButton(
                    onPress: _saving ? null : _save,
                    child: Text(l10n.save),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
