import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logosmart/core/network/api_service.dart';
import 'package:logosmart/core/service/app_settings.dart';
import 'package:logosmart/core/storage/token_storage.dart';
import 'package:logosmart/firebase_options.dart';
import 'package:logosmart/ui/pages/profile/NotificationPage.dart';
import 'package:logosmart/ui/pages/profile/billings_page.dart';
import 'package:logosmart/ui/pages/profile/providers/notifications_provider.dart';
import 'package:logosmart/ui/pages/profile/subscription_page.dart';

/// Bildirishnoma bosilganda sahifa ochish uchun (MaterialApp ga ulanadi).
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Ilova yopiq yoki fonda bo'lganda keladigan xabarlar.
/// `notification` qismi bor xabarlarni tizimning o'zi ko'rsatadi,
/// faqat data xabarlarni biz ko'rsatamiz.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (message.notification != null) return;
  await AppSettings().load();
  final service = NotificationService();
  await service._initLocalNotifications();
  await service._showLocal(message);
}

/// Push bildirishnomalar (NOTIFICATIONS.md, 2-bo'lim).
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Ovozli va ovozsiz kanallar: Android'da kanal ovozini keyin o'zgartirib bo'lmaydi
  static const _soundChannel = AndroidNotificationChannel(
    'logosmart_default',
    'Bildirishnomalar',
    description: 'LogoSmart bildirishnomalari',
    importance: Importance.high,
  );
  static const _silentChannel = AndroidNotificationChannel(
    'logosmart_silent',
    'Ovozsiz bildirishnomalar',
    description: 'LogoSmart bildirishnomalari (ovozsiz)',
    importance: Importance.high,
    playSound: false,
    enableVibration: false,
  );

  final _messaging = FirebaseMessaging.instance;
  final _local = FlutterLocalNotificationsPlugin();

  static String get _platform => Platform.isIOS ? 'IOS' : 'ANDROID';

  /// main() da runApp dan oldin chaqiriladi.
  Future<void> init() async {
    try {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      await _initLocalNotifications();

      await _applyForegroundOptions();
      AppSettings().addListener(_applyForegroundOptions);

      FirebaseMessaging.onMessage.listen(_onForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen((m) => openFromPush(m.data));
      _messaging.onTokenRefresh.listen(_sendToken);

      // Oldin login qilingan bo'lsa tokenni yangilab qo'yamiz
      await registerToken();
    } catch (e) {
      debugPrint("Bildirishnomalarni sozlashda xato: $e");
    }
  }

  /// Login / register muvaffaqiyatli bo'lgandan keyin va ilova ochilganda.
  /// Token'siz backend 403 qaytaradi, shuning uchun login bo'lmasa hech narsa qilmaydi.
  Future<void> registerToken() async {
    try {
      if (await TokenStorage().getAccessToken() == null) return;
      if (!AppSettings().pushEnabled) return;

      await _messaging.requestPermission(alert: true, badge: true, sound: true);
      final token = await _messaging.getToken();
      debugPrint("FCM token: $token");
      if (token != null) await _sendToken(token);
      NotificationsProvider().refreshUnreadCount();
    } catch (e) {
      debugPrint("FCM tokenni ro'yxatdan o'tkazishda xato: $e");
    }
  }

  Future<void> _sendToken(String token) async {
    if (!AppSettings().pushEnabled) return;
    if (await TokenStorage().getAccessToken() == null) return;
    await ApiService().registerDeviceToken(token, _platform);
  }

  /// Sozlamalardagi "Bildirishnomalar" tugmasi.
  Future<void> setPushEnabled(bool enabled) async {
    await AppSettings().setPushEnabled(enabled);
    try {
      if (enabled) {
        await registerToken();
      } else {
        final token = await _messaging.getToken();
        if (token != null) await ApiService().deleteDeviceToken(token);
      }
    } catch (e) {
      debugPrint("Push sozlamasini o'zgartirishda xato: $e");
    }
  }

  /// Ilova push bosilib ochilgan bo'lsa, birinchi kadrdan keyin chaqiriladi.
  Future<void> handleInitialMessage() async {
    try {
      final message = await _messaging.getInitialMessage();
      if (message != null) {
        openFromPush(message.data);
        return;
      }

      final launch = await _local.getNotificationAppLaunchDetails();
      if (launch?.didNotificationLaunchApp ?? false) {
        _onLocalNotificationTap(launch!.notificationResponse);
      }
    } catch (e) {
      debugPrint("Boshlang'ich bildirishnomani o'qishda xato: $e");
    }
  }

  /// Push yoki ro'yxatdagi bildirishnoma bosilganda `data.screen` bo'yicha ekran ochadi.
  void openFromPush(Map<String, dynamic> data) {
    final id = data['notificationId'];
    if (id is String && id.isNotEmpty) NotificationsProvider().markRead(id);

    final Widget page = switch (data['screen']) {
      'billing' => const BillingsPage(),
      'subscription' => const SubscriptionPage(),
      _ => const NotificationPage(),
    };
    navigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => page));
  }

  Future<void> _initLocalNotifications() async {
    await _local.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/launcher_icon'),
        // Ruxsatni FirebaseMessaging so'raydi
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );
    final android = _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.createNotificationChannel(_soundChannel);
    await android?.createNotificationChannel(_silentChannel);
  }

  void _onLocalNotificationTap(NotificationResponse? response) {
    Map<String, dynamic> data = {};
    final payload = response?.payload;
    if (payload != null && payload.isNotEmpty) {
      try {
        data = Map<String, dynamic>.from(jsonDecode(payload));
      } catch (_) {}
    }
    openFromPush(data);
  }

  // iOS ilova ochiq paytda bildirishnomani o'zi ko'rsatadi, ovozi sozlamaga bog'liq
  Future<void> _applyForegroundOptions() async {
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: AppSettings().notificationSound,
    );
  }

  void _onForegroundMessage(RemoteMessage message) {
    // Android ilova ochiq paytda FCM xabarini ko'rsatmaydi — o'zimiz ko'rsatamiz
    if (Platform.isAndroid || message.notification == null) {
      _showLocal(message);
    }
    // Yangi bildirishnoma bazaga ham yozilgan — ro'yxat va badge'ni yangilaymiz
    NotificationsProvider().refresh();
  }

  Future<void> _showLocal(RemoteMessage message) async {
    final title = message.notification?.title ?? message.data['title'];
    final body = message.notification?.body ?? message.data['body'];
    if (title == null && body == null) return;

    final withSound = AppSettings().notificationSound;
    final channel = withSound ? _soundChannel : _silentChannel;

    await _local.show(
      // ID 32-bit bo'lishi shart
      id:
          (message.messageId ?? DateTime.now().toIso8601String()).hashCode &
          0x7fffffff,
      title: title,
      body: body,
      payload: jsonEncode(message.data),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: Importance.high,
          priority: Priority.high,
          playSound: withSound,
          enableVibration: withSound,
        ),
        iOS: DarwinNotificationDetails(presentSound: withSound),
      ),
    );
  }
}
