import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class CustomTextFieldWidget extends StatefulWidget {
  const CustomTextFieldWidget({
    super.key,
    this.controller,
    this.onChanged,
    this.prefix,
    this.suffix,
    this.hintText,
    this.keyboardType,
    this.errorText,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final Widget? prefix;
  final Widget? suffix;
  final String? hintText;
  final TextInputType? keyboardType;
  final String? errorText;

  @override
  State<CustomTextFieldWidget> createState() => _CustomTextFieldWidgetState();
}

class _CustomTextFieldWidgetState extends State<CustomTextFieldWidget> {
  late final TextEditingController _controller;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController();
      _ownsController = true;
    }
    if (widget.onChanged != null) {
      _controller.addListener(_onChanged);
    }
  }

  void _onChanged() => widget.onChanged?.call(_controller.text);

  @override
  void dispose() {
    if (widget.onChanged != null) {
      _controller.removeListener(_onChanged);
    }
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: FTextField(
          control: FTextFieldControl.managed(controller: _controller),
          hint: widget.hintText,
          error: widget.errorText != null ? Text(widget.errorText!) : null,
          keyboardType: widget.keyboardType,
          prefixBuilder: widget.prefix != null
              ? (_, __, ___) => widget.prefix!
              : null,
          suffixBuilder: widget.suffix != null
              ? (_, __, ___) => widget.suffix!
              : null,
        ),
      );
}
