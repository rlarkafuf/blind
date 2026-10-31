import 'package:go_router/go_router.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/create_post/screens/create_post_screen.dart';
import '../../features/feed/screens/feed_screen.dart';
import '../../features/post_detail/screens/post_detail_screen.dart';
import '../../models/post.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/feed',
    routes: [
      GoRoute(
        path: '/feed',
        name: 'feed',
        builder: (context, state) => const FeedScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/create-post',
        name: 'create-post',
        builder: (context, state) => const CreatePostScreen(),
      ),
      GoRoute(
        path: '/post/:id',
        name: 'post-detail',
        builder: (context, state) {
          final postId = state.pathParameters['id'] ?? '';
          final post = state.extra as Post?;
          return PostDetailScreen(
            postId: postId,
            initialPost: post,
          );
        },
      ),
    ],
  );
}
