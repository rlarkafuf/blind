import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/channels.dart';
import '../../../models/channel.dart';
import '../../../models/comment.dart';
import '../../../models/post.dart';
import '../../auth/providers/auth_provider.dart';
import '../repositories/feed_repository.dart';

final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  return MockFeedRepository();
});

final channelsProvider = FutureProvider<List<Channel>>((ref) async {
  final repo = ref.watch(feedRepositoryProvider);
  return repo.getChannels();
});

class SelectedChannelNotifier extends Notifier<String> {
  @override
  String build() => AppChannelIds.uaeLounge;

  void selectChannel(String channelId) {
    state = channelId;
  }
}

final selectedChannelIdProvider =
    NotifierProvider<SelectedChannelNotifier, String>(SelectedChannelNotifier.new);

class PostsNotifier extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() async {
    final channelId = ref.watch(selectedChannelIdProvider);
    final user = ref.watch(currentUserProvider);
    final repo = ref.watch(feedRepositoryProvider);

    return repo.getPosts(
      channelId: channelId,
      companyId: user?.company.id,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }

  Future<void> toggleLike(String postId) async {
    final repo = ref.read(feedRepositoryProvider);
    await repo.toggleLike(postId);

    final currentPosts = state.value;
    if (currentPosts != null) {
      final updated = currentPosts.map((p) {
        if (p.id == postId) {
          final isLiked = !p.isLiked;
          final count = isLiked ? p.likeCount + 1 : (p.likeCount > 0 ? p.likeCount - 1 : 0);
          return p.copyWith(isLiked: isLiked, likeCount: count);
        }
        return p;
      }).toList();
      state = AsyncValue.data(updated);
    }
  }

  Future<void> addPost(Post newPost) async {
    final currentPosts = state.value ?? [];
    state = AsyncValue.data([newPost, ...currentPosts]);
  }
}

final postsProvider =
    AsyncNotifierProvider<PostsNotifier, List<Post>>(PostsNotifier.new);

final postCommentsProvider =
    FutureProvider.family<List<Comment>, String>((ref, postId) async {
  final repo = ref.watch(feedRepositoryProvider);
  return repo.getComments(postId);
});
