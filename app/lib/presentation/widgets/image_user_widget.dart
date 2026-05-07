import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../../core/resources/resources.dart';
import 'settings_camers_widget.dart';

class ImageUserWidget extends StatelessWidget {
  const ImageUserWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      //radius: 19.r,
      backgroundColor: context.theme.colors.primary,
      child: Center(
        child: IconButton(
          onPressed: () {
            showModalBottomSheet(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              context: context,
              backgroundColor: context.theme.colors.background,
              builder: (sheetCtx) => Container(
                height: 250,
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
                      onPressed: () {},
                    ),
                    SettingsCamersWidget(
                      image: AppSvgs.camera,
                      title: "Open Camera",
                      onPressed: () {},
                    ),
                    SettingsCamersWidget(
                      image: AppSvgs.delete,
                      title: "Delete Photo",
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            );
          },
          icon: Icon(
            Icons.camera_alt,
            color: context.theme.colors.primaryForeground,
          ),
        ),
      ),
    );
  }
}
