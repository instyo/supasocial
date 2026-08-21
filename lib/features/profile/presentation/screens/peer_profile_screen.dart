import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../post/presentation/providers/post_providers.dart';
import '../../data/models/profile.dart';
import '../providers/profile_providers.dart';
import '../widgets/profile_action_buttons.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_posts_grid.dart';

class PeerProfileScreen extends ConsumerStatefulWidget {
  const PeerProfileScreen({super.key, required this.userId});

  final String userId;

  @override
  ConsumerState<PeerProfileScreen> createState() => _PeerProfileScreenState();
}

class _PeerProfileScreenState extends ConsumerState<PeerProfileScreen> {
  bool? _following;
  int? _followersCount;
  bool _followBusy = false;
  bool _seeded = false;

  void _seedFollowState(Profile profile) {
    if (_seeded) return;
    _following = profile.isFollowing;
    _followersCount = profile.followersCount;
    _seeded = true;
  }

  Future<void> _shareProfile(String username) async {
    final handle = username.startsWith('@') ? username : '@$username';
    await Clipboard.setData(ClipboardData(text: handle));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copied $handle to clipboard')),
    );
  }

  Future<void> _toggleFollow(Profile profile) async {
    if (_followBusy) return;

    final previousFollowing = _following ?? profile.isFollowing;
    final previousCount = _followersCount ?? profile.followersCount;
    final nextFollowing = !previousFollowing;
    final nextCount = nextFollowing
        ? previousCount + 1
        : (previousCount - 1).clamp(0, 1 << 30);

    setState(() {
      _followBusy = true;
      _following = nextFollowing;
      _followersCount = nextCount;
    });

    final result = await ref.read(followControllerProvider).toggle(
          userId: profile.id,
          currentlyFollowing: previousFollowing,
        );

    if (!mounted) return;

    if (result == null) {
      setState(() {
        _following = previousFollowing;
        _followersCount = previousCount;
        _followBusy = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update follow. Try again.')),
      );
      return;
    }

    setState(() => _followBusy = false);
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileByIdProvider(widget.userId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: profileAsync.maybeWhen(
          data: (profile) => Text(
            profile.username.isNotEmpty
                ? (profile.username.startsWith('@')
                    ? profile.username
                    : '@${profile.username}')
                : profile.displayName,
            style: AppTextStyles.headlineMd.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          orElse: () => Text(
            'Profile',
            style: AppTextStyles.headlineMd.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.marginMobile),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  error.toString(),
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                FilledButton(
                  onPressed: () {
                    _seeded = false;
                    ref.invalidate(profileByIdProvider(widget.userId));
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (profile) {
          if (!_seeded) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted || _seeded) return;
              setState(() => _seedFollowState(profile));
            });
          }

          final displayProfile = profile.copyWith(
            isFollowing: _following ?? profile.isFollowing,
            followersCount: _followersCount ?? profile.followersCount,
          );

          return RefreshIndicator(
            onRefresh: () async {
              _seeded = false;
              ref.invalidate(profileByIdProvider(widget.userId));
              ref.invalidate(userPostsProvider(widget.userId));
              await ref.read(profileByIdProvider(widget.userId).future);
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: ProfileHeader(
                    profile: displayProfile,
                    mode: ProfileActionsMode.peer,
                    isFollowing: displayProfile.isFollowing,
                    onFollow: _followBusy
                        ? null
                        : () => _toggleFollow(profile),
                    onShareProfile: () => _shareProfile(profile.username),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.outlineVariant,
                  ),
                ),
                ProfilePostsGrid(userId: profile.id),
              ],
            ),
          );
        },
      ),
    );
  }
}
