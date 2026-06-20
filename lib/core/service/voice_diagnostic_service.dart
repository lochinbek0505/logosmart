import 'dart:math';

class VoiceDiagnosticService {

  ScoreResult evaluate({
    required String recognizedText,
    required String promptText,
    required String sound,
  }) {
    final recNorm = _normalize(recognizedText);
    // Recognized so'zlarni asliga ziyon yetkazmasdan massivga ajratamiz
    final recWords = recNorm.split(' ').where((e) => e.isNotEmpty).toList();

    final promptWords = _normalize(promptText).split(' ').where((e) => e.isNotEmpty).toList();
    final soundNorm = _normalize(sound);

    // 1) promptText dagi so‘zlardan bittasi 100% TO'LIQ mos kelsa
    for (final w in promptWords) {
      if (recWords.contains(w)) {
        return ScoreResult(
          score: 10,
          matchedWord: w,
          sound: sound,
          matchedSound: true,
        );
      }
    }

    // 2) sound harfi to‘g‘ri aytilgan bo‘lsa
    // Bola aytgan so'zlar ichidan soundNorm qatnashgan birinchi so'zni qidiramiz
    if (soundNorm.isNotEmpty) {
      for (final recWord in recWords) {
        if (recWord.contains(soundNorm)) {
          return ScoreResult(
            score: 5,
            // Mos kelgan to'liq so'zni qaytaramiz
            matchedWord: promptText,
            sound: sound,
            matchedSound: false,
          );
        }
      }
    }

    return ScoreResult(
      score: 0,
      matchedWord: null,
      sound: sound,
      matchedSound: false,
    );
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
  final String? sound;
  final bool matchedSound;

  ScoreResult({
    required this.score,
    required this.matchedWord,
    required this.sound,
    required this.matchedSound,
  });

  @override
  String toString() {
    return 'ScoreResult{score: $score, matchedWord: $matchedWord, sound: $sound, matchedSound: $matchedSound}';
  }


}