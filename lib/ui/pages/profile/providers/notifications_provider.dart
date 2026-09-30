import 'package:flutter/material.dart';
import 'package:logosmart/models/notification_model.dart';

import '../../../../core/network/api_service.dart';

/// Ilova ichidagi bildirishnomalar ro'yxati va o'qilmaganlar soni.
/// Push kelganda NotificationService ham shu obyektni yangilaydi.
class NotificationsProvider with ChangeNotifier {
  static final NotificationsProvider _instance =
      NotificationsProvider._internal();
  factory NotificationsProvider() => _instance;
  NotificationsProvider._internal();

  static const _pageSize = 20;

  final List<NotificationItem> _items = [];
  List<NotificationItem> get items => List.unmodifiable(_items);

  int _unreadCount = 0;
  int get unreadCount => _unreadCount;

  bool isLoading = false;
  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  int _page = 0;
  int _totalPages = 0;
  bool get hasMore => _page + 1 < _totalPages;

  /// Birinchi sahifani qayta yuklash (sahifa ochilganda / pastga tortilganda).
  Future<void> refresh() async {
    isLoading = _items.isEmpty;
    notifyListeners();
    final result = await ApiService().getNotifications(size: _pageSize);
    if (result != null) {
      _items
        ..clear()
        ..addAll(result.items);
      _page = result.page;
      _totalPages = result.totalPages;
    }
    isLoading = false;
    notifyListeners();
    await refreshUnreadCount();
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !hasMore) return;
    _isLoadingMore = true;
    notifyListeners();
    final result = await ApiService().getNotifications(
      page: _page + 1,
      size: _pageSize,
    );
    if (result != null) {
      _items.addAll(result.items);
      _page = result.page;
      _totalPages = result.totalPages;
    }
    _isLoadingMore = false;
    notifyListeners();
  }

  Future<void> refreshUnreadCount() async {
    final count = await ApiService().getUnreadNotificationsCount();
    if (count != null && count != _unreadCount) {
      _unreadCount = count;
      notifyListeners();
    }
  }

  /// Ro'yxatdagi yoki push'dagi bitta bildirishnomani o'qildi qilish.
  Future<void> markRead(String id) async {
    final item = _items.where((e) => e.id == id).firstOrNull;
    if (item != null && !item.read) {
      item.read = true;
      if (_unreadCount > 0) _unreadCount--;
      notifyListeners();
    }
    await ApiService().markNotificationRead(id);
    if (item == null) await refreshUnreadCount();
  }

  Future<void> markAllRead() async {
    for (final item in _items) {
      item.read = true;
    }
    _unreadCount = 0;
    notifyListeners();
    await ApiService().markAllNotificationsRead();
  }

  /// Logout / akkaunt o'chirilganda.
  void clear() {
    _items.clear();
    _unreadCount = 0;
    _page = 0;
    _totalPages = 0;
    notifyListeners();
  }
}
