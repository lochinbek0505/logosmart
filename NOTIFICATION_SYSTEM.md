# Notification tizimi (KPI SamDU RTTM)

Bu hujjat ilovadagi bildirishnoma (push notification) tizimi qanday ishlashini va uni boshqa Flutter loyihalarga qanday ko'chirishni tushuntiradi.

## 1. Umumiy arxitektura

```
Backend (server)
   │  1) FCM token saqlaydi:  POST users/{id}/register-notification/
   │  2) Hodisa bo'lganda FCM orqali push yuboradi
   │  3) Bildirishnomalar tarixini saqlaydi:  GET notifications/
   ▼
Firebase Cloud Messaging (FCM)
   ▼
Flutter ilova
   ├─ notification_bootstrap.dart   → FCM + local notification sozlash, xabarni ko'rsatish
   ├─ NotificationGuard.dart        → bildirishnoma ruxsati o'chiq bo'lsa ilovani bloklash
   ├─ NotificationBlockedGate.dart  → ilovaning root widgeti ustidagi "darvoza"
   ├─ NotificationVolumeService     → (Android native) kanal ovozi o'zgartirilganini tekshirish
   ├─ NotificationProvider          → server'dagi bildirishnomalar ro'yxati, o'qilgan/o'qilmagan
   ├─ NotificationBellBadge         → AppBar'dagi qo'ng'iroqcha + o'qilmaganlar soni
   └─ NotificationPage              → bildirishnomalar ro'yxati sahifasi
```

Tizim ikki qismdan iborat:

1. **Push notification** — FCM orqali real vaqtda keladi, telefon ekranida ko'rinadi (maxsus ovoz bilan).
2. **Ichki bildirishnomalar ro'yxati** — backend'dagi `notifications/` API orqali olinadi, ilova ichida qo'ng'iroqcha va sahifada ko'rsatiladi.

## 2. Paketlar

`pubspec.yaml`:

```yaml
dependencies:
  firebase_core: ^4.6.0
  firebase_messaging: ^16.1.3
  flutter_local_notifications: ^21.0.0
  permission_handler: ^12.0.1   # sozlamalarni ochish uchun (openAppSettings)
  provider: ^6.1.5+1
  dio: ^5.9.0
```

> `awesome_notifications` va `volume_controller` pubspec'da bor, lekin kodda ishlatilmaydi — yangi loyihaga qo'shish shart emas.

## 3. Firebase sozlash

1. Firebase Console'da loyiha yarating, Android (va kerak bo'lsa iOS) ilovani qo'shing.
2. `flutterfire configure` → `lib/firebase_options.dart` hosil bo'ladi.
3. `android/app/google-services.json` va `ios/Runner/GoogleService-Info.plist` fayllarini joylang.
4. Gradle:

```kotlin
// android/settings.gradle.kts
plugins {
    id("com.google.gms.google-services") version("4.3.15") apply false
}

// android/app/build.gradle.kts
plugins {
    id("com.google.gms.google-services")
}
android {
    compileOptions {
        isCoreLibraryDesugaringEnabled = true   // flutter_local_notifications uchun shart
    }
}
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
```

## 4. Android sozlamalari

### 4.1 Maxsus ovoz

Ovoz fayli: `android/app/src/main/res/raw/kpi_notification.mp3`.
Kodda kengaytmasiz nom bilan chaqiriladi: `RawResourceAndroidNotificationSound('kpi_notification')`.

> Release build'da R8 fayl nomini o'chirib yubormasligi uchun `res/raw/keep.xml` qo'shish tavsiya etiladi:
> ```xml
> <resources xmlns:tools="http://schemas.android.com/tools"
>     tools:keep="@raw/kpi_notification" />
> ```

### 4.2 AndroidManifest.xml

