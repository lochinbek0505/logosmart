# Push notification (Firebase Cloud Messaging) — integratsiya qo'llanmasi

Bu hujjat **mobil ilova** va **admin panel** dasturchilari uchun. Backend FCM orqali push yuboradi
va har bir notificationni bazaga ham yozadi, shu sabab ilova ichida "Bildirishnomalar" ro'yxatini
ko'rsatish mumkin (push kelmay qolgan bo'lsa ham).

- Base URL: `https://<server>/api/v1`
- Barcha endpointlar `Authorization: Bearer <token>` talab qiladi (login'da olingan `accessToken`).
- Admin endpointlari faqat `ROLE_ADMIN` uchun.
- Vaqtlar ISO-8601 formatida, UTC (`2026-09-30T05:00:00Z`).

---

## 1. Qachon notification keladi

| `type` | Qachon | `data.screen` | Qo'shimcha `data` |
|---|---|---|---|
| `PAYMENT_SUCCESS` | Click orqali balans to'ldirildi | `billing` | — |
| `PAYMENT_CANCELED` | Click to'lovi bekor qilindi | `billing` | — |
| `SUBSCRIPTION_ACTIVATED` | Obuna faollashtirildi | `subscription` | `planCode` |
| `SUBSCRIPTION_EXPIRING` | Obuna tugashiga 3 kun qoldi / 24 soat qoldi | `subscription` | — |
| `SUBSCRIPTION_EXPIRED` | Obuna muddati tugadi (oxirgi 24 soatda) | `subscription` | — |
| `BALANCE_CHANGED` | Admin user balansini o'zgartirdi | `billing` | — |
| `ADMIN_MESSAGE` | Admin paneldan yuborilgan xabar | admin nima bersa | admin bergan `data` |

Obuna eslatmalari har kuni **soat 10:00 (Toshkent)** da yuboriladi.

Matnlar (title/body) backendda o'zbek tilida tayyorlanadi, ilova ularni o'zgartirmasdan ko'rsatadi.

---

## 2. Mobil ilova

### 2.1. Firebase sozlash

- **Android:** `google-services.json` → `android/app/`. Package: `com.logosmart.logosmart`.
- **iOS:** Firebase Console'da iOS ilova hali qo'shilmagan. Qo'shib, `GoogleService-Info.plist` ni
  olish va Firebase Console → Project settings → Cloud Messaging bo'limiga **APNs auth key (.p8)**
  yuklash kerak, aks holda iOS'ga push bormaydi.
- **Android 13+:** `POST_NOTIFICATIONS` ruxsatini so'rash shart.

### 2.2. Qurilma tokenini ro'yxatdan o'tkazish

Login (yoki register) muvaffaqiyatli bo'lgandan **keyin** va FCM token yangilanganda chaqiriladi.

```
POST /api/v1/notifications/device-token
Authorization: Bearer <token>
Content-Type: application/json

{
  "fcmToken": "dXk3...",
  "platform": "ANDROID"      // ANDROID | IOS | WEB
}
```

Javob: `200 {"success": true}`

- Token login sessiyasiga bog'lanadi. **Logout** (`POST /api/v1/auth/logout`) qilinganda backend shu
  qurilma tokenini o'zi o'chiradi, ilova alohida hech narsa chaqirmaydi.
- Bir telefonda boshqa akkauntga kirilsa, token yangi userga o'tadi. Oldingi userning pushlari bu
  telefonga kelmaydi.
- Akkount o'chirilganda barcha tokenlar va notificationlar ham o'chiriladi.

### 2.3. Push'ni o'chirish (sozlamalarda "Bildirishnomalar: o'chiq")

```
DELETE /api/v1/notifications/device-token?fcmToken=dXk3...
```

Javob: `200 {"success": true}`. Qayta yoqilganda 2.2 ni yana chaqiring.

### 2.4. Push payload

Har bir push `notification` (title, body) va `data` qismidan iborat:

```json
{
  "notification": { "title": "Balans to'ldirildi", "body": "Hisobingizga 150 000 so'm tushdi." },
  "data": {
    "type": "PAYMENT_SUCCESS",
    "screen": "billing",
    "notificationId": "66fa1c..."
  }
}
```

- `notificationId` faqat shaxsiy notificationlarda keladi, admin broadcast'da **kelmaydi**.
- `data` dagi barcha qiymatlar string.

**Push bosilganda qaysi ekran ochiladi (`data.screen` bo'yicha):**

| `screen` | Ekran |
|---|---|
| `billing` | Balans / to'lovlar tarixi |
| `subscription` | Obuna / tariflar |
| yo'q yoki noma'lum | Bildirishnomalar ro'yxati |

Push bosilganda `notificationId` bo'lsa, `PATCH /notifications/{id}/read` ni chaqirish tavsiya etiladi.

> **Muhim (Android):** ilova ochiq (foreground) paytida FCM `notification` xabarini tizim o'zi
> ko'rsatmaydi. Uni `flutter_local_notifications` (yoki native `NotificationManager`) bilan
> qo'lda ko'rsatish yoki ilova ichida banner chiqarish kerak.

### 2.5. Flutter namunasi

```dart
final messaging = FirebaseMessaging.instance;

Future<void> initPush(ApiClient api) async {
  await messaging.requestPermission();

  final token = await messaging.getToken();
  if (token != null) {
    await api.post('/notifications/device-token', {
      'fcmToken': token,
      'platform': Platform.isIOS ? 'IOS' : 'ANDROID',
    });
  }

  messaging.onTokenRefresh.listen((t) => api.post('/notifications/device-token', {
        'fcmToken': t,
        'platform': Platform.isIOS ? 'IOS' : 'ANDROID',
      }));

  // ilova ochiq paytida
  FirebaseMessaging.onMessage.listen((m) {
    showLocalNotification(m.notification?.title, m.notification?.body, m.data);
    refreshUnreadBadge();
  });

  // fonda turganda push bosildi
  FirebaseMessaging.onMessageOpenedApp.listen((m) => openFromPush(m.data));

  // ilova yopiq turganda push bosildi
  final initial = await messaging.getInitialMessage();
  if (initial != null) openFromPush(initial.data);
}

void openFromPush(Map<String, dynamic> data) {
  final id = data['notificationId'];
  if (id != null) api.patch('/notifications/$id/read');

  switch (data['screen']) {
    case 'billing':      router.push('/billing'); break;
    case 'subscription': router.push('/subscription'); break;
    default:             router.push('/notifications');
  }
}
```

`initPush` ni **login'dan keyin** chaqiring (token'siz 2.2 endpointi 403 qaytaradi).

### 2.6. Ilova ichidagi bildirishnomalar ro'yxati

**Ro'yxat (yangilari birinchi):**

```
GET /api/v1/notifications?page=0&size=20      // size: 1..100, default 20
```

```json
{
  "items": [
    {
      "id": "66fa1c...",
      "type": "SUBSCRIPTION_ACTIVATED",
      "title": "Obuna faollashtirildi",
      "body": "\"Oylik\" obunasi faollashtirildi. Amal qilish muddati: 30.10.2026 gacha.",
      "data": { "screen": "subscription", "planCode": "MONTHLY" },
      "read": false,
      "createdAt": "2026-09-30T05:00:00Z"
    }
  ],
  "page": 0,
  "size": 20,
  "total": 1,
  "totalPages": 1
}
```

**O'qilmaganlar soni (badge uchun):**

```
GET /api/v1/notifications/unread-count     →   {"count": 3}
```

**Bittasini o'qildi qilish:**

```
PATCH /api/v1/notifications/{id}/read      →   {"success": true}
```

Boshqa userning `id` si yoki mavjud bo'lmagan `id` → `404`.

**Hammasini o'qildi qilish:**

```
PATCH /api/v1/notifications/read-all       →   {"success": true}
```

---

## 3. Admin panel

### 3.1. Xabar yuborish (broadcast)

```
POST /api/v1/admin/notifications/broadcast
Authorization: Bearer <admin token>
Content-Type: application/json
```

| Maydon | Turi | Majburiy | Izoh |
|---|---|---|---|
| `title` | string | ha | max 100 belgi |
| `body` | string | ha | max 500 belgi |
| `target` | enum | ha | `ALL` \| `USER` \| `ROLE` \| `REGION` |
| `userId` | string | `target=USER` da | user `id` si (`GET /api/v1/profile/users` dan) |
| `role` | enum | `target=ROLE` da | `ROLE_USER`, `ROLE_USER_PARENT`, `ROLE_TEACHER`, `ROLE_PARTNER`, `ROLE_ADMIN` |
| `region` | string | `target=REGION` da | userdagi `region` bilan **aynan bir xil** yozilishi kerak |
| `data` | object<string,string> | yo'q | ilovaga qo'shimcha ma'lumot, masalan `{"screen":"subscription"}` |

**Misollar:**

```json
// hammaga
{ "title": "Yangi mashqlar!", "body": "R tovushi uchun 5 ta yangi mashq qo'shildi.", "target": "ALL" }

// bitta userga
{ "title": "Salom", "body": "Diagnostika natijangiz tayyor.", "target": "USER", "userId": "3f2a..." }

// barcha logopedlarga
{ "title": "Yig'ilish", "body": "Ertaga soat 15:00 da onlayn yig'ilish.", "target": "ROLE", "role": "ROLE_TEACHER" }

// viloyat bo'yicha, bosilganda obuna ekrani ochiladi
{ "title": "Chegirma", "body": "Toshkent shahri uchun 20% chegirma!", "target": "REGION",
  "region": "Toshkent shahri", "data": { "screen": "subscription" } }
```

**Javob:**

```json
{ "recipients": 1250 }
```

- `recipients` — xabar yuboriladigan userlar soni. Yuborish **fonda** bajariladi, ya'ni javob
  kelganda pushlar hali yetib bormagan bo'lishi mumkin.
- `ALL`, `ROLE`, `REGION` faqat **ACTIVE** statusdagi userlarni oladi.
- `recipients: 0` — mos user topilmadi (masalan, region noto'g'ri yozilgan).
- Har bir qabul qiluvchining ilovadagi ro'yxatiga `ADMIN_MESSAGE` turida yoziladi.

**Xatolar:**

| Holat | Kod | `message` |
|---|---|---|
| `target=USER`, `userId` yo'q | 400 | `target=USER uchun userId majburiy` |
| `target=USER`, user topilmadi | 404 | `Foydalanuvchi topilmadi.` |
| `target=ROLE`, `role` yo'q | 400 | `target=ROLE uchun role majburiy` |
| `target=REGION`, `region` yo'q | 400 | `target=REGION uchun region majburiy` |
| `title`/`body` bo'sh yoki juda uzun | 400 | `Validation failed` + `fieldErrors` |
| Admin emas | 403 | — |

Xato formati:

```json
{ "timestamp": "...", "status": 400, "error": "BAD_REQUEST", "message": "target=USER uchun userId majburiy" }
```

### 3.2. Admin panel UI tavsiyasi

"Bildirishnoma yuborish" sahifasi:

1. **Kimga:** radio — Hammaga / Bitta foydalanuvchi / Rol bo'yicha / Viloyat bo'yicha
   - Bitta foydalanuvchi → userlar ro'yxatidan qidirib tanlash (`GET /api/v1/profile/users?q=...`)
   - Rol → select (yuqoridagi rollar)
   - Viloyat → select (registratsiyadagi viloyatlar ro'yxati bilan bir xil qiymatlar)
2. **Sarlavha** (100 belgi hisoblagichi bilan), **Matn** (500 belgi)
3. **Bosilganda ochiladigan ekran** (ixtiyoriy): Yo'q / Balans / Obuna → `data.screen`
4. "Hammaga" tanlanganda tasdiqlash oynasi: *"Xabar barcha foydalanuvchilarga yuboriladi. Davom etasizmi?"*
5. Muvaffaqiyatli javobdan keyin: *"Xabar N ta foydalanuvchiga yuborilmoqda"*

> Hozircha yuborilgan broadcastlar tarixini ko'rsatadigan admin endpointi yo'q. Kerak bo'lsa
> alohida qo'shiladi.

### 3.3. Avtomatik yuboriladigan notificationlar

Admin panelda qo'shimcha ish talab qilinmaydi, lekin admin bilishi kerak:

- `PUT /api/v1/profile/users/{userId}` da `amount` o'zgartirilsa, userga **"Balansingiz yangilandi"**
  push'i avtomatik ketadi (faqat ACTIVE userlarga, summa haqiqatda o'zgargan bo'lsa).
- To'lov, obuna faollashishi va obuna tugashi haqidagi xabarlar ham avtomatik yuboriladi.

---

## 4. Server sozlamasi (DevOps)

1. Service account kaliti: `./firebase/service-account.json` (git'ga **qo'shilmaydi**, `.gitignore` da bor).
2. `docker-compose.yml` bu papkani konteynerga `/app/firebase` sifatida mount qiladi.
3. `.env` ga:

   ```
   FIREBASE_ENABLED=true
   # ixtiyoriy, default: /app/firebase/service-account.json
   # FIREBASE_CREDENTIALS_PATH=/app/firebase/service-account.json
   ```

4. Ishga tushganda logda quyidagi qator chiqishi kerak:

   ```
   Firebase initialized: projectId=logosmart-413e2
   ```

`FIREBASE_ENABLED=false` bo'lsa, notificationlar faqat bazaga yoziladi va push yuborilmaydi.
Ilova bu holatda ham normal ishlaydi.

Obuna eslatmalari scheduler orqali ishlaydi. Backend **bitta instansda** ishlashi kerak, aks holda
eslatmalar takrorlanadi.
