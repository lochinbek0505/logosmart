import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/service/uzbekvoice_stt_service.dart';

class AudioDiagnosticService {
  final AudioPlayer _mainPlayer = AudioPlayer();
  final AudioPlayer _effectPlayer = AudioPlayer();
  final AudioRecorder _recorder = AudioRecorder();
  final UzbekVoiceSttService _sttService = UzbekVoiceSttService();

  StreamSubscription<Amplitude>? _ampSub;

  Future<void> playObjectSound(String soundPath, VoidCallback onComplete) async {
    final sub = _mainPlayer.onPlayerComplete.listen((_) {});
    sub.onData((_) {
      onComplete();
      sub.cancel(); // Memory leak'ni oldini olish uchun
    });

    if (soundPath.startsWith('http')) {
      await _mainPlayer.play(UrlSource(soundPath));
    } else {
      await _mainPlayer.play(AssetSource(soundPath));
    }
  }

  /// Maxsus effektlarni (muvaffaqiyat, xatolik, mikrofon yoqilishi) chalish uchun
  Future<void> playEffect(String assetPath) async {
    await _effectPlayer.play(AssetSource(assetPath));
  }

  /// Mikrofonni avtomatik yoqish va ovoz balandligini (amplitude) uzatish
  Future<bool> startRecording({required Function(double) onAmplitudeChanged}) async {
    final mic = await Permission.microphone.request();
    if (!mic.isGranted) return false;

    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/record_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: path,
    );

    _ampSub = _recorder.onAmplitudeChanged(const Duration(milliseconds: 120)).listen((amp) {
      onAmplitudeChanged(amp.current);
    });

    return true;
  }

  /// Yozishni to'xtatish va STT orqali matnga o'girish
  Future<String?> stopAndTranscribe() async {
    await _ampSub?.cancel();
    final path = await _recorder.stop();

    if (path != null && File(path).existsSync()) {
      return await _sttService.transcribe(audioPath: path);
    }
    return null;
  }

  void dispose() {
    _ampSub?.cancel();
    _mainPlayer.dispose();
    _effectPlayer.dispose();
    _recorder.dispose();
  }
}