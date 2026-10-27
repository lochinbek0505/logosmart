import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:logosmart/core/utils/voice_match.dart';

/// Har bir level JSON idagi STT maqsadlari to'g'ri aytilganda qabul qilinishi
/// va rasm topishdagi variantlar bir-biri bilan adashmasligi.
void main() {
  final files = Directory('assets')
      .listSync()
      .whereType<File>()
      .where((f) => RegExp(r'(exsep\w*|games)\.json$').hasMatch(f.path));

  for (final file in files) {
    test(file.path, () {
      final levels = jsonDecode(file.readAsStringSync()) as List;
      for (final level in levels) {
        final game = level['game'];
        if (game == null) continue;
        final config = game['jsonConfig'] as Map<String, dynamic>;
        final where = '${file.path} id=${level['id']} ${game['type']}';

        switch (game['type']) {
          case 'path_game':
            final t = config['target_text'] as String;
            expect(voiceMatches(t, t, lenient: true), isTrue, reason: where);
          case 'arrow':
            for (final n in config['outer_nodes']) {
              final t = n['target_text'] as String;
              expect(voiceMatches(t, t, lenient: true), isTrue, reason: where);
            }
          case 'cloud':
            for (final c in config['clouds']) {
              final t = c['text'] as String;
              expect(voiceMatches(t, t, lenient: true), isTrue, reason: where);
            }
          case 'find_image_page':
            final items = (config['items'] as List).cast<Map>();
            for (final a in items) {
              final said = a['text'] as String;
              expect(voiceMatches(said, said), isTrue, reason: where);
              // a ni aytganda boshqa, undan uzunroq variant mos kelmasligi kerak
              for (final b in items) {
                if (identical(a, b)) continue;
                final other = b['text'] as String;
                final ambiguous = voiceMatches(said, other) &&
                    phonemeWord(other).length >= phonemeWord(said).length;
                expect(ambiguous, isFalse, reason: '$where: "$said" ~ "$other"');
              }
            }
          case 'train_game':
            for (final i in config['items']) {
              final t = i['text'] as String;
              expect(voiceMatches(t, t), isTrue, reason: where);
            }
        }
      }
    });
  }
}
