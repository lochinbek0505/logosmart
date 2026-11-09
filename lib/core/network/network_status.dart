import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import 'api_service.dart';

/// Internet holati. O'yinlar, mashqlar va progress serverda — ularga kirishdan
/// oldin [check] bilan haqiqiy aloqa tekshiriladi (Wi-Fi yoqilgan, lekin
/// internet yo'q holat ham ushlanadi). Aloqa qaytganda tinglovchilar xabardor
/// qilinadi — navbatdagi natijalar shu payt serverga yuboriladi.
class NetworkStatus extends ChangeNotifier {
  NetworkStatus._();

  static final NetworkStatus instance = NetworkStatus._();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _sub;
  bool _started = false;

  bool _online = true;

  /// Oxirgi ma'lum holat (tekshiruvsiz)
  bool get isOnline => _online;

  /// Testlar uchun: serverga so'rov o'rniga shu funksiya chaqiriladi
  @visibleForTesting
  Future<bool> Function()? checkOverride;

  /// Ilova ishga tushganda bir marta (main.dart)
  void start() {
    if (_started) return;
    _started = true;
    _sub = _connectivity.onConnectivityChanged.listen((r) {
      if (r.every((c) => c == ConnectivityResult.none)) {
        _set(false);
      } else {
        // Tarmoq paydo bo'ldi — internet haqiqatan bormi, tekshiramiz
        check();
      }
    }, onError: (_) {});
  }

  Future<bool>? _checking;

  /// Server bilan haqiqiy aloqa bormi. Bir vaqtda bir nechta chaqirilsa
  /// bitta so'rov yuboriladi.
  Future<bool> check() =>
      _checking ??= _doCheck().whenComplete(() => _checking = null);

  Future<bool> _doCheck() async {
    bool ok;
    final override = checkOverride;
    if (override != null) {
      ok = await override();
    } else {
      try {
        final r = await _connectivity.checkConnectivity();
        ok =
            !r.every((c) => c == ConnectivityResult.none) &&
            await ApiService().ping();
      } catch (_) {
        ok = await ApiService().ping();
      }
    }
    _set(ok);
    return ok;
  }

  void _set(bool online) {
    if (_online == online) return;
    _online = online;
    notifyListeners();
  }

  @visibleForTesting
  void resetForTesting() {
    checkOverride = null;
    _online = true;
    _checking = null;
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
