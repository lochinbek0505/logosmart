import 'dart:math';

class VoiceDiagnosticService {
  // promptText ichidagi so‘zlardan biri 100% mos kelsa -> 10 ball
  // bo‘lmasa, lekin sound (harf) to‘g‘ri aytilgan bo‘lsa -> 5 ball
  // aks holda 0
  ScoreResult evaluate({
    required String recognizedText,
    required String promptText,
    required String sound,
  }) {
    final rec = _normalize(recognizedText);
    final promptWords = _normalize(promptText).split(' ').where((e) => e.isNotEmpty).toList();
    final soundNorm = _normalize(sound);

    // 1) promptText dagi so‘zlardan bittasi 100% mos kelsa
    for (final w in promptWords) {
      if (rec.contains(w)) {
        return ScoreResult(score: 10, matchedWord: w, matchedSound: false);
      }
    }

    // 2) sound harfi to‘g‘ri aytilgan bo‘lsa (so‘z ichida uchrashi)
    if (soundNorm.isNotEmpty && rec.contains(soundNorm)) {
      return ScoreResult(score: 5, matchedWord: null, matchedSound: true);
    }

    return ScoreResult(score: 0, matchedWord: null, matchedSound: false);
  }

  String _normalize(String t) {
    return t
        .toLowerCase()
        .replaceAll(RegExp(r"[’`ʻʼ]"), "'")
        .replaceAll(RegExp(r"[^a-zа-яёҳқғў0-9'\s]"), " ")
        .replaceAll(RegExp(r"\s+"), " ")
        .trim();
  }
}

class ScoreResult {
  final int score;
  final String? matchedWord;
  final bool matchedSound;

  ScoreResult({
    required this.score,
    required this.matchedWord,
    required this.matchedSound,
  });
}