import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../calculator/screens/calculator_screen.dart';
import '../providers/feed_provider.dart';
import '../widgets/channel_filter_bar.dart';
import '../widgets/post_card.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const FeedScreen(),
          const Scaffold(body: Center(child: Text('채널 화면'))),
          const SizedBox(), // Placeholder for Write (handled via onTap)
          const CalculatorScreen(),
          const Scaffold(body: Center(child: Text('마이페이지 화면'))),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 2) {
            context.pushNamed('create-post');
          } else if (index == 4) {
            context.pushNamed('profile');
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: '채널'),
          BottomNavigationBarItem(icon: Icon(Icons.edit_square), label: '글쓰기'),
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: '계산기/비교'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이페이지'),
        ],
      ),
    );
  }
}

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
                color: AppColors.uaeEmerald,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'B',
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
              'Blind',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {},
          ),
          if (currentUser == null)
            TextButton(
              onPressed: () => context.pushNamed('onboarding'),
              child: const Text('Login'),
            )
        ],
      ),
      body: Column(
        children: [
          // Channels Filter Bar
          channelsAsync.when(
            data: (channels) => ChannelFilterBar(
              channels: channels,
              selectedChannelId: selectedChannelId,
              userCompanyName: currentUser?.company.name,
              onChannelSelected: (id) {
                ref.read(selectedChannelIdProvider.notifier).selectChannel(id);
              },
            ),
            loading: () => const SizedBox(height: 48, child: Center(child: CircularProgressIndicator())),
            error: (_, __) => const SizedBox(height: 48),
          ),
          const Divider(),

          // Feed List
          Expanded(
            child: postsAsync.when(
              data: (posts) {
                return RefreshIndicator(
                  color: AppColors.uaeEmerald,
                  onRefresh: () => ref.read(postsProvider.notifier).refresh(),
                  child: ListView.separated(
                    padding: const EdgeInsets.only(bottom: 80, top: 8),
                    itemCount: posts.length,
                    separatorBuilder: (context, index) => const Divider(),
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
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.uaeEmerald)),
              error: (err, st) => Center(
                child: Text('Error loading feed: $err', style: const TextStyle(color: AppColors.error)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
