import 'package:flutter/material.dart';

/// Overflow menu with Edit / Delete actions for a contact.
class ContactActionsMenu extends StatelessWidget {
  const ContactActionsMenu({
    super.key,
    this.onEdit,
    this.onDelete,
  });

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_Action>(
      icon: const Icon(Icons.more_vert, size: 20),
      onSelected: (action) {
        if (action == _Action.edit) onEdit?.call();
        if (action == _Action.delete) onDelete?.call();
      },
      itemBuilder: (_) => [
        if (onEdit != null)
          const PopupMenuItem(
            value: _Action.edit,
            child: Row(
              children: [
                Icon(Icons.edit_outlined, size: 18),
                SizedBox(width: 10),
                Text('Edit'),
              ],
            ),
          ),
        if (onDelete != null)
          const PopupMenuItem(
            value: _Action.delete,
            child: Row(
              children: [
                Icon(Icons.delete_outline, size: 18, color: Color(0xFFD32F2F)),
                SizedBox(width: 10),
                Text('Delete', style: TextStyle(color: Color(0xFFD32F2F))),
              ],
            ),
          ),
      ],
    );
  }
}

enum _Action { edit, delete }
