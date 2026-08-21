import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8EEFF), AppColors.surface, Color(0xFFF5F3FF)],
            stops: [0.0, 0.45, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.marginMobile,
                vertical: AppSpacing.md,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppSpacing.maxWidthAuth,
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: AppRadius.borderXl,
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
