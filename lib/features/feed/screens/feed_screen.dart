import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/feed_provider.dart';
import '../widgets/channel_filter_bar.dart';
import '../widgets/post_card.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final channelsAsync = ref.watch(channelsProvider);
    final selectedChannelId = ref.watch(selectedChannelIdProvider);
    final postsAsync = ref.watch(postsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.uaeEmerald, AppColors.uaeEmeraldDark],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'م',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Majlis',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        actions: [
          if (currentUser != null)
            Padding(
              padding: const EdgeInsets.only(right: 14.0),
              child: InkWell(
                onTap: () => _showUserMenu(context, ref),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: currentUser.company.brandColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        currentUser.company.name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_drop_down, size: 16, color: AppColors.textMuted),
                    ],
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.login_rounded),
              onPressed: () => context.go('/onboarding'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Channel selector
          channelsAsync.when(
            data: (channels) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ChannelFilterBar(
                channels: channels,
                selectedChannelId: selectedChannelId,
                userCompanyName: currentUser?.company.name,
                onChannelSelected: (chId) {
                  ref.read(selectedChannelIdProvider.notifier).selectChannel(chId);
                },
              ),
            ),
            loading: () => const SizedBox(height: 48),
            error: (_, __) => const SizedBox.shrink(),
          ),

          const Divider(height: 1),

          // Posts Feed List
          Expanded(
            child: postsAsync.when(
              data: (posts) {
                if (posts.isEmpty) {
                  return _buildEmptyState(context);
                }

                return RefreshIndicator(
                  color: AppColors.uaeEmerald,
                  backgroundColor: AppColors.surfaceElevated,
                  onRefresh: () => ref.read(postsProvider.notifier).refresh(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: posts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return PostCard(
                        post: post,
                        onTap: () {
                          context.push('/post/${post.id}', extra: post);
                        },
                        onLikeTap: () {
                          ref.read(postsProvider.notifier).toggleLike(post.id);
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.uaeEmerald),
              ),
              error: (err, _) => Center(
                child: Text(
                  'Error loading posts: $err',
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.uaeEmerald,
        foregroundColor: Colors.white,
        elevation: 4,
        onPressed: () {
          if (currentUser == null) {
            context.go('/onboarding');
          } else {
            context.push('/create-post');
          }
        },
        icon: const Icon(Icons.edit_outlined, size: 20),
        label: const Text(
          'Post Anonymously',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.forum_outlined,
                size: 40,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No posts in this lounge yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Be the first verified colleague to start an anonymous discussion in this channel.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showUserMenu(BuildContext context, WidgetRef ref) {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: user.company.brandColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.verified_user_rounded,
                        color: user.company.brandColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.company.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Handle: ${user.nickname} · ${user.company.industry}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.security, color: AppColors.uaeEmerald),
                  title: const Text('Zero-PII Anonymity Status', style: TextStyle(fontSize: 14)),
                  subtitle: const Text('Verified by work email hash (No plaintext stored)', style: TextStyle(fontSize: 11)),
                  contentPadding: EdgeInsets.zero,
                ),
                ListTile(
                  leading: const Icon(Icons.swap_horiz, color: AppColors.textSecondary),
                  title: const Text('Switch Demo Profile', style: TextStyle(fontSize: 14)),
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    Navigator.pop(ctx);
                    context.go('/onboarding');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: AppColors.error),
                  title: const Text('Sign Out', style: TextStyle(fontSize: 14, color: AppColors.error)),
                  contentPadding: EdgeInsets.zero,
                  onTap: () async {
                    Navigator.pop(ctx);
                    await ref.read(authStateProvider.notifier).signOut();
                    if (context.mounted) {
                      context.go('/onboarding');
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