`<application>` ichida FCM default kanali (backend `notification` payload yuborganda va ilova yopiq bo'lganda Android shu kanaldan foydalanadi):

```xml
<meta-data
    android:name="com.google.firebase.messaging.default_notification_channel_id"
    android:value="kpi_final_channel_v1" />
```

> ⚠️ Joriy loyihada `<activity>` ichida ham `high_importance_channel` qiymati bilan ikkinchi meta-data bor. U ishlatilmaydi va chalkashlik keltiradi — yangi loyihada faqat `<application>` darajasidagisini qoldiring.

Android 13+ uchun `POST_NOTIFICATIONS` ruxsati `firebase_messaging` plagini manifest'i orqali avtomatik qo'shiladi; `requestPermission()` uni so'raydi.

### 4.3 Kanallar

| Kanal ID | Nomi | Importance | Vazifasi |
|---|---|---|---|
| `kpi_final_channel_v1` | Asosiy bildirishnomalar | `max` | Barcha push xabarlar |
| `kpi_warning_channel_v1` | Ogohlantirishlar | `high` | "Ovozni pasaytirmang" ogohlantirishi |

> Android'da kanal bir marta yaratilgach, uning ovozi/importance'ini koddan o'zgartirib bo'lmaydi. Ovozni o'zgartirmoqchi bo'lsangiz — **yangi kanal ID** bering (`_v2` va h.k.), va manifest + native koddagi ID'ni ham yangilang.

## 5. Flutter kodi

### 5.1 `main.dart` — ishga tushirish

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(
      NotificationService.firebaseMessagingBackgroundHandler,
    );
  }
  await NotificationService.setupNotifications();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        // ...
      ],
      child: MaterialApp(
        home: const NotificationBlockedGate(child: AuthHandler()),
      ),
    ),
  );
}
```

Muhim: `onBackgroundMessage` **`runApp`dan oldin** va **top-level yoki static** funksiya bilan chaqirilishi shart, funksiyada `@pragma('vm:entry-point')` bo'lishi kerak.

### 5.2 `notification_bootstrap.dart` — `NotificationService`

Asosiy vazifalari:

**`setupNotifications()`**
1. `FlutterLocalNotificationsPlugin`ni `@mipmap/ic_launcher` ikonkasi bilan initsializatsiya qiladi.
2. Ikkala Android kanalini yaratadi.
3. `FirebaseMessaging.instance.requestPermission(alert, badge, sound)` — ruxsat so'raydi.
4. `setForegroundNotificationPresentationOptions` — iOS'da foreground'da ham ko'rsatish.
5. `FirebaseMessaging.onMessage` — ilova **ochiq** paytda kelgan xabarni local notification sifatida ko'rsatadi (FCM foreground'da o'zi ko'rsatmaydi).
6. `onMessageOpenedApp` va `getInitialMessage` — xabar bosilganda (hozircha faqat log).

**`firebaseMessagingBackgroundHandler()`** (ilova fonda/yopiq):
- Agar xabarda `notification` bloki bo'lsa — Android o'zi ko'rsatadi (manifest'dagi default kanal orqali).
- Agar **data-only** bo'lsa — biz `localNotifications.show()` bilan ko'rsatamiz.
- Shundan keyin ovoz tekshiruvi bajariladi.

**`_showLocalNotificationFromRemoteMessage()`**
- Sarlavha: `notification.title` → `data['title']` → `'Yangi xabar'`
- Matn: `notification.body` → `data['body']` → `'Sizga yangi xabar keldi'`
- ID: `DateTime.now().millisecondsSinceEpoch % 2^31` (har bir xabar alohida ko'rinadi).

**`_showLowVolumeWarningIfNeeded()`** — native kanal orqali tekshiradi, foydalanuvchi kanal ovozini o'zgartirgan/o'chirgan bo'lsa, doimiy `id: 999001` bilan ogohlantirish chiqaradi (bitta bo'lib qoladi, ko'payib ketmaydi).

### 5.3 Ovoz o'zgartirilganini tekshirish (native MethodChannel)

Dart tomoni — `lib/user/NotificationVolumeService.dart`:

```dart
class NotificationVolumeService {
  static const MethodChannel _channel = MethodChannel('kpi.notification.volume');

