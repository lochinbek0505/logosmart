import 'dart:io';

import 'package:dio/dio.dart';

class UzbekVoiceSttService {
  UzbekVoiceSttService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  static const String _url = 'https://uzbekvoice.ai/api/v1/stt';

  Future<String> transcribe({
    required String audioPath,
    String language = 'uz',
    bool returnOffsets = true,
    bool runDiarization = false,
    bool blocking = true,
  }) async {
    final String apiKey="9a27fcc9-4dd0-45f3-89ab-6655d9e4aee8:5644d06b-6026-44c5-a7d0-e93db71b328f";

    final file = File(audioPath);
    if (!await file.exists()) {
      throw Exception('Audio file not found: $audioPath');
    }

    final form = FormData.fromMap({
      'return_offsets': returnOffsets.toString(),
      'run_diarization': runDiarization.toString(),
      'language': language,
      'blocking': blocking.toString(),
      'file': await MultipartFile.fromFile(
        audioPath,
        filename: file.path.split('/').last,
        contentType: _guessContentType(audioPath),
      ),
    });

    final res = await _dio.post(
      _url,
      data: form,
      options: Options(headers: {'Authorization': apiKey}),
    );

    final data = res.data as Map<String, dynamic>;
    final result = data['result'] as Map<String, dynamic>?;
    return (result?['text'] ?? '').toString();
  }

  static DioMediaType _guessContentType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.wav')) return DioMediaType('audio', 'wav');
    if (lower.endsWith('.m4a')) return DioMediaType('audio', 'mp4');
    return DioMediaType('audio', 'mpeg'); // mp3
  }
}

/// Dio MediaType uchun:
class MediaType {
  final String type;
  final String subtype;

  const MediaType(this.type, this.subtype);

  @override
  String toString() => '$type/$subtype';
}
