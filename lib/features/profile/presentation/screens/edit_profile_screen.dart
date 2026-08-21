import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/widgets/auth_text_field.dart';
import '../../data/models/profile.dart';
import '../providers/profile_providers.dart';
import '../widgets/profile_avatar.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  final _websiteController = TextEditingController();

  File? _pickedImage;
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  void _initFromProfile(Profile profile) {
    if (_initialized) return;
    _nameController.text = profile.fullName ?? '';
    _usernameController.text = profile.username;
    _bioController.text = profile.bio ?? '';
    _websiteController.text = profile.website ?? '';
    _initialized = true;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (file == null) return;
    setState(() => _pickedImage = File(file.path));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(editProfileControllerProvider.notifier).save(
          fullName: _nameController.text,
          username: _usernameController.text,
          bio: _bioController.text,
          website: _websiteController.text,
          avatarFile: _pickedImage,
        );

    if (!mounted) return;

    if (success) {
      context.pop();
      return;
    }

    final error = ref.read(editProfileControllerProvider).error;
    final message = error?.toString() ?? 'Failed to save profile.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentProfileProvider);
    final saveState = ref.watch(editProfileControllerProvider);
    final isSaving = saveState.isLoading;
    final repository = ref.watch(profileRepositoryProvider);

    return profileAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Edit Profile')),
        body: Center(child: Text(error.toString())),
      ),
      data: (profile) {
        if (profile == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Edit Profile')),
            body: const Center(child: Text('Profile not found')),
          );
        }

        _initFromProfile(profile);
        final avatarUrl = repository.avatarPublicUrl(profile.avatarUrl);

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: isSaving ? null : () => context.pop(),
              icon: const Icon(Icons.close_rounded),
            ),
            title: Text(
              'Edit Profile',
              style: AppTextStyles.headlineMd.copyWith(
                color: AppColors.primary,
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : _save,
                child: const Text('Save'),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.marginMobile,
                AppSpacing.md,
                AppSpacing.marginMobile,
                AppSpacing.lg,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: isSaving ? null : _pickImage,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          ProfileAvatar(
                            imageUrl: avatarUrl,
                            localFile: _pickedImage,
                            size: 104,
                          ),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextButton(
                      onPressed: isSaving ? null : _pickImage,
                      child: const Text('Change profile photo'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          AuthTextField(
                            label: 'Name',
                            hint: 'Your name',
                            controller: _nameController,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.sm + 4),
                          AuthTextField(
                            label: 'Username',
                            hint: '@username',
                            controller: _usernameController,
                            textInputAction: TextInputAction.next,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z0-9._]'),
                              ),
                            ],
                            validator: (value) {
                              final cleaned =
                                  value?.trim().replaceFirst(RegExp(r'^@'), '') ??
                                      '';
                              if (cleaned.isEmpty) {
                                return 'Please enter a username';
                              }
                              if (cleaned.length < 3) {
                                return 'Username must be at least 3 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.sm + 4),
                          AuthTextField(
                            label: 'Bio',
                            hint: 'Tell people about yourself',
                            controller: _bioController,
                            maxLines: 4,
                            maxLength: 150,
                            showCounter: true,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                          ),
                          const SizedBox(height: AppSpacing.sm + 4),
                          AuthTextField(
                            label: 'Website',
                            hint: 'yourwebsite.com',
                            controller: _websiteController,
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    FilledButton(
                      onPressed: isSaving ? null : _save,
                      child: isSaving
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Save Changes'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
