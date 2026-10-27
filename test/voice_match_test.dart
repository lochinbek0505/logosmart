import 'package:flutter_test/flutter_test.dart';
import 'package:logosmart/core/service/voice_diagnostic_service.dart';
import 'package:logosmart/core/utils/voice_match.dart';

void main() {
  group('lenient (tovush taqlidi: chiziqli, strelka, bulut)', () {
    test("STT qo'shgan unlilar e'tiborga olinmaydi", () {
      expect(voiceMatches('dardardar', 'Drrr', lenient: true), isTrue);
      expect(voiceMatches('tır tır', 'Trrr', lenient: true), isTrue);
      expect(voiceMatches('Rarara', 'Rrra', lenient: true), isTrue);
      expect(voiceMatches('ogog', 'Ooog', lenient: true), isTrue);
      expect(voiceMatches('ishish', 'Shsh', lenient: true), isTrue);
    });

    test('kirill va turkcha harflar', () {
      expect(voiceMatches('дррр', 'Drrr', lenient: true), isTrue);
      expect(voiceMatches('шшш', 'Shsh', lenient: true), isTrue);
      expect(voiceMatches('şşş', 'Shsh', lenient: true), isTrue);
    });

    test("apostrof turlari va o'/o farq qilmaydi", () {
      expect(voiceMatches('oʻr', 'oorr', lenient: true), isTrue);
      expect(voiceMatches("o'r", 'oorr', lenient: true), isTrue);
      expect(voiceMatches('or', "o'r", lenient: true), isTrue);
    });

    test('noto\'g\'ri tovush qabul qilinmaydi', () {
      expect(voiceMatches('dla', 'Drrr', lenient: true), isFalse);
      expect(voiceMatches('dadada', 'Drrr', lenient: true), isFalse);
      expect(voiceMatches('ak', 'Aaag', lenient: true), isFalse);
      // sh, s o'rnida emas; g' — g emas
      expect(voiceMatches('shshsh', 'Ssss', lenient: true), isFalse);
      expect(voiceMatches('ashash', 'Asss', lenient: true), isFalse);
      expect(voiceMatches("g'g'g'", 'Gggg', lenient: true), isFalse);
      expect(voiceMatches('ғаға', 'Ggga', lenient: true), isFalse);
      expect(voiceMatches('chchch', 'Shsh', lenient: true), isFalse);
    });
  });

  group("strict (so'zlar: rasm topish, poyezd)", () {
    test("so'z aytilishi kerak", () {
      expect(voiceMatches('Gilam.', 'gilam'), isTrue);
      expect(voiceMatches('gilamni', 'gilam'), isTrue);
      expect(voiceMatches('gulam', 'gilam'), isFalse);
    });

    test('yozuv farqlari', () {
      expect(voiceMatches('oʻt', "o't"), isTrue);
      expect(voiceMatches('o‘t', "o't"), isTrue);
      expect(voiceMatches('timsox', 'timsoh'), isTrue);
      expect(voiceMatches('гилам', 'gilam'), isTrue);
      expect(voiceMatches('ўт', "o't"), isTrue);
    });

    test("o' va o, sh va s farqlanadi", () {
      expect(voiceMatches('ot', "o't"), isFalse);
      expect(voiceMatches('shabzi', 'sabzi'), isFalse);
      expect(voiceMatches('dardardar', 'Drrr'), isFalse);
    });
  });

  test("bo'sh javob", () {
    expect(isEmptyTranscript(''), isTrue);
    expect(isEmptyTranscript(' . '), isTrue);
    expect(isEmptyTranscript('ss'), isFalse);
  });

  group('diagnostika', () {
    final service = VoiceDiagnosticService();

    test("so'z qo'shimcha bilan va kirillda", () {
      expect(service.evaluate(recognizedText: 'Asalni', promptText: 'asal', sound: 'S').score, 10);
      expect(service.evaluate(recognizedText: 'асал', promptText: 'asal', sound: 'S').score, 10);
    });

    test('tovush digraf ichidan topilmaydi', () {
      expect(service.evaluate(recognizedText: 'shabji', promptText: 'sabzi', sound: 'S').score, 0);
      expect(service.evaluate(recognizedText: 'sabji', promptText: 'sabzi', sound: 'S').score, 5);
      expect(service.evaluate(recognizedText: 'shapka', promptText: 'shar', sound: 'Sh').score, 5);
    });

    test("xato javobda ham ko'rsatiladigan so'z bor", () {
      final res = service.evaluate(recognizedText: 'tabzi', promptText: 'sabzi', sound: 'S');
      expect(res.score, 0);
      expect(res.matchedWord, isNull);
      expect(res.displayWord, 'sabzi');
    });
  });
}
