import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';

class PostImage extends StatelessWidget {
  const PostImage({
    super.key,
    required this.imageUrl,
    this.borderRadius,
    this.aspectRatio = 1,
    this.fit = BoxFit.cover,
    this.height,
  });

  final String imageUrl;
  final BorderRadius? borderRadius;
  final double aspectRatio;
  final BoxFit fit;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppRadius.borderMd;

    final image = CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: double.infinity,
      height: height == double.infinity ? null : height,
      placeholder: (context, url) => Container(
        color: AppColors.surfaceContainerHigh,
        alignment: Alignment.center,
        child: const SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: AppColors.surfaceContainerHigh,
        alignment: Alignment.center,
        child: Icon(
          Icons.broken_image_outlined,
          color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
          size: 40,
        ),
      ),
    );

    Widget child = image;
    if (height == double.infinity) {
      child = SizedBox.expand(child: image);
    } else if (height == null) {
      child = AspectRatio(aspectRatio: aspectRatio, child: image);
    }

    return ClipRRect(borderRadius: radius, child: child);
  }
}
