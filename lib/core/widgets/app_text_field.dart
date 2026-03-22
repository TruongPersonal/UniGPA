import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unigpa/core/constants/app_colors.dart';

import '../constants/app_text_styles.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    this.label,
    required this.hint,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.autocorrect = true,
    this.enableSuggestions,
    this.maxLength,
    this.onChanged,
    this.trailingLabel,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String? label;
  final String hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final bool autocorrect;
  final bool? enableSuggestions;
  final int? maxLength;
  final void Function(String)? onChanged;
  final Widget? trailingLabel;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label!,
                style: AppTextStyles.labelLarge.copyWith(color: colors.textPrimary),
              ),
              ?trailingLabel,
            ],
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          autocorrect: autocorrect,
          enableSuggestions: enableSuggestions ?? autocorrect,
          maxLength: maxLength,
          onChanged: onChanged,
          autofocus: autofocus,
          style: TextStyle(color: colors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            counterText: '',
          ),
        ),
      ],
    );
  }
}
