import 'package:flutter/material.dart';
import '../../../models/company.dart';

/// Repository managing Korean company directory and domain verification matching.
class CompanyRepository {
  static final Company defaultGeneralCompany = Company(
    id: 'comp-general',
    domain: 'general',
    name: '새회사',
    industry: '스타트업 / 기타',
    iconCode: 'public',
    brandColor: const Color(0xFF64748B),
    isVerifiedEntity: false,
  );

  static final List<Company> defaultCompanies = [
    const Company(
      id: 'comp-samsung',
      domain: 'samsung.com',
      name: '삼성전자',
      industry: 'IT/전자',
      iconCode: 'bolt',
      brandColor: Color(0xFF1428A0),
      isVerifiedEntity: true,
    ),
    const Company(
      id: 'comp-sk',
      domain: 'sk.com',
      name: 'SK하이닉스',
      industry: '반도체',
      iconCode: 'bolt',
      brandColor: Color(0xFFE3000F),
      isVerifiedEntity: true,
    ),
    const Company(
      id: 'comp-skhynix',
      domain: 'skhynix.com',
      name: 'SK하이닉스',
      industry: '반도체',
      iconCode: 'bolt',
      brandColor: Color(0xFFE3000F),
      isVerifiedEntity: true,
    ),
    const Company(
      id: 'comp-hyundai',
      domain: 'hyundai.com',
      name: '현대자동차',
      industry: '자동차/제조',
      iconCode: 'directions_car',
      brandColor: Color(0xFF002C5F),
      isVerifiedEntity: true,
    ),
    const Company(
      id: 'comp-naver',
      domain: 'navercorp.com',
      name: '네이버',
      industry: 'IT/인터넷',
      iconCode: 'language',
      brandColor: Color(0xFF03C75A),
      isVerifiedEntity: true,
    ),
    const Company(
      id: 'comp-kakao',
      domain: 'kakaocorp.com',
      name: '카카오',
      industry: 'IT/인터넷',
      iconCode: 'chat_bubble',
      brandColor: Color(0xFFFEE500),
      isVerifiedEntity: true,
    ),
    const Company(
      id: 'comp-coupang',
      domain: 'coupang.com',
      name: '쿠팡',
      industry: '이커머스',
      iconCode: 'shopping_cart',
      brandColor: Color(0xFFEA0029),
      isVerifiedEntity: true,
    ),
    const Company(
      id: 'comp-toss',
      domain: 'toss.im',
      name: '토스',
      industry: '금융/핀테크',
      iconCode: 'payments',
      brandColor: Color(0xFF0050FF),
      isVerifiedEntity: true,
    ),
    const Company(
      id: 'comp-daangn',
      domain: 'daangn.com',
      name: '당근',
      industry: 'IT/인터넷',
      iconCode: 'storefront',
      brandColor: Color(0xFFFF7E36),
      isVerifiedEntity: true,
    ),
    const Company(
      id: 'comp-woowahan',
      domain: 'woowahan.com',
      name: '배달의민족',
      industry: 'IT/인터넷',
      iconCode: 'delivery_dining',
      brandColor: Color(0xFF2AC1BC),
      isVerifiedEntity: true,
    ),
    const Company(
      id: 'comp-lge',
      domain: 'lge.com',
      name: 'LG전자',
      industry: 'IT/전자',
      iconCode: 'tv',
      brandColor: Color(0xFFA50034),
      isVerifiedEntity: true,
    ),
  ];

  /// Resolves an email address to a verified Korean enterprise.
  /// If unknown or generic (gmail, yahoo), returns defaultGeneralCompany.
  Company resolveCompanyByEmail(String email) {
    final lower = email.trim().toLowerCase();
    final parts = lower.split('@');
    if (parts.length != 2) return defaultGeneralCompany;
    final domain = parts[1];

    for (final company in defaultCompanies) {
      if (company.domain.toLowerCase() == domain) {
        return company;
      }
    }
    return defaultGeneralCompany;
  }

  List<Company> getAllCompanies() => defaultCompanies;
}
