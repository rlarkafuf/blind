import 'package:flutter/foundation.dart';

/// Represents an anonymous comment or nested reply on a post.
@immutable
class Comment {
  final String id;
  final String postId;
  final String? parentId; // Null for top-level comments, UUID for replies
  final String companyNameSnapshot;
  final String authorNickname;
  final String content;
  final int likeCount;
  final bool isLiked;
  final DateTime createdAt;
  final List<Comment> replies;

  const Comment({
    required this.id,
    required this.postId,
    this.parentId,
    required this.companyNameSnapshot,
    required this.authorNickname,
    required this.content,
    this.likeCount = 0,
    this.isLiked = false,
    required this.createdAt,
    this.replies = const [],
  });

  Comment copyWith({
    String? id,
    String? postId,
    String? parentId,
    String? companyNameSnapshot,
    String? authorNickname,
    String? content,
    int? likeCount,
    bool? isLiked,
    DateTime? createdAt,
    List<Comment>? replies,
  }) {
    return Comment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      parentId: parentId ?? this.parentId,
      companyNameSnapshot: companyNameSnapshot ?? this.companyNameSnapshot,
      authorNickname: authorNickname ?? this.authorNickname,
      content: content ?? this.content,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt ?? this.createdAt,
      replies: replies ?? this.replies,
    );
  }

  factory Comment.fromJson(Map<String, dynamic> json, {List<Comment> replies = const []}) {
    return Comment(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      parentId: json['parent_id'] as String?,
      companyNameSnapshot: json['company_name_snapshot'] as String,
      authorNickname: json['author_nickname'] as String,
      content: json['content'] as String,
      likeCount: (json['like_count'] as int?) ?? 0,
      isLiked: (json['is_liked'] as bool?) ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      replies: replies,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'parent_id': parentId,
      'company_name_snapshot': companyNameSnapshot,
      'author_nickname': authorNickname,
      'content': content,
      'like_count': likeCount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get authorBadge => '[$companyNameSnapshot · $authorNickname]';
}
