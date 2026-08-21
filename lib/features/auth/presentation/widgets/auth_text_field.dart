import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.prefixIcon,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.onToggleObscure,
    this.validator,
    this.autofillHints,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData prefixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final VoidCallback? onToggleObscure;
  final String? Function(String?)? validator;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMd),
        const SizedBox(height: AppSpacing.xs + 2),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          validator: validator,
          autofillHints: autofillHints,
          style: AppTextStyles.bodyMd,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(prefixIcon, size: 20),
            suffixIcon: onToggleObscure == null
                ? null
                : IconButton(
                    onPressed: onToggleObscure,
                    icon: Icon(
                      obscureText
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
