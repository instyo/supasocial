import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class HomePlaceholderScreen extends ConsumerWidget {
  const HomePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authRepositoryProvider).currentUser;
    final name = user?.userMetadata?['full_name'] as String? ?? 'there';
    final email = user?.email ?? '';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.marginMobile),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(
                Icons.auto_awesome,
                size: 48,
                color: AppColors.primary.withValues(alpha: 0.8),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Welcome, $name',
                style: AppTextStyles.headlineLgMobile,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                email,
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                "You're signed in. Feed coming soon.",
                style: AppTextStyles.labelMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: () {
                  ref.read(authControllerProvider.notifier).signOut();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.outlineVariant),
                  minimumSize: const Size(double.infinity, 52),
                  shape: const StadiumBorder(),
                ),
                child: const Text('Sign Out'),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}
