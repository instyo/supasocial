import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/auth_providers.dart';

class SocialAuthButtons extends ConsumerWidget {
  const SocialAuthButtons({super.key});

  bool get _supportsAppleSignIn =>
      !kIsWeb && (Platform.isIOS || Platform.isAndroid || Platform.isMacOS);

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Social sign-in coming soon')));
  }

  Future<void> _onGoogle(BuildContext context, WidgetRef ref) async {
    final result = await ref
        .read(authControllerProvider.notifier)
        .signInWithGoogle();

    if (!context.mounted || result == true || result == null) return;

    final error = ref.read(authControllerProvider).error;
    final message = error is Exception
        ? error.toString().replaceFirst('Exception: ', '')
        : 'Google sign-in failed. Please try again.';

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _onApple(BuildContext context, WidgetRef ref) async {
    final result = await ref
        .read(authControllerProvider.notifier)
        .signInWithApple();

    if (!context.mounted || result == true || result == null) return;

    final error = ref.read(authControllerProvider).error;
    final message = error is Exception
        ? error.toString().replaceFirst('Exception: ', '')
        : 'Apple sign-in failed. Please try again.';

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider(color: AppColors.outlineVariant)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Text(
                'or continue with',
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
            const Expanded(child: Divider(color: AppColors.outlineVariant)),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SocialButton(
              assetPath: 'assets/images/google.png',
              semanticLabel: 'Sign in with Google',
              onTap: isLoading ? null : () => _onGoogle(context, ref),
            ),
            if (_supportsAppleSignIn) ...[
              const SizedBox(width: AppSpacing.sm + 4),
              _SocialButton(
                assetPath: 'assets/images/apple.png',
                semanticLabel: 'Sign in with Apple',
                onTap: isLoading ? null : () => _onApple(context, ref),
              ),
            ],
            const SizedBox(width: AppSpacing.sm + 4),
            _SocialButton(
              assetPath: 'assets/images/facebook.png',
              semanticLabel: 'Sign in with Facebook',
              onTap: isLoading ? null : () => _showComingSoon(context),
            ),
          ],
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.assetPath,
    required this.semanticLabel,
    required this.onTap,
  });

  final String assetPath;
  final String semanticLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return Material(
      color: AppColors.socialButtonBg,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: Opacity(
              opacity: enabled ? 1 : 0.4,
              child: Image.asset(
                assetPath,
                width: 22,
                height: 22,
                fit: BoxFit.contain,
                semanticLabel: semanticLabel,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
