import '../utils/voice_match.dart';

class VoiceDiagnosticService {
  ScoreResult evaluate({
    required String recognizedText,
    required String promptText,
    required String sound,
  }) {
    // Kirill/lotin, apostrof va h/x farqlari tekislanadi; sh, ch, o', g'
    // bitta tovush hisoblanadi (voice_match.dart)
    final recWords = phonemeWords(recognizedText);
    final soundNorm = phonemeWord(sound);

    // 1) promptText dagi so'z aytilgan bo'lsa. Qo'shimcha bilan aytilgani
    // ham qabul qilinadi: "asal" → "asalni"
    for (final word in promptText.split(RegExp(r'\s+'))) {
      final w = phonemeWord(word);
      if (w.isNotEmpty && recWords.any((r) => r.startsWith(w))) {
        return ScoreResult(
          promptText: promptText,
          score: 10,
          matchedWord: word.toLowerCase().replaceAll(RegExp(r'[.,!?;:]'), ''),
          sound: sound,
          matchedSound: true,
        );
      }
    }

    // 2) sound tovushi to'g'ri aytilgan bo'lsa. "S" ni "sh" ichidan,
    // "G" ni "g'" ichidan topib olmaydi
    if (soundNorm.isNotEmpty) {
      for (final recWord in recWords) {
        if (recWord.contains(soundNorm)) {
          return ScoreResult(
            promptText: promptText,
            score: 5,
            matchedWord: promptText,
            sound: sound,
            matchedSound: false,
          );
        }
      }
    }

    return ScoreResult(
      promptText: promptText,
      score: 0,
      matchedWord: null,
      sound: sound,
      matchedSound: false,
    );
  }
}

class ScoreResult {
  final int score;
  final String? matchedWord;
  final String? sound;
  final bool matchedSound;

  /// Bolaga ko'rsatilgan so'z — xato bo'lsa ham (matchedWord null bo'lganda)
  /// natija sahifalarida shu ko'rsatiladi
  final String promptText;

  ScoreResult({
    required this.score,
    required this.matchedWord,
    required this.sound,
    required this.matchedSound,
    this.promptText = '',
  });

  /// Natija sahifalarida ko'rsatiladigan so'z
  String get displayWord => matchedWord ?? promptText;

  @override
  String toString() {
    return 'ScoreResult{score: $score, matchedWord: $matchedWord, promptText: $promptText, sound: $sound, matchedSound: $matchedSound}';
  }
}
