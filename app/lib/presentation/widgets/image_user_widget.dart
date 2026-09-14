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
  });

  final ValueChanged<ImageSource> onSourceSelected;
  final VoidCallback onDelete;

  /// Controls whether the "Delete Photo" option is offered at all.
  final bool hasPhoto;

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
    return CircleAvatar(
      backgroundColor: context.theme.colors.primary,
      child: Center(
        child: IconButton(
          onPressed: () => _showSheet(context),
          icon: Icon(
            Icons.camera_alt,
            color: context.theme.colors.primaryForeground,
          ),
        ),
      ),
    );
  }
}
