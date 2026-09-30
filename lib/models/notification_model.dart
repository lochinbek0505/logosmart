/// GET /notifications ro'yxatidagi bitta bildirishnoma.
class NotificationItem {
  NotificationItem({
    this.id,
    this.type,
    this.title,
    this.body,
    this.data = const {},
    this.read = false,
    this.createdAt,
  });

  String? id;
  String? type;
  String? title;
  String? body;
  Map<String, String> data;
  bool read;
  DateTime? createdAt;

  /// Bosilganda ochiladigan ekran: billing | subscription | null
  String? get screen => data['screen'];

  NotificationItem.fromJson(dynamic json)
    : id = json['id'],
      type = json['type'],
      title = json['title'],
      body = json['body'],
      data =
          (json['data'] as Map?)?.map(
            (k, v) => MapEntry(k.toString(), v.toString()),
          ) ??
          {},
      read = json['read'] ?? false,
      createdAt = DateTime.tryParse(json['createdAt'] ?? '')?.toLocal();
}

/// GET /notifications javobi (sahifalangan).
class NotificationsPageModel {
  NotificationsPageModel({
    this.items = const [],
    this.page = 0,
    this.totalPages = 0,
    this.total = 0,
  });

  List<NotificationItem> items;
  int page;
  int totalPages;
  int total;

  NotificationsPageModel.fromJson(dynamic json)
    : items = (json['items'] as List? ?? [])
          .map((e) => NotificationItem.fromJson(e))
          .toList(),
      page = json['page'] ?? 0,
      totalPages = json['totalPages'] ?? 0,
      total = json['total'] ?? 0;
}
