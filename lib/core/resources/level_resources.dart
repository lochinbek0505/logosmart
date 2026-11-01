import '../storage/level_state.dart';

final RegExp _mediaPath = RegExp(r'\.(webp|png|jpe?g|gif|mp3|wav|ogg|m4a|mp4|webm|json|tflite)$', caseSensitive: false);

/// Level ochilishi uchun kerak bo'ladigan resurs yo'llari: mashq (model, video, ovozlar)
/// va o'yin `jsonConfig` idagi barcha fayl yo'llari.
Set<String> resourcePathsOfLevel(LevelState level) {
  final out = <String>{};
  void add(String? p) {
    if (p != null && p.trim().isNotEmpty && _mediaPath.hasMatch(p.trim())) out.add(p.trim());
  }

  final ex = level.exercise;
  if (ex != null) {
    add(ex.modelPath);
    add(ex.mediaPath);
    add(ex.sound);
    for (final step in ex.steps) {
      add(step.sound);
    }
  }

  void walk(Object? v) {
    if (v is String) {
      add(v);
    } else if (v is Map) {
      v.values.forEach(walk);
    } else if (v is List) {
      v.forEach(walk);
    }
  }

  final game = level.game;
  if (game != null) walk(game.configAsMap());
  return out;
}
