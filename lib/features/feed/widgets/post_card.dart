import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/anonymity_helper.dart';
import '../../../models/post.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;
  final VoidCallback onLikeTap;

  const PostCard({
    super.key,
    required this.post,
    required this.onTap,
    required this.onLikeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Company Badge + Time + Pinned Indicator
              Row(
                children: [
                  _buildCompanyBadge(),
                  const Spacer(),
                  if (post.isPinned) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.uaeGold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.uaeGold.withValues(alpha: 0.4)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.push_pin, size: 11, color: AppColors.uaeGold),
                          SizedBox(width: 3),
                          Text(
                            'PINNED',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.uaeGold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    AnonymityHelper.formatRelativeTime(post.createdAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                post.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),

              // Snippet Content
              Text(
                post.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 14),

              // Footer: Likes, Comments, Views
              Row(
                children: [
                  InkWell(
                    onTap: onLikeTap,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Row(
                        children: [
                          Icon(
                            post.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            size: 16,
                            color: post.isLiked ? AppColors.uaeRed : AppColors.textMuted,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${post.likeCount}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: post.isLiked ? AppColors.uaeRed : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Row(
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 15,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${post.commentCount}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Row(
                    children: [
                      const Icon(
                        Icons.visibility_outlined,
                        size: 15,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.viewCount}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompanyBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.uaeEmerald,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            post.authorBadge,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
