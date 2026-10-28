import 'package:flutter/material.dart';
import 'package:logosmart/core/network/api_service.dart';

import '../../../../../core/service/voice_diagnostic_service.dart';
import '../../../../../models/diagnostic_group_model.dart';

class VoiceDiagnosticProvider extends ChangeNotifier {
  final _service = VoiceDiagnosticService();
  final _apiService = ApiService();
  int totalScore = 0;
  List<String> errors = [];
  int currentIndex = 0;

  // Faol shablonlardagi barcha topshiriqlar, orderNo bo'yicha tartiblangan
  List<TemplateItem> items = [];
  List<ScoreResult> scores = [];

  void init(List<Template> list) {
    items = [
      for (final t in list)
        if (t.active != false) ...?t.itemsList,
    ]..sort((a, b) => (a.orderNo ?? 0).compareTo(b.orderNo ?? 0));
    totalScore = 0;
    errors = [];
    scores = [];
    currentIndex = 0;
    notifyListeners();
  }

  TemplateItem? get currentItem =>
      currentIndex < items.length ? items[currentIndex] : null;

  /// Bajarilgan topshiriqlar ulushi (0..1) — progress bar uchun
  double get progress => items.isEmpty ? 0 : scores.length / items.length;

  /// Admin panel "k", "SH" kabi yozishi mumkin — "K", "Sh" ko'rinishiga keltiramiz
  static String normalizeSound(String? sound) {
    final s = sound?.trim() ?? "";
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  /// Har bir topshiriq uchun eng yuqori ball
  static const int maxItemScore = 10;

  ScoreResult evaluateSpeech(String recognizedText) {
    final item = currentItem;
    if (item == null) {
      return ScoreResult(
        score: 0,
        matchedWord: null,
        sound: "",
        matchedSound: false,
      );
    }

    final sound = normalizeSound(item.sound);
    final res = _service.evaluate(
      recognizedText: recognizedText,
      promptText: item.promptText ?? "",
      sound: sound,
    );

    if (res.score == 0) {
      errors.add("$sound tovushi noto‘g‘ri");
    } else {
      totalScore += res.score;
    }
    scores.add(res);

    notifyListeners();
    return res;
  }

  bool next() {
    if (currentIndex < items.length - 1) {
      currentIndex++;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> submitResults(context) async {
    // Backend foiz kutadi: ballar (0, 5, 10) 100 ga nisbatan hisoblanadi
    final maxTotal = scores.length * maxItemScore;
    Map<String, dynamic> data = {
      "totalPercent": maxTotal == 0 ? 0 : (totalScore * 100 / maxTotal).round(),
    };

    // "sounds": [
    // {"sound": "string", "percent": 100, "note": "string"},
    // ],

    // Har bir tovush bir nechta so'z bilan tekshiriladi — tovush bo'yicha jamlaymiz
    final bySound = <String, List<ScoreResult>>{};
    for (var value in scores) {
      bySound.putIfAbsent(value.sound ?? "", () => []).add(value);
    }

    List<Map<String, dynamic>> sounds = [];

    bySound.forEach((sound, results) {
      final sum = results.fold<int>(0, (a, r) => a + r.score);
      final correct = results.where((r) => r.matchedSound).length;
      sounds.add({
        "sound": sound,
        "percent": (sum * 100 / (results.length * maxItemScore)).round(),
        "note": correct == results.length
            ? "Tovush to‘g‘ri aytilgan"
            : "${results.length} ta so‘zdan $correct tasida to‘g‘ri aytilgan",
      });
    });

    data["sounds"] = sounds;

    try {
      await _apiService.submitDiagnostic(context, data);
    } catch (e) {
      debugPrint("Natijalarni yuborishda xato: $e");
    }
  }
}
