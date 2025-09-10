import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SecureTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final IconData prefixIcon;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final TextCapitalization textCapitalization;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool showSuffixIcon;
  final Color? suffixIconColor;
  final VoidCallback? onTap;
  final bool enabled;
  final bool disableCopyPaste;

  const SecureTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.prefixIcon,
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.textCapitalization = TextCapitalization.none,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.showSuffixIcon = false,
    this.suffixIconColor,
    this.onTap,
    this.enabled = true,
    this.disableCopyPaste = true,
  });

  @override
  State<SecureTextField> createState() => _SecureTextFieldState();
}

class _SecureTextFieldState extends State<SecureTextField> {
  bool _isValid = false;
  String _previousText = '';

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_validateField);
    _previousText = widget.controller.text;
  }

  @override
  void dispose() {
    widget.controller.removeListener(_validateField);
    super.dispose();
  }

  void _validateField() {
    setState(() {
      _isValid = widget.controller.text.trim().isNotEmpty;
    });
  }

  void _handleTextChange(String newText) {
    if (!widget.disableCopyPaste) {
      _previousText = newText;
      return;
    }

    // Check if this is a paste operation (sudden large text change)
    if (newText.length > _previousText.length + 1) {
      // Likely a paste operation, revert to previous text
      widget.controller.text = _previousText;
      widget.controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _previousText.length),
      );
      return;
    }

    // Check for copy/paste using clipboard
    _checkClipboardOperation(newText);
    _previousText = newText;
  }

  void _checkClipboardOperation(String newText) async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData?.text != null && 
          clipboardData!.text!.isNotEmpty &&
          newText.contains(clipboardData.text!)) {
        // Detected clipboard content in the text, revert
        widget.controller.text = _previousText;
        widget.controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _previousText.length),
        );
      }
    } catch (e) {
      // Ignore clipboard access errors
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      enabled: widget.enabled,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        prefixIcon: Icon(
          widget.prefixIcon,
          color: _isValid
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        suffixIcon: widget.showSuffixIcon && _isValid
            ? Icon(
                Icons.check_circle,
                color: widget.suffixIconColor ?? Colors.green,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ),
      validator: widget.validator,
      textCapitalization: widget.textCapitalization,
      textInputAction: widget.textInputAction,
      keyboardType: widget.keyboardType,
      enableSuggestions: false,
      autocorrect: false,
      inputFormatters: widget.inputFormatters,
      onTap: widget.onTap,
      onChanged: _handleTextChange,
    );
  }
}
