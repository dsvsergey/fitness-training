import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/resources/resources.dart';
import 'settings_camers_widget.dart';

/// The camera badge overlaid on a profile avatar.
///
/// Presentational only: it reports which action the user chose and leaves the
/// picking and uploading to its parent, so it stays free of I/O.
class ImageUserWidget extends StatelessWidget {
  const ImageUserWidget({
    super.key,
    required this.onSourceSelected,
    required this.onDelete,
    this.hasPhoto = false,
    this.size,
  });

  final ValueChanged<ImageSource> onSourceSelected;
  final VoidCallback onDelete;

  /// Controls whether the "Delete Photo" option is offered at all.
  final bool hasPhoto;

  /// Diameter of the badge. Defaults to whatever CircleAvatar and IconButton
  /// pick on their own, which suits a large profile avatar; pass a smaller
  /// value when the badge sits on a smaller one.
  final double? size;

  void _showSheet(BuildContext context) {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      context: context,
      backgroundColor: context.theme.colors.background,
      builder: (sheetCtx) => Container(
        height: hasPhoto ? 250 : 190,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(50),
            topRight: Radius.circular(50),
          ),
          color: context.theme.colors.background,
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 50,
              height: 7,
              decoration: ShapeDecoration(
                color: context.theme.colors.border,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            const SizedBox(height: 40),
            SettingsCamersWidget(
              image: AppSvgs.photo,
              title: "Select from Gallery",
              onPressed: () {
                Navigator.pop(sheetCtx);
                onSourceSelected(ImageSource.gallery);
              },
            ),
            SettingsCamersWidget(
              image: AppSvgs.camera,
              title: "Open Camera",
              onPressed: () {
                Navigator.pop(sheetCtx);
                onSourceSelected(ImageSource.camera);
              },
            ),
            if (hasPhoto)
              SettingsCamersWidget(
                image: AppSvgs.delete,
                title: "Delete Photo",
                onPressed: () {
                  Navigator.pop(sheetCtx);
                  onDelete();
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = this.size;
    return CircleAvatar(
      radius: size == null ? null : size / 2,
      backgroundColor: context.theme.colors.primary,
      child: Center(
        child: IconButton(
          onPressed: () => _showSheet(context),
          // The defaults leave an IconButton at its 48px minimum, which is
          // wider than a scaled-down badge.
          padding: size == null ? null : EdgeInsets.zero,
          constraints: size == null ? null : const BoxConstraints(),
          iconSize: size == null ? null : size * 0.55,
          icon: Icon(
            Icons.camera_alt,
            color: context.theme.colors.primaryForeground,
          ),
        ),
      ),
    );
  }
}
