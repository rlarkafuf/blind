import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../feed/providers/feed_provider.dart';
import '../../feed/widgets/post_card.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('마이페이지')),
        body: Center(
          child: ElevatedButton(
            onPressed: () => context.pushNamed('onboarding'),
            child: const Text('로그인하기'),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('마이페이지'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authStateProvider.notifier).signOut();
              context.goNamed('feed');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: currentUser.company.brandColor,
                  child: const Icon(Icons.person, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentUser.company.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      currentUser.nickname,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            labelColor: AppColors.textPrimary,
            unselectedLabelColor: AppColors.textMuted,
            indicatorColor: AppColors.textPrimary,
            tabs: const [
              Tab(text: '내가 쓴 글'),
              Tab(text: '댓글 단 글'),
              Tab(text: '좋아요 한 글'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _PostList(fetcher: (repo) => repo.getMyPosts(currentUser.id)),
                _PostList(fetcher: (repo) => repo.getMyCommentedPosts(currentUser.id)),
                _PostList(fetcher: (repo) => repo.getMyLikedPosts(currentUser.id)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        ref.read(authStateProvider.notifier).signOut();
                        context.goNamed('feed');
                      },
                      child: const Text('로그아웃', style: TextStyle(color: AppColors.textPrimary)),
                    ),
                    const Text('|', style: TextStyle(color: AppColors.border)),
                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('회원탈퇴'),
                            content: const Text('정말로 탈퇴하시겠습니까?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('취소', style: TextStyle(color: AppColors.textPrimary)),
                              ),
                              TextButton(
                                onPressed: () {
                                  ref.read(authStateProvider.notifier).deleteAccount();
                                  context.goNamed('feed');
                                },
                                child: const Text('탈퇴하기', style: TextStyle(color: AppColors.error)),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text('회원탈퇴', style: TextStyle(color: AppColors.textPrimary)),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    // Placeholder for privacy policy
                  },
                  child: const Text('개인정보 처리방침', style: TextStyle(color: AppColors.textMuted, decoration: TextDecoration.underline)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PostList extends ConsumerWidget {
  final Future<List<dynamic>> Function(dynamic repo) fetcher;

  const _PostList({required this.fetcher});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(feedRepositoryProvider);

    return FutureBuilder(
      future: fetcher(repo),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('에러 발생: ${snapshot.error}'));
        }
        final posts = snapshot.data ?? [];
        if (posts.isEmpty) {
          return const Center(child: Text('해당하는 글이 없습니다.', style: TextStyle(color: AppColors.textMuted)));
        }
        return ListView.separated(
          itemCount: posts.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final post = posts[index];
            return PostCard(
              post: post,
              onTap: () {
                context.pushNamed(
                  'post-detail',
                  pathParameters: {'id': post.id},
                  extra: post,
                );
              },
              onLikeTap: () {
                ref.read(postsProvider.notifier).toggleLike(post.id);
              },
            );
          },
        );
      },
    );
  }
}
