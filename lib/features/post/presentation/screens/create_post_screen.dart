import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/post_providers.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _captionController = TextEditingController();
  File? _pickedImage;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 85,
    );
    if (file == null) return;
    setState(() => _pickedImage = File(file.path));
  }

  Future<void> _submit() async {
    final image = _pickedImage;
    if (image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a photo')),
      );
      return;
    }

    final success = await ref.read(createPostControllerProvider.notifier).create(
          image: image,
          caption: _captionController.text,
        );

    if (!mounted) return;

    if (success) {
      context.pop();
      return;
    }

    final error = ref.read(createPostControllerProvider).error;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error?.toString() ?? 'Failed to create post.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final createState = ref.watch(createPostControllerProvider);
    final isSubmitting = createState.isLoading;
    final canSubmit = _pickedImage != null && !isSubmitting;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: isSubmitting ? null : () => context.pop(),
          icon: const Icon(Icons.close_rounded),
        ),
        title: Text(
          'New Post',
          style: AppTextStyles.headlineMd.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: canSubmit ? _submit : null,
            child: isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Share',
                    style: AppTextStyles.labelMd.copyWith(
                      color: canSubmit
                          ? AppColors.primary
                          : AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.marginMobile),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: isSubmitting ? null : _pickImage,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: AppRadius.borderXl,
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _pickedImage != null
                        ? Image.file(
                            _pickedImage!,
                            fit: BoxFit.cover,
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 48,
                                color: AppColors.onSurfaceVariant
                                    .withValues(alpha: 0.6),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                'Tap to choose a photo',
                                style: AppTextStyles.labelMd.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              if (_pickedImage != null) ...[
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: isSubmitting ? null : _pickImage,
                  child: const Text('Change photo'),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _captionController,
                enabled: !isSubmitting,
                maxLines: 5,
                maxLength: 500,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Write a caption...',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
