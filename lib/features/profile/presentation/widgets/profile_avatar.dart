import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    this.imageUrl,
    this.localFile,
    this.size = 88,
    this.showBorder = true,
  });

  final String? imageUrl;
  final File? localFile;
  final double size;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final radius = size / 2;

    Widget image;
    if (localFile != null) {
      image = Image.file(
        localFile!,
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      image = CachedNetworkImage(
        imageUrl: imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (context, url) => _placeholder(radius),
        errorWidget: (context, url, error) => _placeholder(radius),
      );
    } else {
      image = _placeholder(radius);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(color: Colors.white, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(child: image),
    );
  }

  Widget _placeholder(double radius) {
    return Container(
      width: size,
      height: size,
      color: AppColors.surfaceContainerHigh,
      child: Icon(
        Icons.person_rounded,
        size: radius,
        color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
      ),
    );
  }
}
