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
    _sub = _connectivity.onConnectivityChanged.listen((_) {
      // Tarmoq o'zgardi (Wi-Fi <-> mobil, uzildi, qaytdi). connectivity_plus
      // ba'zi qurilmalarda (VPN, almashish paytida) noto'g'ri "none" beradi —
      // unga ishonmasdan server bilan haqiqiy aloqa tekshiriladi
      _lastServerContact = null;
      check(force: true);
    }, onError: (_) {});
  }

  Future<bool>? _checking;

  /// Server oxirgi marta qachon javob bergan (istalgan so'rov)
  DateTime? _lastServerContact;

  /// Shu vaqt ichida server javob bergan bo'lsa qayta "ping" qilinmaydi
  static const Duration _freshContact = Duration(seconds: 30);

  /// Bitta tekshiruv ko'pi bilan shuncha davom etadi (ikki urinish) —
  /// "Internet qidirilmoqda" oynasidagi halqa shu vaqtga to'ladi
  static const Duration _firstPing = Duration(seconds: 5);
  static const Duration _secondPing = Duration(seconds: 7);
  static const Duration maxCheckDuration = Duration(seconds: 14);

  /// Yaqinda server javob bergan — tekshiruv darhol true qaytaradi
  bool get recentlyOnline {
    final last = _lastServerContact;
    return checkOverride == null &&
        last != null &&
        DateTime.now().difference(last) < _freshContact;
  }

  /// Server istalgan so'rovga javob qaytardi (status muhim emas) — internet
  /// bor. ApiService interceptor'i chaqiradi.
  void reportServerContact() {
    _lastServerContact = DateTime.now();
    _set(true);
  }

  /// Server bilan haqiqiy aloqa bormi. Yaqinda server javob bergan bo'lsa
  /// darhol true ([force] — baribir tekshirish). Bir vaqtda bir nechta
  /// chaqirilsa bitta so'rov yuboriladi.
  Future<bool> check({bool force = false}) {
    if (!force && recentlyOnline) {
      return Future.value(true);
    }
    return _checking ??= _doCheck().whenComplete(() => _checking = null);
  }

  Future<bool> _doCheck() async {
    bool ok;
    final override = checkOverride;
    if (override != null) {
      ok = await override();
    } else {
      // Mobil internetda uzoq turgandan keyingi birinchi so'rov (DNS + TLS)
      // sekin bo'ladi — bitta qisqa urinish internet bor paytda ham "yo'q"
      // derdi. Internet umuman yo'q bo'lsa ikkala urinish ham darhol tugaydi
      ok =
          await ApiService().ping(timeout: _firstPing) ||
          await ApiService().ping(timeout: _secondPing);
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
    _lastServerContact = null;
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
