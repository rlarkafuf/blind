import 'package:flutter/foundation.dart';

@immutable
class PollOption {
  final String id;
  final String text;
  final int votes;

  const PollOption({
    required this.id,
    required this.text,
    this.votes = 0,
  });

  PollOption copyWith({
    String? id,
    String? text,
    int? votes,
  }) {
    return PollOption(
      id: id ?? this.id,
      text: text ?? this.text,
      votes: votes ?? this.votes,
    );
  }

  factory PollOption.fromJson(Map<String, dynamic> json) {
    return PollOption(
      id: json['id'] as String,
      text: json['text'] as String,
      votes: (json['votes'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'votes': votes,
    };
  }
}

@immutable
class Poll {
  final String id;
  final String title;
  final List<PollOption> options;

  const Poll({
    required this.id,
    required this.title,
    required this.options,
  });

  Poll copyWith({
    String? id,
    String? title,
    List<PollOption>? options,
  }) {
    return Poll(
      id: id ?? this.id,
      title: title ?? this.title,
      options: options ?? this.options,
    );
  }

  factory Poll.fromJson(Map<String, dynamic> json) {
    return Poll(
      id: json['id'] as String,
      title: (json['title'] as String?) ?? '',
      options: (json['options'] as List<dynamic>)
          .map((e) => PollOption.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'options': options.map((e) => e.toJson()).toList(),
    };
  }
}

/// Represents an anonymous discussion post on Majlis.
@immutable
class Post {
  final String id;
  final String channelId;
  final String userId;
  final String? companyId;
  final String companyNameSnapshot;
  final String authorNickname;
  final String title;
  final String content;
  final int viewCount;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Poll? poll;

  const Post({
    required this.id,
    required this.channelId,
    required this.userId,
    this.companyId,
    required this.companyNameSnapshot,
    required this.authorNickname,
    required this.title,
    required this.content,
    this.viewCount = 0,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
    this.isPinned = false,
    required this.createdAt,
    required this.updatedAt,
    this.poll,
  });

  Post copyWith({
    String? id,
    String? channelId,
    String? userId,
    String? companyId,
    String? companyNameSnapshot,
    String? authorNickname,
    String? title,
    String? content,
    int? viewCount,
    int? likeCount,
    int? commentCount,
    bool? isLiked,
    bool? isPinned,
    DateTime? createdAt,
    DateTime? updatedAt,
    Poll? poll,
  }) {
    return Post(
      id: id ?? this.id,
      channelId: channelId ?? this.channelId,
      userId: userId ?? this.userId,
      companyId: companyId ?? this.companyId,
      companyNameSnapshot: companyNameSnapshot ?? this.companyNameSnapshot,
      authorNickname: authorNickname ?? this.authorNickname,
      title: title ?? this.title,
      content: content ?? this.content,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      poll: poll ?? this.poll,
    );
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      channelId: json['channel_id'] as String,
      userId: json['user_id'] as String,
      companyId: json['company_id'] as String?,
      companyNameSnapshot: json['company_name_snapshot'] as String,
      authorNickname: json['author_nickname'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      viewCount: (json['view_count'] as int?) ?? 0,
      likeCount: (json['like_count'] as int?) ?? 0,
      commentCount: (json['comment_count'] as int?) ?? 0,
      isLiked: (json['is_liked'] as bool?) ?? false,
      isPinned: (json['is_pinned'] as bool?) ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      poll: json['poll'] != null ? Poll.fromJson(json['poll'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'channel_id': channelId,
      'user_id': userId,
      'company_id': companyId,
      'company_name_snapshot': companyNameSnapshot,
      'author_nickname': authorNickname,
      'title': title,
      'content': content,
      'view_count': viewCount,
      'like_count': likeCount,
      'comment_count': commentCount,
      'is_pinned': isPinned,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'poll': poll?.toJson(),
    };
  }

  /// Formatted author badge label: "[회사명 · 닉네임]"
  String get authorBadge => '[$companyNameSnapshot · $authorNickname]';
}
