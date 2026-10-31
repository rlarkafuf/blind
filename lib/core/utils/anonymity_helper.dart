import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// Helper for Zero-PII cryptography, anonymous handles, and time formatting.
class AnonymityHelper {
  AnonymityHelper._();

  static const String _defaultSalt = 'MAJLIS_UAE_ZERO_PII_SALT_SECURE_2026';

  /// Computes a one-way irreversible SHA-256 hash of a workplace email.
  /// Plaintext emails are never persisted into databases or log streams.
  static String hashEmail(String email, {String salt = _defaultSalt}) {
    final normalized = email.trim().toLowerCase();
    final bytes = utf8.encode('$normalized:$salt');
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Extracts domain from email (e.g. 'john@samsung.com' -> 'samsung.com')
  static String extractDomain(String email) {
    final parts = email.trim().toLowerCase().split('@');
    if (parts.length == 2) {
      return parts[1];
    }
    return '';
  }

  static const List<String> _prefixes = [
    'Falcon',
    'Dune',
    'Oasis',
    'Burj',
    'Oryx',
    'Ghaf',
    'Pearl',
    'Marina',
    'Palm',
    'Creek',
    'Zayed',
    'Safa',
    'Khor',
    'Jumeirah',
    'Liwa',
  ];

  /// Generates a randomized anonymous handle, e.g. "Falcon-491"
  static String generateAnonymousNickname({Random? random}) {
    final rng = random ?? Random();
    final prefix = _prefixes[rng.nextInt(_prefixes.length)];
    final suffix = 100 + rng.nextInt(900); // 100-999
    return '$prefix-$suffix';
  }

  /// Relative time formatter for feeds and comments
  static String formatRelativeTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inSeconds < 60) {
      return '방금 전';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}분 전';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}시간 전';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}일 전';
    } else {
      return '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')}';
    }
  }
}
