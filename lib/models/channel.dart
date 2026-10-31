import 'package:flutter/material.dart';

/// Represents a topic vertical or lounge channel in Majlis.
@immutable
class Channel {
  final String id;
  final String name;
  final String? nameAr;
  final String description;
  final String iconCode;
  final bool isCompanyRestricted;
  final int sortOrder;

  const Channel({
    required this.id,
    required this.name,
    this.nameAr,
    required this.description,
    required this.iconCode,
    this.isCompanyRestricted = false,
    this.sortOrder = 0,
  });

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      id: json['id'] as String,
      name: json['name'] as String,
      nameAr: json['name_ar'] as String?,
      description: (json['description'] as String?) ?? '',
      iconCode: (json['icon_code'] as String?) ?? 'tag',
      isCompanyRestricted: (json['is_company_restricted'] as bool?) ?? false,
      sortOrder: (json['sort_order'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_ar': nameAr,
      'description': description,
      'icon_code': iconCode,
      'is_company_restricted': isCompanyRestricted,
      'sort_order': sortOrder,
    };
  }

  IconData get iconData {
    switch (iconCode) {
      case 'chat':
        return Icons.chat_bubble_outline_rounded;
      case 'domain':
        return Icons.domain_rounded;
      case 'bolt':
        return Icons.bolt_rounded;
      case 'account_balance':
        return Icons.account_balance_rounded;
      case 'code':
        return Icons.code_rounded;
      case 'apartment':
        return Icons.apartment_rounded;
      case 'payments':
        return Icons.payments_outlined;
      case 'trending_up':
        return Icons.trending_up_rounded;
      default:
        return Icons.tag_rounded;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Channel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
