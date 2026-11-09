import 'package:flutter_test/flutter_test.dart';
import 'package:logosmart/ui/pages/games/widgets/game_fail_dialog.dart';

void main() {
  test("noto'g'ri javoblar — kMaxGameMistakes da o'yin tugaydi", () {
    final a = GameAttempts();
    for (var i = 1; i < kMaxGameMistakes; i++) {
      expect(a.register(counted: true), isFalse);
    }
    expect(a.register(counted: true), isTrue);
  });

  test("faqat eshitilmagan urinishlar (bo'sh STT/xato) ham cheksiz aylanmaydi", () {
    final a = GameAttempts();
    for (var i = 1; i < kMaxUnheardAttempts; i++) {
      expect(a.register(counted: false), isFalse);
    }
    expect(a.register(counted: false), isTrue);
  });

  test("eshitilmaganlar noto'g'ri javoblar chegarasini kamaytirmaydi", () {
    final a = GameAttempts();
    for (var i = 0; i < kMaxUnheardAttempts - 1; i++) {
      a.register(counted: false);
    }
    expect(a.register(counted: true), kMaxGameMistakes == 1);
  });
}
