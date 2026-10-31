import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/anonymity_helper.dart';
import '../../../models/comment.dart';
import '../../../models/post.dart';
import '../../auth/providers/auth_provider.dart';
import '../../feed/providers/feed_provider.dart';
import '../utils/anonymous_mapping.dart';
import '../widgets/comment_tile.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  final String postId;
  final Post? initialPost;

  const PostDetailScreen({
    super.key,
    required this.postId,
    this.initialPost,
  });

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  Comment? _replyTarget;
  bool _isSubmitting = false;
  Post? _post;

  @override
  void initState() {
    super.initState();
    _post = widget.initialPost;
    if (_post == null) {
      _loadPost();
    }
  }

  Future<void> _loadPost() async {
    final repo = ref.read(feedRepositoryProvider);
    final p = await repo.getPostById(widget.postId);
    if (mounted && p != null) {
      setState(() {
        _post = p;
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    final user = ref.read(currentUserProvider);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in with a verified work email to comment.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final repo = ref.read(feedRepositoryProvider);
      await repo.createComment(
        postId: widget.postId,
        parentId: _replyTarget?.id,
        content: content,
        author: user,
      );

      _commentController.clear();
      setState(() {
        _replyTarget = null;
        _isSubmitting = false;
        if (_post != null) {
          _post = _post!.copyWith(commentCount: _post!.commentCount + 1);
        }
      });

      // Invalidate comments to refresh UI
      ref.invalidate(postCommentsProvider(widget.postId));
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post comment: $e')),
        );
      }
    }
  }





  void _handleVote(String optionId) async {
    final repo = ref.read(feedRepositoryProvider);
    await repo.votePoll(widget.postId, optionId);
    final updatedPost = await repo.getPostById(widget.postId);
    setState(() {
      _post = updatedPost;
    });
  }

  @override
  Widget build(BuildContext context) {
    final post = _post;
    final currentUser = ref.watch(currentUserProvider);
    final commentsAsync = ref.watch(postCommentsProvider(widget.postId));

    if (post == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.uaeEmerald),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          post.companyNameSnapshot,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 20),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Anonymous link copied to clipboard')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Post Content and Comments ScrollView
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author Badge & Timestamp
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.uaeEmerald,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              post.authorBadge,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        AnonymityHelper.formatRelativeTime(post.createdAt),
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Post Title
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Full Post Content
                  Text(
                    post.content,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                      height: 1.6,
                    ),
                  ),

                  // Poll UI
                  if (post.poll != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.poll!.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...post.poll!.options.map((option) {
                            final totalVotes = post.poll!.options.fold(0, (sum, opt) => sum + opt.votes);
                            final percent = totalVotes == 0 ? 0.0 : option.votes / totalVotes;

                            return GestureDetector(
                              onTap: () => _handleVote(option.id),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: Stack(
                                  children: [
                                    Container(
                                      height: 40,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceElevated,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    FractionallySizedBox(
                                      widthFactor: percent,
                                      child: Container(
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: AppColors.uaeEmerald.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                    Positioned.fill(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              option.text,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            Text(
                                              '${(percent * 100).toStringAsFixed(1)}%',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 8),
                          Text(
                            '총 ${post.poll!.options.fold(0, (sum, opt) => sum + opt.votes)}명 참여',
                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  const SizedBox(height: 20),

                  // Engagement Counter Bar
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          ref.read(postsProvider.notifier).toggleLike(post.id);
                          final isLiked = !post.isLiked;
                          final newCount = isLiked ? post.likeCount + 1 : (post.likeCount > 0 ? post.likeCount - 1 : 0);
                          setState(() {
                            _post = post.copyWith(isLiked: isLiked, likeCount: newCount);
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: post.isLiked ? AppColors.uaeRed.withValues(alpha: 0.15) : AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: post.isLiked ? AppColors.uaeRed.withValues(alpha: 0.4) : AppColors.border,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                post.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                size: 16,
                                color: post.isLiked ? AppColors.uaeRed : AppColors.textMuted,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${post.likeCount}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: post.isLiked ? AppColors.uaeRed : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: AppColors.textMuted),
                            const SizedBox(width: 6),
                            Text(
                              '${post.commentCount}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Row(
                        children: [
                          const Icon(Icons.visibility_outlined, size: 16, color: AppColors.textMuted),
                          const SizedBox(width: 6),
                          Text(
                            '${post.viewCount}',
                            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),

                  // Comments Header
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      'Comments (${post.commentCount})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),

                  // Comments List
                  commentsAsync.when(
                    data: (comments) {
                      if (comments.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.0),
                          child: Center(
                            child: Text(
                              '등록된 댓글이 없습니다.',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                            ),
                          ),
                        );
                      }

                      final anonMapping = AnonymousMappingUtils.buildAnonymousMapping(comments, post.authorNickname);

                      return Column(
                        children: comments.map((comment) {
                          final mappedComment = comment.copyWith(
                            authorNickname: anonMapping[comment.authorNickname] ?? comment.authorNickname
                          );
                          return CommentTile(
                            comment: mappedComment,
                            onReplyTap: (target) {
                              setState(() {
                                _replyTarget = target;
                              });
                            },
                          );
                        }).toList(),
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: AppColors.uaeEmerald),
                    ),
                    error: (err, _) => Text(
                      'Failed to load comments: $err',
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Replying indicator if active
          if (_replyTarget != null)
            Container(
              color: AppColors.surfaceElevated,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.reply, size: 16, color: AppColors.uaeEmerald),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Replying to ${_replyTarget!.authorBadge}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.uaeEmerald,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16, color: AppColors.textMuted),
                    onPressed: () {
                      setState(() {
                        _replyTarget = null;
                      });
                    },
                  ),
                ],
              ),
            ),

          // Bottom Anonymous Comment Input Bar
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 10,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (currentUser != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Row(
                      children: [
                        const Icon(Icons.lock_outline, size: 12, color: AppColors.uaeEmerald),
                        const SizedBox(width: 4),
                        Text(
                          'Commenting anonymously as ${currentUser.badgeLabel}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: _replyTarget != null ? 'Write an anonymous reply...' : 'Add an anonymous comment...',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.uaeEmerald,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _isSubmitting ? null : _handleSubmitComment,
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.send_rounded, size: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
