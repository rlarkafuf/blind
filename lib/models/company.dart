import 'package:flutter/material.dart';

/// Represents a verified UAE enterprise, ministry, or generic category.
@immutable
class Company {
  final String id;
  final String domain;
  final String name;
  final String? nameAr;
  final String industry;
  final String iconCode;
  final Color brandColor;
  final bool isVerifiedEntity;

  const Company({
    required this.id,
    required this.domain,
    required this.name,
    this.nameAr,
    required this.industry,
    this.iconCode = 'business',
    this.brandColor = const Color(0xFF00843D),
    this.isVerifiedEntity = true,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] as String,
      domain: json['domain'] as String,
      name: json['name'] as String,
      nameAr: json['name_ar'] as String?,
      industry: json['industry'] as String,
      iconCode: (json['icon_code'] as String?) ?? 'business',
      brandColor: _parseHexColor(json['brand_color'] as String?),
      isVerifiedEntity: (json['is_verified_entity'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'domain': domain,
      'name': name,
      'name_ar': nameAr,
      'industry': industry,
      'icon_code': iconCode,
      'brand_color': '#${brandColor.toARGB32().toRadixString(16).padLeft(8, '0')}',
      'is_verified_entity': isVerifiedEntity,
    };
  }

  static Color _parseHexColor(String? hexString) {
    if (hexString == null || hexString.isEmpty) {
      return const Color(0xFF00843D);
    }
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    try {
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return const Color(0xFF00843D);
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Company && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
