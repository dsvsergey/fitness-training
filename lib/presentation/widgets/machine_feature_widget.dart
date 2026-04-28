import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class MachineFeatureWidget extends StatelessWidget {
  final String label;
  final String? value;
  final Widget icon;
  final String? additionalText;

  const MachineFeatureWidget({
    super.key,
    required this.label,
    required this.icon,
    this.value,
    this.additionalText,
  });

  @override
  Widget build(BuildContext context) {
    return additionalText == null
        ? _withoutAdditional(context)
        : _withAdditional(context);
  }

  Widget _withoutAdditional(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          icon,
          Row(
            children: [
              Text(
                label,
                style: context.theme.typography.md.copyWith(
                  color: context.theme.colors.mutedForeground,
                ),
              ),
              const Spacer(),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: Text(
                  value ?? '',
                  key: ValueKey<String>(value ?? ''),
                  style: context.theme.typography.md.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      );

  Widget _withAdditional(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 70,
            child: Stack(
              children: [
                icon,
                Positioned(
                  right: 0,
                  top: 0,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) =>
                        ScaleTransition(scale: animation, child: child),
                    child: Text(
                      additionalText ?? '',
                      style: context.theme.typography.sm.copyWith(
                        fontWeight: FontWeight.w700,
                        color: context.theme.colors.mutedForeground,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Text(
                label,
                style: context.theme.typography.md.copyWith(
                  color: context.theme.colors.mutedForeground,
                ),
              ),
              const Spacer(),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: Text(
                  value ?? '',
                  style: context.theme.typography.md.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
}
