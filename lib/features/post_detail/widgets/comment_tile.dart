import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/anonymity_helper.dart';
import '../../../models/comment.dart';

class CommentTile extends StatelessWidget {
  final Comment comment;
  final ValueChanged<Comment>? onReplyTap;
  final bool isReply;

  const CommentTile({
    super.key,
    required this.comment,
    this.onReplyTap,
    this.isReply = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: isReply ? 28.0 : 0.0,
        top: 8.0,
        bottom: 8.0,
      ),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: isReply ? AppColors.surfaceElevated.withValues(alpha: 0.6) : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isReply ? AppColors.border.withValues(alpha: 0.5) : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Author Badge + Time
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  comment.authorBadge,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                AnonymityHelper.formatRelativeTime(comment.createdAt),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Content
          Text(
            comment.content,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),

          // Actions: Like + Reply
          Row(
            children: [
              Row(
                children: [
                  Icon(
                    comment.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    size: 14,
                    color: comment.isLiked ? AppColors.uaeRed : AppColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${comment.likeCount}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
              if (!isReply && onReplyTap != null) ...[
                const SizedBox(width: 16),
                InkWell(
                  onTap: () => onReplyTap!(comment),
                  borderRadius: BorderRadius.circular(4),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Row(
                      children: [
                        Icon(Icons.reply_rounded, size: 14, color: AppColors.uaeEmerald),
                        SizedBox(width: 4),
                        Text(
                          'Reply',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.uaeEmerald,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),

          // Nested Replies
          if (comment.replies.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...comment.replies.map(
              (reply) => CommentTile(
                comment: reply,
                isReply: true,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
