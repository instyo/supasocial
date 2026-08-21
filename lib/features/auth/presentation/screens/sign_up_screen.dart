import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../providers/auth_providers.dart';
import '../widgets/auth_footer_link.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/social_auth_buttons.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authControllerProvider.notifier).signUp(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );

    if (!mounted) return;

    if (success) {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Check your email to confirm your account.'),
          ),
        );
      }
      return;
    }

    final error = ref.read(authControllerProvider).error;
    final message = error is Exception
        ? error.toString().replaceFirst('Exception: ', '')
        : 'Sign up failed. Please try again.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return AuthScaffold(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthHeader(
              title: 'Create Account',
              subtitle:
                  'Join Aura to experience a focused,\ncalm social environment.',
            ),
            const SizedBox(height: AppSpacing.lg - 4),
            AuthTextField(
              label: 'Name',
              hint: 'John Doe',
              controller: _nameController,
              prefixIcon: Icons.person_outline_rounded,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your name';
                }
                if (value.trim().length < 2) {
                  return 'Name must be at least 2 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.sm + 4),
            AuthTextField(
              label: 'Email',
              hint: 'john@example.com',
              controller: _emailController,
              prefixIcon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your email';
                }
                final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                if (!emailRegex.hasMatch(value.trim())) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.sm + 4),
            AuthTextField(
              label: 'Password',
              hint: '••••••••',
              controller: _passwordController,
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              onToggleObscure: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: isLoading ? null : _onSubmit,
              child: isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Sign Up'),
            ),
            const SizedBox(height: AppSpacing.md),
            const SocialAuthButtons(),
            const SizedBox(height: AppSpacing.md),
            AuthFooterLink(
              prompt: 'Already have an account?',
              actionLabel: 'Sign In',
              onPressed: isLoading ? () {} : () => context.go('/sign-in'),
            ),
          ],
        ),
      ),
    );
  }
}
