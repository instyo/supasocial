import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void openUserProfile(
  BuildContext context, {
  required String userId,
  String? currentUserId,
}) {
  if (userId.isEmpty) return;

  if (currentUserId != null && userId == currentUserId) {
    context.go('/profile');
    return;
  }

  context.push('/users/$userId');
}
