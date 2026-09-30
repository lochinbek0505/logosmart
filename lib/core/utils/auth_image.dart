import 'package:flutter/material.dart';
import 'package:logosmart/core/network/api_service.dart';
import 'package:logosmart/core/storage/token_storage.dart';

/// `files/{id}/download` kabi rasmlar Authorization talab qiladi (aks holda 403).
/// Token faqat o'z API'mizga yuboriladi.
Map<String, String>? authImageHeaders(String url) {
  final token = TokenStorage().cachedAccessToken;
  if (token == null || !url.startsWith(ApiService().baseUrl)) return null;
  return {'Authorization': 'Bearer $token'};
}

/// NetworkImage + kerak bo'lsa token.
ImageProvider authNetworkImage(String url) =>
    NetworkImage(url, headers: authImageHeaders(url));
