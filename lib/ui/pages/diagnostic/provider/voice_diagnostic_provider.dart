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

  // templates ro‘yxati
  List<Template> templates = [];
  List<ScoreResult> scores = [];

  void init(List<Template> list) {
    templates = list;
    totalScore = 0;
    errors = [];
    scores = [];
    currentIndex = 0;
    notifyListeners();
  }

  Template? get currentTemplate =>
      currentIndex < templates.length ? templates[currentIndex] : null;

  /// Bajarilgan topshiriqlar ulushi (0..1) — progress bar uchun
  double get progress =>
      templates.isEmpty ? 0 : scores.length / templates.length;

  /// Har bir topshiriq uchun eng yuqori ball
  static const int maxItemScore = 10;

  ScoreResult evaluateSpeech(String recognizedText) {
    final tpl = currentTemplate;
    if (tpl == null || tpl.itemsList == null || tpl.itemsList!.isEmpty) {
      return ScoreResult(
        score: 0,
        matchedWord: null,
        sound: "",
        matchedSound: false,
      );
    }

    final item = tpl.itemsList!.first;
    final res = _service.evaluate(
      recognizedText: recognizedText,
      promptText: item.promptText ?? "",
      sound: item.sound ?? "",
    );

    if (res.score == 0) {
      errors.add("${item.sound} tovushi noto‘g‘ri");
    } else {
      totalScore += res.score;
    }
    scores.add(res);

    notifyListeners();
    return res;
  }

  bool next() {
    if (currentIndex < templates.length - 1) {
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

    List<Map<String, dynamic>> sounds = [];

    for (var value in scores) {
      sounds.add({
        "sound": value.sound,
        "percent": value.score * 100 ~/ maxItemScore,
        "note": value.matchedSound
            ? "Tovush to‘g‘ri aytilgan"
            : (value.matchedWord != null
                  ? "Tovush noto‘g‘ri, lekin so‘zda qatnashgan"
                  : "Tovush noto‘g‘ri"),
      });
    }

    data["sounds"] = sounds;

    try {
      await _apiService.submitDiagnostic(context, data);
    } catch (e) {
      debugPrint("Natijalarni yuborishda xato: $e");
    }
  }
}
