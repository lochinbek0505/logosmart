import 'package:flutter_test/flutter_test.dart';
import 'package:logosmart/core/utils/money_format.dart';
import 'package:logosmart/models/profile_response.dart';

void main() {
  group('formatSom', () {
    test('backend BigDecimal summalari', () {
      expect(formatSom(49000.0), '49 000');
      expect(formatSom(1250000), '1 250 000');
      expect(formatSom(null), '0');
      expect(formatSomText('49000.00'), '49 000');
      expect(formatSomText(null), '0');
      expect(formatSomText('xato'), '0');
    });
  });

  group('ProfileResponse obuna holati', () {
    test('muddati tugagan obuna faol emas (kod qolgan bo\'lsa ham)', () {
      final past = DateTime.now().subtract(const Duration(days: 1));
      final p = ProfileResponse(
        subscriptionCode: 'YEARLY',
        subscriptionExpiresAt: past.toUtc().toIso8601String(),
      );
      expect(p.hasActiveSubscription, isFalse);
    });

    test('kelajakdagi sana — faol', () {
      final future = DateTime.now().add(const Duration(days: 10));
      final p = ProfileResponse(
        subscriptionCode: 'MONTHLY',
        subscriptionExpiresAt: future.toUtc().toIso8601String(),
      );
      expect(p.hasActiveSubscription, isTrue);
      expect(p.subscriptionExpiry, isNotNull);
    });

    test('DEFAULT / sana yo\'q — faol emas', () {
      expect(ProfileResponse(subscriptionCode: 'DEFAULT').hasActiveSubscription, isFalse);
      expect(ProfileResponse(subscriptionExpiresAt: 'xato').hasActiveSubscription, isFalse);
    });
  });
}
