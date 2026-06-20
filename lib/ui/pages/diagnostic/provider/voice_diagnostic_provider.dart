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

  void scoreInit() {
    scores = [
      ScoreResult(
        score: 10,
        matchedWord: "asal",
        sound: "S",
        matchedSound: true,
      ),
      ScoreResult(
        score: 5,
        matchedWord: "sabzi",
        sound: "S",
        matchedSound: false,
      ),
    ];
  }

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
    Map<String, dynamic> data = {"totalPercent": totalScore};

    // "sounds": [
    // {"sound": "string", "percent": 100, "note": "string"},
    // ],

    List<Map<String, dynamic>> sounds = [];

    for (var value in scores) {
      sounds.add({
        "sound": value.sound,
        "percent": value.score, // 0, 5, 10 ni 100 ga nisbatan
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
