import 'package:intl/intl.dart';

final _somFormat = NumberFormat('#,##0', 'en_US');

/// 49000.0 → "49 000". Backend summalarni BigDecimal (49000.00) qaytaradi,
/// to'g'ridan-to'g'ri chiqarilsa "49000.0" bo'lib ko'rinadi.
String formatSom(num? amount) =>
    _somFormat.format((amount ?? 0).round()).replaceAll(',', ' ');

/// Matn ko'rinishidagi summa ("49000.00") uchun.
String formatSomText(String? amount) => formatSom(num.tryParse(amount ?? ''));
