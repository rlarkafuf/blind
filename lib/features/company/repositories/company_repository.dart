import 'package:flutter/material.dart';
import '../../../models/company.dart';

/// Repository managing UAE company directory and domain verification matching.
class CompanyRepository {
  static final Company defaultGeneralCompany = Company(
    id: 'comp-general',
    domain: 'general',
    name: 'General / Job Seeker',
    nameAr: 'عام / باحث عن عمل',
    industry: 'General & Other',
    iconCode: 'public',
    brandColor: const Color(0xFF64748B),
    isVerifiedEntity: false,
  );

  static final List<Company> defaultCompanies = [
    const Company(
      id: 'comp-adnoc',
      domain: 'adnoc.ae',
      name: 'ADNOC',
      nameAr: 'أدنوك',
      industry: 'Energy & Nuclear',
      iconCode: 'bolt',
      brandColor: Color(0xFF0072CE),
      isVerifiedEntity: true,
    ),
    const Company(
      id: 'comp-eand',
      domain: 'eand.com',
      name: 'e& (Etisalat)',
      nameAr: 'اتصالات',
      industry: 'Tech & AI',
      iconCode: 'code',
      brandColor: Color(0xFFE30613),
      isVerifiedEntity: true,
    ),
    const Company(
      id: 'comp-emirates',
      domain: 'emirates.com',
      name: 'Emirates Airline',
      nameAr: 'طيران الإمارات',
      industry: 'Aviation & Logistics',
      iconCode: 'flight',
      brandColor: Color(0xFFD71921),
      isVerifiedEntity: true,
    ),
    const Company(
      id: 'comp-enec',
      domain: 'enec.gov.ae',
      name: 'ENEC (Barakah Nuclear)',
      nameAr: 'مؤسسة الإمارات للطاقة النووية',
      industry: 'Energy & Nuclear',
      iconCode: 'bolt',
      brandColor: Color(0xFF007A33),
      isVerifiedEntity: true,
    ),
    const Company(
      id: 'comp-fab',
      domain: 'fab.ae',
      name: 'FAB (First Abu Dhabi Bank)',
      nameAr: 'بنك أبوظبي الأول',
      industry: 'Banking & Finance',
      iconCode: 'account_balance',
      brandColor: Color(0xFF002D62),
      isVerifiedEntity: true,
    ),
    const Company(
      id: 'comp-enbd',
      domain: 'emiratesnbd.com',
      name: 'Emirates NBD',
      nameAr: 'بنك الإمارات دبي الوطني',
      industry: 'Banking & Finance',
      iconCode: 'account_balance',
      brandColor: Color(0xFF002B49),
      isVerifiedEntity: true,
    ),
    const Company(
      id: 'comp-mubadala',
      domain: 'mubadala.ae',
      name: 'Mubadala Investment Co.',
      nameAr: 'مبادلة للاستثمار',
      industry: 'Sovereign Wealth & Investment',
      iconCode: 'trending_up',
      brandColor: Color(0xFF007C92),
      isVerifiedEntity: true,
    ),
    const Company(
      id: 'comp-adia',
      domain: 'adia.ae',
      name: 'ADIA (Abu Dhabi Inv. Auth.)',
      nameAr: 'جهاز أبوظبي للاستثمار',
      industry: 'Sovereign Wealth & Investment',
      iconCode: 'trending_up',
      brandColor: Color(0xFF8C734B),
      isVerifiedEntity: true,
    ),
    const Company(
      id: 'comp-dewa',
      domain: 'dewa.gov.ae',
      name: 'DEWA',
      nameAr: 'هيئة كهرباء ومياه دبي',
      industry: 'Energy & Nuclear',
      iconCode: 'bolt',
      brandColor: Color(0xFF00953B),
      isVerifiedEntity: true,
    ),
    const Company(
      id: 'comp-emaar',
      domain: 'emaar.ae',
      name: 'Emaar Properties',
      nameAr: 'إعمار العقارية',
      industry: 'Real Estate & Living',
      iconCode: 'apartment',
      brandColor: Color(0xFFD4AF37),
      isVerifiedEntity: true,
    ),
    const Company(
      id: 'comp-careem',
      domain: 'careem.com',
      name: 'Careem',
      nameAr: 'كريم',
      industry: 'Tech & AI',
      iconCode: 'code',
      brandColor: Color(0xFF00B140),
      isVerifiedEntity: true,
    ),
    const Company(
      id: 'comp-talabat',
      domain: 'talabat.com',
      name: 'Talabat',
      nameAr: 'طلبات',
      industry: 'Tech & AI',
      iconCode: 'code',
      brandColor: Color(0xFFFF5A00),
      isVerifiedEntity: true,
    ),
    const Company(
      id: 'comp-masdar',
      domain: 'masdar.ae',
      name: 'Masdar Clean Energy',
      nameAr: 'مصدر للطاقة النظيفة',
      industry: 'Energy & Nuclear',
      iconCode: 'bolt',
      brandColor: Color(0xFF78BE20),
      isVerifiedEntity: true,
    ),
  ];

  /// Resolves an email address to a verified UAE enterprise.
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