  static Future<bool> isNotificationSoundReducedOrChanged() async {
    final result = await _channel.invokeMethod<bool>('isNotificationSoundReducedOrChanged');
    return result ?? false;
  }
}
```

Kotlin tomoni — `MainActivity.kt`:

```kotlin
class MainActivity : FlutterActivity() {
    private val CHANNEL = "kpi.notification.volume"
    private val APP_CHANNEL_ID = "kpi_final_channel_v1"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isNotificationSoundReducedOrChanged" -> {
                        try {
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                                val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                                val ch = nm.getNotificationChannel(APP_CHANNEL_ID)
                                if (ch == null) { result.success(false); return@setMethodCallHandler }
                                result.success(ch.hasUserSetSound() || ch.sound == null)
                            } else result.success(false)
                        } catch (e: Exception) { result.success(false) }
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
```

> ⚠️ Cheklov: MethodChannel `MainActivity`da ro'yxatdan o'tgan. Ilova **yopiq** bo'lganda background handler alohida isolate'da ishlaydi va Activity yo'q — shuning uchun u yerda chaqiruv `MissingPluginException` beradi (try/catch ushlab qoladi, ogohlantirish chiqmaydi). Fon rejimida ham ishlashi kerak bo'lsa, handlerni `FlutterPlugin` sifatida yoki `Application` klassida ro'yxatdan o'tkazing.

### 5.4 Ruxsatni majburlash — `NotificationGuard` + `NotificationBlockedGate`

- `NotificationGuard.isNotificationEnabled()` — Android'da `areNotificationsEnabled()` orqali tekshiradi. Web va iOS'da doim `true` qaytaradi.
- `NotificationGuard.enforce(context)` — ruxsat yoqilmaguncha **yopib bo'lmaydigan** dialog ko'rsatadi (`barrierDismissible: false`, `PopScope(canPop: false)`):
  - **"Sozlamalarni ochish"** → `openAppSettings()` (permission_handler)
  - **"Qayta tekshirish"** → dialog yopiladi, `while (true)` sikli qayta tekshiradi.
- `NotificationBlockedGate` — `MaterialApp.home` ga o'raladi; tekshiruv tugaguncha loader ko'rsatadi, ruxsat bo'lsa `child`ni ochadi.

Natija: bildirishnomasi o'chiq foydalanuvchi ilovadan foydalana olmaydi. Bu talab sizning loyihangizga kerak bo'lmasa, gate'ni qo'shmang.

### 5.5 FCM token'ni backend'ga yuborish

Hozir `lib/user/pages/TasksPage.dart` → `initState()`da (login'dan keyin):

```dart
Future<void> getFCMToken() async {
  final token = await FirebaseMessaging.instance.getToken();
  if (token != null) await sendTokenToServer(token);
}

