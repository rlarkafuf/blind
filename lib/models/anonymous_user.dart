import 'package:flutter/foundation.dart';
import 'company.dart';

/// Represents a verified anonymous professional profile (Zero-PII).
@immutable
class AnonymousUser {
  final String id;
  final String emailHash; // One-way SHA-256 hash
  final Company company;
  final String nickname; // e.g. 'Falcon-842'
  final DateTime createdAt;

  const AnonymousUser({
    required this.id,
    required this.emailHash,
    required this.company,
    required this.nickname,
    required this.createdAt,
  });

  factory AnonymousUser.fromJson(Map<String, dynamic> json, Company company) {
    return AnonymousUser(
      id: json['id'] as String,
      emailHash: json['email_hash'] as String,
      company: company,
      nickname: json['nickname_prefix'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email_hash': emailHash,
      'company_id': company.id,
      'nickname_prefix': nickname,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Badge preview text e.g. "[삼성전자 · 직급(선택)]"
  String get badgeLabel => '[${company.name} · $nickname]';
}
