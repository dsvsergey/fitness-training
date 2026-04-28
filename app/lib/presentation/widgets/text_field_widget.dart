import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class TextFieldWidget extends StatefulWidget {
  const TextFieldWidget({
    super.key,
    this.controller,
    this.onChanged,
    this.prefix,
    this.suffix,
    this.hintText,
    this.keyboardType,
    this.errorText,
    this.isPassword = false,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final Widget? prefix;
  final Widget? suffix;
  final String? hintText;
  final TextInputType? keyboardType;
  final String? errorText;
  final bool isPassword;

  @override
  State<TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
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
  Widget build(BuildContext context) {
    if (widget.isPassword) {
      return FTextField.password(
        control: FTextFieldControl.managed(controller: _controller),
        hint: widget.hintText,
        error: widget.errorText != null ? Text(widget.errorText!) : null,
        keyboardType: widget.keyboardType,
      );
    }

    return FTextField(
      control: FTextFieldControl.managed(controller: _controller),
      hint: widget.hintText,
      error: widget.errorText != null ? Text(widget.errorText!) : null,
      keyboardType: widget.keyboardType,
      prefixBuilder: widget.prefix != null ? (_, _, _) => widget.prefix! : null,
      suffixBuilder: widget.suffix != null ? (_, _, _) => widget.suffix! : null,
    );
  }
}
