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
  });

  @override
  State<SecureTextField> createState() => _SecureTextFieldState();
}

class _SecureTextFieldState extends State<SecureTextField> {
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_validateField);
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
      onChanged: (value) {
        // Prevent paste operations
        if (value.length > widget.controller.text.length + 1) {
          // Likely a paste operation, revert to previous value
          widget.controller.text = widget.controller.text;
          widget.controller.selection = TextSelection.fromPosition(
            TextPosition(offset: widget.controller.text.length),
          );
        }
      },
    );
  }
}
