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

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authControllerProvider.notifier).signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );

    if (!mounted || success) return;

    final error = ref.read(authControllerProvider).error;
    final message = error is Exception
        ? error.toString().replaceFirst('Exception: ', '')
        : 'Sign in failed. Please try again.';

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
              title: 'Welcome Back',
              subtitle:
                  'Sign in to continue your focused,\ncalm social experience.',
            ),
            const SizedBox(height: AppSpacing.lg - 4),
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
              autofillHints: const [AutofillHints.password],
              onToggleObscure: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
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
                  : const Text('Sign In'),
            ),
            const SizedBox(height: AppSpacing.md),
            const SocialAuthButtons(),
            const SizedBox(height: AppSpacing.md),
            AuthFooterLink(
              prompt: "Don't have an account?",
              actionLabel: 'Sign Up',
              onPressed: isLoading ? () {} : () => context.go('/sign-up'),
            ),
          ],
        ),
      ),
    );
  }
}
