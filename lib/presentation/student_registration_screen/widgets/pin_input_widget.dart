import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';

class PinInputWidget extends StatefulWidget {
  final String label;
  final String? hintText;
  final Function(String) onChanged;
  final bool obscureText;
  final int length;
  final bool enabled;

  const PinInputWidget({
    super.key,
    required this.label,
    this.hintText,
    required this.onChanged,
    this.obscureText = true,
    this.length = 4,
    this.enabled = true,
  });

  @override
  State<PinInputWidget> createState() => _PinInputWidgetState();
}

class _PinInputWidgetState extends State<PinInputWidget> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  late List<String> _pin;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.length,
      (index) => TextEditingController(),
    );
    _focusNodes = List.generate(
      widget.length,
      (index) => FocusNode(),
    );
    _pin = List.filled(widget.length, '');
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onTextChanged(String value, int index) {
    if (value.length > 1) {
      // Handle paste or multiple character input
      final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
      if (digits.length >= widget.length) {
        // Fill all fields with pasted digits
        for (int i = 0; i < widget.length; i++) {
          _controllers[i].text = digits[i];
          _pin[i] = digits[i];
        }
        _focusNodes.last.requestFocus();
      } else {
        // Fill available digits
        for (int i = 0; i < digits.length && i < widget.length; i++) {
          _controllers[i].text = digits[i];
          _pin[i] = digits[i];
        }
        if (digits.length < widget.length) {
          _focusNodes[digits.length].requestFocus();
        }
      }
    } else {
      _pin[index] = value;
      if (value.isNotEmpty && index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      }
    }

    widget.onChanged(_pin.join(''));
  }

  void _onKeyPressed(KeyEvent event, int index) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.backspace) {
        if (_pin[index].isEmpty && index > 0) {
          _focusNodes[index - 1].requestFocus();
          _controllers[index - 1].clear();
          _pin[index - 1] = '';
          widget.onChanged(_pin.join(''));
        }
      }
    }
  }

  void _clearAll() {
    for (int i = 0; i < widget.length; i++) {
      _controllers[i].clear();
      _pin[i] = '';
    }
    _focusNodes[0].requestFocus();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label,
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_pin.any((digit) => digit.isNotEmpty))
              TextButton(
                onPressed: _clearAll,
                child: Text(
                  'Clear',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 2.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(widget.length, (index) {
            return Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _pin[index].isNotEmpty
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.outline,
                  width: 2,
                ),
                boxShadow: _pin[index].isNotEmpty
                    ? [
                        BoxShadow(
                          color: AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: KeyboardListener(
                focusNode: FocusNode(),
                onKeyEvent: (event) => _onKeyPressed(event, index),
                child: TextField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(1),
                  ],
                  obscureText: widget.obscureText,
                  enabled: widget.enabled,
                  style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    counterText: '',
                  ),
                  onChanged: (value) => _onTextChanged(value, index),
                ),
              ),
            );
          }),
        ),
        if (widget.hintText != null) ...[
          SizedBox(height: 1.h),
          Text(
            widget.hintText!,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
