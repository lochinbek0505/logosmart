# O'yinlar, Ilk nutq va ball — serverga ko'chirish bo'yicha hisobot

**Sana:** 2026-11-05
**Loyihalar:** `logosmart` (Flutter ilova), `logosmart-backend` (Spring Boot), `logosmart_admin_vue` (admin panel)
**Holat:** Kod yozildi va testlardan o'tdi. **Commit qilinmagan.** Real telefonda (APK) va ishlab turgan serverda hali sinalmagan.

---

## Mundarija

1. [Qisqacha natija](#1-qisqacha-natija)
2. [Avvalgi holat va muammolar](#2-avvalgi-holat-va-muammolar)
3. [Backend o'zgarishlari](#3-backend-ozgarishlari)
4. [Admin panel o'zgarishlari](#4-admin-panel-ozgarishlari)
5. [Ilova o'zgarishlari](#5-ilova-ozgarishlari)
6. [Internet yo'q / qaytdi — xatti-harakat](#6-internet-yoq--qaytdi--xatti-harakat)
7. [Eski (lokal) progressni ko'chirish](#7-eski-lokal-progressni-kochirish)
8. [Serverga yuklanadigan JSON fayllar](#8-serverga-yuklanadigan-json-fayllar)
9. [Testlar](#9-testlar)
10. [Tekshirilmagan qismlar](#10-tekshirilmagan-qismlar)
11. [Men tanlagan qarorlar](#11-men-tanlagan-qarorlar)
12. [Ishga tushirish tartibi](#12-ishga-tushirish-tartibi)
13. [Avvaldan bor muammolar](#13-avvaldan-bor-muammolar)
14. [Oldingi topshiriq: CV model natijasi hisoblanmasligi](#14-oldingi-topshiriq-cv-model-natijasi-hisoblanmasligi)
15. [O'zgargan fayllar ro'yxati](#15-ozgargan-fayllar-royxati)

---

## 1. Qisqacha natija

| Talab | Holat |
|---|---|
| O'yinlar va Ilk nutq to'liq serverda saqlanadi, ilova sinxron ishlaydi | Bajarildi |
| Ilk nutq — kartalar emas, bitta JSON asosidagi bitta xarita | Bajarildi (42 level) |
| Ball umumiy va to'liq serverda | Bajarildi |
| Internet qaytganda navbatdagi natijalar o'zi yuborilsin (4-bo'lim, 3-qism xatosi) | Tuzatildi |
| Logout'dan keyin oldingi bolaning progressi keyingi akkauntga o'tib qolishi | Tuzatildi |
| Internet yo'q bo'lsa o'yin/mashqqa kirib bo'lmasin, dizaynga mos ogohlantirish | Bajarildi |
| Admin panelda JSON yuklash | Bajarildi (mavjud "JSON import" O'yinlar va Ilk nutq uchun ham ishlaydi) |
| Har bir qism testdan o'tkazilsin | Backend 244, ilova 65 test o'tdi |

---

## 2. Avvalgi holat va muammolar

| Qism | Qayerda edi | Muammo |
|---|---|---|
| Tovushlar (R, L, S, K, Sh, Z, G) | Serverda | Internet qaytganda navbat avtomatik yuborilmasdi |
| O'yinlar (46 level) | APK ichidagi `assets/games.json`, progress faqat Hive'da | Ilova o'chirilsa yoki telefon almashtirilsa progress yo'qolardi |
| Ilk nutq (4 ta xarita) | `assets/first_speech/*.json`, progress faqat Hive'da | Xuddi shu |
| Umumiy ball | Faqat Hive'da (`_total_ball`) | Backend bilan sinxronlash funksiyalari bo'sh edi; logout'da ball o'chib ketardi |
| Logout | `clearServerData()` faqat tovushlar keshini tozalardi | O'yinlar va Ilk nutq progressi qolib, keyingi akkauntga o'tardi |

---

## 3. Backend o'zgarishlari

### 3.1. Bo'lim turi (`category`)

- Yangi enum: `PracticeCategory` — `SOUND`, `GAMES`, `FIRST_SPEECH`.
- `VoicePractice` modeliga `category` maydoni qo'shildi.
  - Bazadagi eski yozuvlarda bu maydon yo'q — ular avtomatik `SOUND` hisoblanadi. **Ma'lumotlar migratsiyasi kerak emas.**
- `VoicePracticeRequest` ga ixtiyoriy `category` qo'shildi. Yuborilmasa:
  - yaratishda — `SOUND`;
  - tahrirlashda — avvalgi qiymat saqlanadi.
- **O'yinlar va Ilk nutq bittadan bo'ladi.** Ikkinchisini yaratishga yoki tovush mashqini band bo'limga aylantirishga urinilsa `409 CONFLICT` qaytadi.
- `GET /voice-practices` endi **faqat tovushlarni** qaytaradi.

### 3.2. Yangi API'lar

| API | Kim uchun | Vazifasi |
|---|---|---|
| `GET /api/v1/games` | Ilova | O'yinlar xaritasi levellari foydalanuvchi progressi bilan |
| `GET /api/v1/first-speech` | Ilova | Ilk nutq xaritasi levellari progress bilan |
| `GET /api/v1/ball` | Ilova | Serverdagi umumiy ball |
| `POST /api/v1/ball/events` | Ilova | Ball o'zgarishlarini yuborish |
| `GET /api/v1/admin/voice-practices?category=` | Admin | Bo'limlar ro'yxati (turi bo'yicha filtr) |

**`/games` va `/first-speech` javobi (`SectionResponse`):**

```json
{
  "id": "voicePracticeId",
  "name": "O'yinlar",
  "category": "GAMES",
  "totalLevels": 46,
  "availableLevelsCount": 46,
  "starCount": 12,
  "subscribed": false,
  "levels": [ /* /levels?voicePracticeId= bilan bir xil format */ ]
}
```

- Bo'lim hali admin panelda yaratilmagan bo'lsa — `404`.
- Natija (yulduz) uchun **mavjud** `POST /levels/{id}/stars` ishlatiladi. U yulduz, keyingi levelni ochish, obuna (`isFree`) va tarixni allaqachon boshqaradi.

**Ball API:**

```json
POST /api/v1/ball/events
{ "events": [ { "id": "ilova-yaratgan-unikal-id", "delta": 10 }, { "id": "...", "delta": -5 } ] }

Javob: { "ball": 55, "accepted": 2 }
```

- Har bir hodisa `id` si ilovada yaratiladi. Server `userId + eventId` bo'yicha unikal indeks bilan takrorlarni e'tiborsiz qoldiradi. **Internet uzilib so'rov qayta yuborilsa ham ball ikki marta qo'shilmaydi.**
- Ball **0 dan pastga tushmaydi**.
- Validatsiya:
  - `id` bo'sh bo'lmasligi va 64 belgidan oshmasligi kerak;
  - `delta` −1000…1000 oralig'ida;
  - bir so'rovda ko'pi bilan 200 ta hodisa.

  Noto'g'ri so'rov `400` oladi.
- Ball `users` hujjatidan alohida **`user_balls`** kolleksiyasida saqlanadi. Hodisalar `ball_events` da turadi. Shunda profil saqlanganda ball ustiga eski qiymat yozilib ketmaydi.

### 3.3. Statistika

- `SectionUsageInterceptor` ga yangi bo'limlar qo'shildi:
  - `/games` → `games`;
  - `/first-speech` → `first_speech`;
  - `/ball` → `progress`.
- Admin statistikasida nomlari: "O'yinlar xaritasi", "Ilk nutqni rivojlantirish".

### 3.4. Xavfsizlik

- Yangi foydalanuvchi API'lari login talab qiladi.
- `/admin/voice-practices` faqat `ADMIN` uchun.
- Ikkalasi ham `SecurityAccessTest` da tekshirilgan.

---

## 4. Admin panel o'zgarishlari

- **"Ovoz mashqlari"** sahifasiga 3 ta tab qo'shildi: **Tovushlar / O'yinlar / Ilk nutq**. Tanlangan tab URL'da saqlanadi (`?tab=GAMES`).
- **O'yinlar** va **Ilk nutq** tablari:
  - bo'lim hali yo'q bo'lsa — "Bo'lim hali yaratilmagan" va **"Bo'limni yaratish"** tugmasi chiqadi;
  - bo'lim bor bo'lsa — bitta karta ko'rinadi, uni bosib levellarga o'tiladi;
  - levellar sahifasidagi mavjud **"JSON import"** ishlatiladi (format R, L bilan bir xil);
  - ichida levellari bor bo'limni o'chirish tugmasi yashirilgan (levellar "yetim" qolmasligi uchun).
- Ro'yxat endi admin API'sidan (`/admin/voice-practices`) olinadi. Kartada levellar soni ko'rsatiladi.
  - Oldingi "yulduz / ochiq / boshlangan" raqamlari adminning o'z progressi edi, ma'nosiz bo'lgani uchun olib tashlandi.
- Yangi matnlar uchun ruscha va inglizcha tarjimalar `messages.js` ga qo'shildi.
- Levellar sahifasidan "Orqaga" tugmasi to'g'ri tabga qaytaradi.

> Admin loyihasida sizning commit qilinmagan i18n o'zgarishlaringiz bor edi — ularga tegmadim, faqat kerakli qatorlarni qo'shdim.

---

## 5. Ilova o'zgarishlari

### 5.1. `LevelProvider` (asosiy mantiq)

- **Barcha xaritalar serverdan:**
  - tovushlar — `/levels`;
  - O'yinlar — `/games`;
  - Ilk nutq — `/first-speech`.
- Lokal JSON'dan o'qish (`soundLevelFiles`, `_loadLevels`, `_saveProgress`) olib tashlandi.
- Ilk nutqning 4 ta konstantasi (`FS_*`) o'rniga bitta `firstSpeechSound = 'FIRST_SPEECH'` ishlatiladi.
- **Natijalar navbati:** yulduz avval Hive'dagi navbatga yoziladi, keyin serverga yuboriladi.
  - Yuborish paytida yangi natija qo'shilsa, u ham shu aylanishda ketadi.
  - Server rad etgan natija (masalan, pullik level) navbatdan olinadi.
- **Ball:** `ball` = serverdagi qiymat + hali yuborilmagan o'zgarishlar.
  - `addBall()` darhol ekranda ko'rinadi va serverga navbat orqali ketadi.
- **Sinxronlash triggerlari:**
  - internet qaytganda;
  - ilova fondan qaytganda (`resumed`);
  - har bir natijadan keyin;
  - xarita yuklanganda.

  Har birida navbatdagi yulduz va ballar yuboriladi, ochiq xarita serverdan yangilanadi.
- **Login'dan keyin** (`bootstrap`) O'yinlar va Ilk nutq oldindan yuklanadi va keshlanadi. Shu payt eski lokal progress ham serverga ko'chiriladi.
- **"So'ngi harakat"** kartasi faqat tovush mashqlarini hisobga oladi. O'yin natijasi tarixda eng yangi bo'lsa ham, u tovush deb olinmaydi.
- **Logout:**
  - `flushBeforeSignOut()` navbatni ko'pi bilan 4 soniya ichida yuborishga urinadi;
  - keyin `clearServerData()` keshlar, navbatlar, ball va eski lokal progressni tozalaydi.
- **Login** (`reloadForUser`): eski lokal progress o'chirilmaydi, u kirgan foydalanuvchiga ko'chiriladi.

### 5.2. Yangi fayllar

| Fayl | Vazifasi |
|---|---|
| `lib/core/network/network_status.dart` | Internet holati. `connectivity_plus` va serverga haqiqiy so'rov (`/actuator/health`) orqali "Wi-Fi bor, lekin internet yo'q" holatini ham aniqlaydi. Internet qaytsa tinglovchilarga xabar beradi |
| `lib/ui/pages/games/widgets/no_internet.dart` | `NoInternetView` (xarita o'rnidagi karta), `showNoInternetDialog`, `ensureOnline()` |

### 5.3. UI

- **`MapRoadPage`:**
  - ochilganda internet tekshiriladi;
  - internet yo'q bo'lsa levellar ko'rsatilmaydi (keshda bo'lsa ham), o'rniga "Internet yo'q" kartasi chiqadi;
  - kartada **"Qayta urinish"** tugmasi bor; alohida sahifada **"Orqaga"** ham bor (O'yinlar tabida yo'q);
  - internet qaytsa xarita **o'zi** ochiladi;
  - har bir levelni bosishdan oldin `ensureOnline()` chaqiriladi. Internet yo'q bo'lsa ogohlantirish oynasi chiqadi va o'yin ochilmaydi.
- **Dizayn:** mavjud dialoglar uslubida — `palette.surface`, `nunito` shrifti, `main_blue_600` tugma, qizil `wifi_off` belgisi.
- **`StartSpeechPage`:** "Boshlash" bosilganda kartalar sahifasi o'rniga `MapRoadPage(sound: FIRST_SPEECH)` ochiladi.
- `first_speech_categories_page.dart` **o'chirildi**.

### 5.4. Topilgan va tuzatilgan eski xato

`MapRoadPage.initState` ichida `selectSound()` kadr chizilayotgan paytda provider'ni yangilardi. Debug rejimda bu **"setState() called during build"** xatosini berardi. Endi chaqiruv kadrdan keyinga (microtask) o'tkazildi. Xatoni widget testlar topdi.

### 5.5. Boshqa

- `ApiService`: `getSection()`, `getBall()`, `postBallEvents()`, `ping()` qo'shildi.
- `main.dart`: `NetworkStatus.instance.start()` qo'shildi.
- `profile_provider.signOutLocally`: token o'chirilishidan oldin `flushBeforeSignOut()` chaqiriladi.

---

## 6. Internet yo'q / qaytdi — xatti-harakat

| Holat | Nima bo'ladi |
|---|---|
| Xaritaga kirishda internet yo'q | "Internet yo'q" kartasi chiqadi, levellar ko'rinmaydi |
| Internet qaytdi (kartadagi "Qayta urinish" yoki tarmoq o'zgarishi) | Xarita serverdan yuklanib ochiladi |
| Xarita ochiq, internet uzildi, levelga bosildi | Ogohlantirish oynasi chiqadi, o'yin ochilmaydi |
| O'yin o'rtasida internet uzildi | Natija navbatga yoziladi, keyingi level ochiladi, ball ekranda ko'rinadi |
| Internet qaytdi / ilova fondan qaytdi | Navbatdagi yulduz va ballar yuboriladi, xarita yangilanadi |
| Server javobi yo'qolib, so'rov qayta yuborildi | Yulduz: server eng yuqorisini saqlaydi. Ball: `eventId` tufayli ikki marta qo'shilmaydi |
| Logout'da internet yo'q | 4 soniyadan ko'p kutmaydi, keyin tozalaydi |

---

## 7. Eski (lokal) progressni ko'chirish

Yangilanishdan keyin birinchi marta xarita serverdan yuklanganda **bir marta** bajariladi. Keyin lokal yozuvlar o'chiriladi.

| Eski kalit (Hive) | Yangi xaritadagi o'rni |
|---|---|
| `GAMES` | O'yinlar 1–46 (avval "hammasi ochiq" bo'lib qolgan eski ma'lumot to'g'rilanadi) |
| `FS_ARTIKULATSION` | Ilk nutq 1–8 |
| `FS_NAFAS` | Ilk nutq 9–20 |
| `FS_BARMOQ` | Ilk nutq 21–27 |
| `FS_CHIZIQ` | Ilk nutq 28–42 |
| `_total_ball` | Bitta ball hodisasi sifatida serverga yuboriladi |

- Yulduzli levellar ko'chiriladi.
- Keyingi leveli ochiq bo'lgan levellar 0 yulduz bilan "o'tilgan" deb ko'chiriladi.
- Har bir eski xaritaning 1-leveli doim ochiq edi. Shuning uchun u oldingi bo'limning oxirgi leveli o'ynalgan deb **hisoblanmaydi**.

---

## 8. Serverga yuklanadigan JSON fayllar

`logosmart/server_levels/` papkasida:

| Fayl | Levellar | Tarkibi |
|---|---|---|
| `games.json` | 46 | 46 ta o'yin (`assets/games.json` dan) |
| `first_speech.json` | 42 | artikulatsion 8 (mashq) + nafas 12 + barmoq 7 + chiziq 15 (o'yin) |

- `id` lar 1 dan ketma-ket.
- 1-level ochiq (`locked: false`), qolganlari yopiq.
- Hammasida `isFree: true`.
- Har bir o'yin turi ilovadagi `navigationTo` ro'yxatida borligi va har bir mashq levelida qadamlar borligi tekshirildi.

---

## 9. Testlar

### 9.1. Natijalar

| Loyiha | Natija |
|---|---|
| Backend (`./mvnw test`, JDK 21) | **244 test, 0 xato** (1 ta skip — avvaldan bor). 18 ta yangi test |
| Ilova (`flutter test`) | **65 o'tdi**, 1 ta yiqildi — avvaldan buzuq shablon (13-bo'limga qarang). 24 ta yangi test |
| Admin (`npm run build`) | Muvaffaqiyatli |
| `flutter analyze` | Yangi xato yoki ogohlantirish yo'q |

### 9.2. Backend testlari

| Test | Nimani tekshiradi |
|---|---|
| `VoicePracticeCategoryTest` (7) | Default `SOUND`; O'yinlar/Ilk nutq bittadan (409); tahrirda category saqlanishi; `/voice-practices` faqat tovushlar; admin filtri |
| `SectionServiceTest` (3) | Yulduzlar va ochiq levellar soni; bo'lim yo'q bo'lsa 404; `SOUND` so'ralmaydi |
| `BallServiceMongoTest` (7, haqiqiy Mongo test bazasi) | Takroriy `eventId` ikki marta qo'shilmaydi (alohida so'rovda ham, bitta paket ichida ham); 0 dan pastga tushmaydi; `delta=0`; foydalanuvchilar alohida; **8 ta parallel so'rov** — har hodisa aniq bir marta |
| `BallAndSectionApiTest` (5, HTTP) | `/games`, `/first-speech`, `/ball`; 404; noto'g'ri ball so'rovlari 400; admin filtri va noto'g'ri `category` 400 |
| `SectionFlowMongoTest` (2, haqiqiy Mongo) | **To'liq oqim:** bo'lim yaratish → levellar importi → `/games` → yulduz → keyingi level ochiladi; pullik level kontenti yashirilishi |
| `SecurityAccessTest` (+7 qator) | Yangi API'lar tokensiz yopiq; admin API oddiy userga yopiq |

**Haqiqiy fayllar bilan tekshiruv.** `games.json` va `first_speech.json` admin panelning **haqiqiy** `normalize()` funksiyasidan o'tkazildi (Node orqali `ImportLevelsModal.vue` dan olindi). Natija `SectionFlowMongoTest` ga berildi va har bir level backend validatsiyasidan o'tdi.

### 9.3. Ilova testlari

**`test/level_sync_test.dart` (20 test, soxta backend server bilan):**
- O'yinlar `/games` dan, Ilk nutq `/first-speech` dan yuklanadi.
- `server_levels/*.json` serverdan kelganda to'g'ri o'qiladi: o'yin turi, `jsonConfig`, mashq qadamlari.
- Natija serverga ketadi; boshqa qurilmada progress tiklanadi.
- 404, pullik level, rad etilgan natija holatlari.
- Internetsiz natija navbatda turadi va internet qaytishi bilan yuboriladi; fondan qaytganda ham yuboriladi.
- Ball: yuborish, internetsiz yig'ish, javob yo'qolganda ikki marta qo'shilmasligi, 0 dan pastga tushmasligi, eski ballni ko'chirish.
- Ilk nutqning 4 ta eski xaritasini siljish bilan ko'chirish; O'yinlar eski ma'lumoti.
- Logout tozalashi, internetsiz logout, login'da eski progressning saqlanishi.

**`test/map_offline_test.dart` (4 ta widget test):**
- Internet yo'q → "Internet yo'q" kartasi chiqadi, keshdagi levellar ham ko'rinmaydi → "Qayta urinish" → xarita ochiladi.
- O'yinlar tabida "Orqaga" yo'q; internet qaytsa xarita o'zi ochiladi.
- Xarita ochiq, internet uzildi → levelga bosilsa ogohlantirish chiqadi, level ochilmaydi.
- Ilk nutq "Boshlash" → bitta xarita (`/first-speech`) ochiladi.

### 9.4. Mutatsiya tekshiruvi

Testlar tasodifan o'tmayotganini isbotlash uchun kodga ataylab xato kiritildi:

| Kiritilgan xato | Testlar ushladimi |
|---|---|
| Ilk nutq migratsiyasida 1-level himoyasi olib tashlandi | Ha |
| Internet qaytganda sinxronlash o'chirildi | Ha |
| Ball hodisa ID'si har safar yangilanadigan qilindi | Ha |
| Logout eski lokal progressni o'chirmaydigan qilindi | Ha |
| Internetsiz yuborishda natija tashlab yuboriladigan qilindi | Ha |
| Level bosishda internet tekshiruvi olib tashlandi | Ha |
| "Internet yo'q" kartasi o'chirildi | Ha |
| Internetsiz keshdagi levellar ko'rsatiladigan qilindi | Ha |

Testlar ketma-ket 3–5 marta ishga tushirildi — barqaror o'tdi.

---

## 10. Tekshirilmagan qismlar

- **Real telefon va APK** — build qilinmadi (talabingizga ko'ra).
- **Backend'ni to'liq ishga tushirish** — lokal kompyuterda Redis va Docker ishlamayapti. Oqim servis darajasida, haqiqiy Mongo test bazasida va HTTP (MockMvc) testlari bilan tekshirildi.
- **Admin panelni brauzerda bosib ko'rish** — qilinmadi. Faqat build va normalize mantig'i tekshirildi.
- **`ping()` → `/actuator/health`** — prod serverda bu manzil ochiq ekanligi tekshirilmadi. Ochiq bo'lmasa ham har qanday HTTP javob "internet bor" deb olinadi, faqat ulanish xatosi "yo'q" hisoblanadi.

---

## 11. Men tanlagan qarorlar

Bularni o'zgartirish mumkin:

| Masala | Qaror | Sababi / o'zgartirish yo'li |
|---|---|---|
| Bepul/pullik | 88 levelning hammasi bepul (`isFree: true`) | Hozirgi holat saqlanadi. Admin panelda levelni tahrirlab o'zgartirish mumkin |
| Reyting | O'yin va Ilk nutq yulduzlari reytingga qo'shiladi | Ular ham yulduzlar tarixiga yoziladi |
| Ilk nutq tartibi | Artikulatsion → nafas → barmoq → chiziq | Boshqa tartib kerak bo'lsa JSON'dagi `id` larni o'zgartiring |
| Eski JSON fayllar | `assets/games.json` va `assets/first_speech/*.json` APK'da qoldi | Kod ularni ishlatmaydi. O'chirish uchun alohida ayting |

---

## 12. Ishga tushirish tartibi

> **Muhim:** tartib buzilsa, yangi ilovada O'yinlar tabida "Mashg'ulotlar topilmadi" chiqadi.

1. **Backend**ni deploy qiling.
2. **Admin panel**ni deploy qiling.
3. Admin → "Ovoz mashqlari" → **O'yinlar** tabi → **"Bo'limni yaratish"** → bo'limga kiring → **"JSON import"** → `server_levels/games.json`.
4. **Ilk nutq** tabida xuddi shunday, `server_levels/first_speech.json` bilan.
5. Shundan keyingina **yangi APK**ni chiqaring.

Eski ilova versiyalariga ta'sir yo'q: ular O'yinlar va Ilk nutq uchun hali ham lokal JSON'ni ishlatadi.

---

## 13. Avvaldan bor muammolar

Bular o'zgarishlarimga bog'liq emas:

- `test/widget_test.dart` — Flutter'ning standart "Counter" shabloni. Ilovaga mos emas va o'zgarishlarimdan oldin ham yiqilardi.
- `pubspec.yaml` da mavjud bo'lmagan 3 ta papka ko'rsatilgan:
  - `assets/backround/hand_game/`
  - `assets/backround/cloud_game/`
  - `assets/game/arrow/`

---

## 14. Oldingi topshiriq: CV model natijasi hisoblanmasligi

**Muammo:** ba'zi qurilmalarda model 70–80 % aniqlik ko'rsatsa ham mashq bajarilgan deb hisoblanmasdi.

**Sabab** (`lib/ui/pages/cv_model/camera_page.dart`):
- qadam uchun 3 ta mos kadr kerak edi;
- ikki mos kadr orasida 600 ms dan ko'p o'tsa, yig'ilgan ovozlar o'chirilardi;
- kuchsiz qurilmalarda model GPU'siz ishlab, bitta natijani 700–1500 ms da beradi.

Natijada har bir yangi kadr oldingi ovozlarni o'chirib yuborardi va 3 ta kadr hech qachon yig'ilmasdi.

**Tuzatish:** kadrlar orasidagi haqiqiy vaqt o'lchanadi (o'rtacha qiymat):
- uzilish chegarasi = max(600 ms, o'rtacha oraliq × 2.5);
- oraliq 400 ms dan oshsa, kerakli kadrlar soni 3 dan 2 ga tushadi;
- kuchli qurilmalarda va ishonch chegaralarida (0.40 / 0.60) hech narsa o'zgarmadi.

**Tekshiruv:** `flutter analyze` toza. Real qurilmada sinalmagan.

---

## 15. O'zgargan fayllar ro'yxati

### Ilova (`logosmart`)

| Holat | Fayl |
|---|---|
| O'zgardi | `lib/core/network/api_service.dart` |
| O'zgardi | `lib/main.dart` |
| O'zgardi | `lib/ui/pages/cv_model/camera_page.dart` (14-bo'lim) |
| O'zgardi | `lib/ui/pages/games/alphabet_map/map_route_page.dart` |
| O'zgardi | `lib/ui/pages/games/alphabet_map/provider/level_provider.dart` |
| O'zgardi | `lib/ui/pages/main/firstspeech/StartSpeechPage.dart` |
| O'zgardi | `lib/ui/pages/main/main_page.dart` (izoh) |
| O'zgardi | `lib/ui/pages/profile/providers/profile_provider.dart` |
| O'chirildi | `lib/ui/pages/main/firstspeech/first_speech_categories_page.dart` |
| Yangi | `lib/core/network/network_status.dart` |
| Yangi | `lib/ui/pages/games/widgets/no_internet.dart` |
| Yangi | `server_levels/games.json`, `server_levels/first_speech.json` |
| Yangi | `test/level_sync_test.dart`, `test/map_offline_test.dart` |

### Backend (`logosmart-backend`)

| Holat | Fayl |
|---|---|
| O'zgardi | `voice/model/VoicePractice.java`, `voice/dto/VoicePracticeRequest.java`, `voice/service/VoicePracticeService.java` |
| O'zgardi | `stats/config/SectionUsageInterceptor.java`, `stats/service/UsageStatsService.java` |
| Yangi | `voice/model/PracticeCategory.java` |
| Yangi | `voice/dto/SectionResponse.java`, `voice/dto/AdminVoicePracticeResponse.java` |
| Yangi | `voice/service/SectionService.java` |
| Yangi | `voice/controller/SectionController.java`, `voice/controller/VoicePracticeAdminController.java` |
| Yangi | `ball/` — `UserBall`, `BallEvent`, DTO'lar, `BallService`, `BallController` |
| Testlar | `SecurityAccessTest`, `SectionUsageInterceptorTest` (kengaytirildi) |
| Testlar | `VoicePracticeCategoryTest`, `SectionServiceTest`, `SectionFlowMongoTest`, `BallServiceMongoTest`, `BallAndSectionApiTest` (yangi) |

### Admin panel (`logosmart_admin_vue`)

| Holat | Fayl |
|---|---|
| O'zgardi | `src/api/index.js` |
| O'zgardi | `src/views/voice/VoicePracticesView.vue` |
| O'zgardi | `src/views/voice/LevelsView.vue` |
| O'zgardi | `src/i18n/messages.js` |