Future<void> sendTokenToServer(String fcmToken) async {
  final user = await SaveToken.readProfile();
  final authToken = await SaveToken.readToken();
  if (user?.id != null && authToken != null) {
    await ApiService().registerToken(user!.id!, {"token": fcmToken}, authToken, context);
  }
}
```

API: `POST users/{userId}/register-notification/`, body `{"token": "<fcm_token>"}`, header `Authorization: Bearer <jwt>`.

**Boshqa loyihada yaxshilash tavsiyalari:**
- Token yuborishni bitta sahifaga emas, **login muvaffaqiyatli bo'lgandan keyin** umumiy joyga (AuthProvider) qo'ying — aks holda faqat shu sahifaga kirgan rollar token yuboradi.
- `FirebaseMessaging.instance.onTokenRefresh.listen(sendTokenToServer)` qo'shing — token yangilanganda ham serverga ketadi.
- Logout'da `FirebaseMessaging.instance.deleteToken()` chaqiring (yoki backend'da tokenni o'chiring), aks holda chiqib ketgan foydalanuvchiga ham push boraveradi.

### 5.6 Ichki bildirishnomalar ro'yxati (backend API)

| Metod | Endpoint | Vazifasi |
|---|---|---|
| `GET` | `notifications/` | Joriy foydalanuvchining barcha bildirishnomalari |
| `POST` | `notifications/{id}/read/` | Bittasini o'qilgan qilish |
| `POST` | `notifications/read_all/` | Hammasini o'qilgan qilish |
| `POST` | `users/{id}/register-notification/` | FCM token'ni saqlash |

Javob formati (`GET notifications/`) — oddiy massiv:

```json
[
  {
    "id": 12,
    "title": "Yangi topshiriq",
    "message": "Sizga yangi topshiriq biriktirildi",
    "is_read": false,
    "datetime": "2026-09-30T10:15:00",
    "user": 5
  }
]
```

Model: `lib/user/models/notification_model.dart` (`NotificationModel` → `List<DataList>`).

`NotificationProvider` (ChangeNotifier) metodlari:
- `getNotification(context)` — ro'yxatni yuklaydi
- `readNotification(id, context)` / `readAllNotification(id, context)`
- `countUnreadNotification(context)` — `is_read == false` bo'lganlar soni (butun ro'yxatni yuklab sanaydi)

### 5.7 UI

- **`NotificationBellBadge`** — AppBar'dagi qo'ng'iroqcha. Ochilganda o'qilmaganlar sonini oladi, 99 dan ko'p bo'lsa `99+`. Bosilganda `NotificationPage` ochiladi, qaytganda son yangilanadi.
- **`NotificationPage`** — `RefreshIndicator` bilan ro'yxat; elementni bosish → `readNotification`; yuqoridagi tugma → `readAllNotification`.

## 6. Backend'dan push yuborish

Tavsiya etilgan payload (FCM HTTP v1):

```json
{
  "message": {
    "token": "<fcm_token>",
    "notification": {
      "title": "Yangi topshiriq",
      "body": "Sizga yangi topshiriq biriktirildi"
    },
    "data": {
      "title": "Yangi topshiriq",
      "body": "Sizga yangi topshiriq biriktirildi",
      "type": "task",
      "id": "123"
    },
    "android": {
      "priority": "high",
      "notification": {
        "channel_id": "kpi_final_channel_v1",
        "sound": "kpi_notification"
      }
    },
    "apns": {
      "payload": { "aps": { "sound": "default" } }
    }
  }
}
```

- `channel_id` va `sound` berilsa, ilova yopiq bo'lganda ham maxsus ovoz chalinadi.
- `data` ichida `title`/`body` takrorlansa, data-only rejimda ham to'g'ri ko'rinadi.
- Push yuborish bilan birga `notifications` jadvaliga yozuv qo'shilishi kerak — shunda ilova ichidagi ro'yxatda ham paydo bo'ladi.

## 7. Xabar oqimi (holatlar bo'yicha)

| Ilova holati | Payload | Kim ko'rsatadi | Ovoz tekshiruvi |
|---|---|---|---|
| Ochiq (foreground) | istalgan | `onMessage` → `flutter_local_notifications` | ✅ |
| Fonda / yopiq | `notification` bor | Android tizimi (default kanal) | ⚠️ native kanal ishlamaydi (5.3) |
| Fonda / yopiq | data-only | `firebaseMessagingBackgroundHandler` → local | ⚠️ native kanal ishlamaydi (5.3) |
| Bildirishnoma bosildi | — | `onMessageOpenedApp` / `getInitialMessage` | — |

## 8. Boshqa loyihaga ko'chirish — qisqa checklist

- [ ] Firebase loyiha + `flutterfire configure` + `google-services.json` / `GoogleService-Info.plist`
- [ ] `pubspec.yaml` paketlari (2-bo'lim)
- [ ] Gradle: google-services plagini + core library desugaring
- [ ] `res/raw/<ovoz>.mp3` (+ `keep.xml`)
- [ ] Manifest: `default_notification_channel_id`
- [ ] `notification_bootstrap.dart` nusxalash; kanal ID, nom va ovoz nomini o'zgartirish
- [ ] `main.dart`: `Firebase.initializeApp` → `onBackgroundMessage` → `setupNotifications()`
- [ ] (ixtiyoriy) `MainActivity.kt` MethodChannel + `NotificationVolumeService` — kanal ID bir xil bo'lsin
- [ ] (ixtiyoriy) `NotificationGuard` + `NotificationBlockedGate` — ruxsatni majburlash
- [ ] Login'dan keyin FCM token'ni backend'ga yuborish + `onTokenRefresh` + logout'da `deleteToken`
- [ ] Backend: token saqlash, `notifications/` CRUD, FCM orqali yuborish
- [ ] `NotificationProvider`, model, `NotificationBellBadge`, `NotificationPage`
- [ ] iOS: Xcode'da *Push Notifications* va *Background Modes → Remote notifications* capability, Firebase'ga APNs key yuklash

## 9. Hozirgi loyihadagi ma'lum kamchiliklar

1. Bildirishnoma bosilganda tegishli sahifaga o'tish (deep link) yo'q — faqat `debugPrint`.
2. FCM token faqat `TasksPage`da yuboriladi; `onTokenRefresh` va logout'da o'chirish yo'q.
3. `localNotifications.initialize` faqat Android sozlamalari bilan chaqirilgan — iOS uchun `DarwinInitializationSettings` qo'shilmagan.
4. Manifest'da ikkita, har xil `default_notification_channel_id` bor.
5. Ovoz tekshiruvi fon rejimida ishlamaydi (5.3).
6. `countUnreadNotification` butun ro'yxatni yuklaydi — backend'da `unread_count` endpoint bo'lsa samaraliroq.
