import 'package:flutter/material.dart';

import '../../../../../core/service/voice_diagnostic_service.dart';
import '../../../../../models/diagnostic_group_model.dart';

class VoiceDiagnosticProvider extends ChangeNotifier {
  final _service = VoiceDiagnosticService();

  int totalScore = 0;
  List<String> errors = [];
  int currentIndex = 0;

  // templates ro‘yxati
  List<Template> templates = [];

  void init(List<Template> list) {
    templates = list;
    totalScore = 0;
    errors = [];
    currentIndex = 0;
    notifyListeners();
  }

  Template? get currentTemplate =>
      currentIndex < templates.length ? templates[currentIndex] : null;

  ScoreResult evaluateSpeech(String recognizedText) {
    final tpl = currentTemplate;
    if (tpl == null || tpl.itemsList == null || tpl.itemsList!.isEmpty) {
      return ScoreResult(score: 0, matchedWord: null, matchedSound: false);
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
}