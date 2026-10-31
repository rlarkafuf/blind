import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// Helper for Zero-PII cryptography, UAE-themed anonymous handles, and time formatting.
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

  /// Extracts domain from email (e.g. 'john@adnoc.ae' -> 'adnoc.ae')
  static String extractDomain(String email) {
    final parts = email.trim().toLowerCase().split('@');
    if (parts.length == 2) {
      return parts[1];
    }
    return '';
  }

  static const List<String> _uaePrefixes = [
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

  /// Generates a randomized UAE-themed anonymous handle, e.g. "Falcon-491"
  static String generateAnonymousNickname({Random? random}) {
    final rng = random ?? Random();
    final prefix = _uaePrefixes[rng.nextInt(_uaePrefixes.length)];
    final suffix = 100 + rng.nextInt(900); // 100-999
    return '$prefix-$suffix';
  }

  /// Relative time formatter for feeds and comments
  static String formatRelativeTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inSeconds < 60) {
      return 'just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
