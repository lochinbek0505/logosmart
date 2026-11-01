# LogoSmart — to'liq kod auditi hisoboti

Sana: 2026-11-02 · Qamrov: `lib/` (≈149 Dart fayl, 31 000 qator), Android native qism

## Umumiy natija

| Ko'rsatkich | Audit oldidan | Auditdan keyin |
|---|---|---|
| `flutter analyze` — error / warning | 0 / 0 | 0 / 0 |
| `flutter analyze` — info | 127 | 121 |
| Unit/widget testlar | — | 41 ta o'tdi (`widget_test.dart` dan tashqari, pastga qarang) |
| Topilgan va tuzatilgan xatolar | — | **10 ta mantiq** + **12 ta responsivlik** |
| Tuzatilmagan, qaror talab qiladigan kuzatuvlar | — | 6 ta |

---

## 1. Mantiqiy xatolar (tuzatildi)

### 1.1 Chiqishda (logout) barcha sozlamalar o'chib ketardi — **jiddiy**
- **Joy:** `profile_provider.dart` → `signOutLocally`, `main.dart` → `_onSessionExpired`
- **Muammo:** `TokenStorage().clearAll()` secure storage'dagi **hamma** kalitlarni o'chiradi. Sozlamalar (mavzu, bildirishnoma ovozi, o'yin musiqasi, vibratsiya, mobil internetda yuklash) ham shu storage'da. Har logout yoki sessiya tugashida foydalanuvchi sozlamalari standartga qaytardi.
- **Yechim:** faqat auth kalitlarini o'chiradigan `deleteAuthData()` ishlatiladi.

### 1.2 O'yin ballari saqlanmasdi
- **Joy:** `level_provider.dart` → `addBall`
- **Muammo:** `_ball` faqat xotirada edi — ilova yopilganda 0 ga tushardi. Yutqazganda `addBall(-x)` ballni manfiy qilib yuborishi mumkin edi.
- **Yechim:** ball Hive (`_total_ball`) da saqlanadi, `bootstrap()` da yuklanadi, 0 dan pastga tushmaydi, logout'da tozalanadi.

### 1.3 Resurslarni yuklashda ikki parallel jarayon
- **Joy:** `resource_manager.dart` → `downloadCore`
- **Muammo:** yuklash ekrani `downloadCore()` ni ishlatayotganda "Hozircha ilovaga kirish" tugmasi yoki internet qaytishi `syncInBackground(force: true)` ni chaqirardi — bitta fayl guruhi ikki joydan yuklanib, progress bar "sakrab" turardi.
- **Yechim:** `downloadCore` ham `_syncing` qulfidan foydalanadi; ikkinchi chaqiruv birinchisi tugashini kutadi. Orqa fondagi (videolar, modellar) sinxronlash qulf bo'shagandan keyin boshlanadi — testda `clearAll` stsenariysi bilan tekshirildi.

### 1.4 Kamera mashqi qayta ochilganda buzilardi — **jiddiy**
- **Joy:** `start_text_page.dart` → `_onStartPressed`, `camera_page.dart`
- **Muammo:** `widget.data.exercise!.steps.removeAt(0)` provider keshidagi **asl** `LevelState` ro'yxatini o'zgartirardi. Natijada: (a) level ikkinchi marta ochilganda "about" intro chiqmasdi; (b) har ochilishda yana bir bosqich o'chib, oxiri `CameraPage` "Ma'lumotlar topilmadi!" derdi. Ovoz `null` bo'lsa `sound!` ilovani yiqitardi.
- **Yechim:** ro'yxat o'zgartirilmaydi; `CameraPage` birinchi "about" bosqichini o'zining nusxasida o'tkazib yuboradi. Ovoz bo'lmasa sahifa baribir ochiladi.

### 1.5 Ovoz ochilmasa o'yin qotib qolardi
- **Joy:** 7 ta o'yin (`find_image`, `train`, `cooking`, `hand`, `cloud`, `arrow`, `path`), `puzzle`, `camera_page`, `start_text_page` → `_playAudioAndWait`
- **Muammo:** `play()` xato bersa yoki `onPlayerComplete` hodisasi kelmasa (buzilgan/yuklanmagan fayl), `Completer` hech qachon tugamasdi — o'yin "ovoz chalinyapti" holatida abadiy bloklanib qolardi.
- **Yechim:** `try/catch` + 30 soniyalik `timeout`.

### 1.6 Yopilgan sahifada `setState`
- **Joy:** `cooking_page.dart` (`_processAcceptedItem`), `cloud_game_page.dart` (`_handleWrongAnswer`, muvaffaqiyat qismi)
- **Muammo:** STT/ovoz `await` dan keyin bola orqaga chiqib ketgan bo'lsa — "setState() called after dispose()" xatosi.
- **Yechim:** `mounted` tekshiruvi.

### 1.7 Xaritada "joriy level" animatsiyasi ko'chmasdi
- **Joy:** `level_button.dart`
- **Muammo:** pulsatsiya faqat `initState` da yoqilardi. Keyingi level ochilganda (tugmalar `ValueKey` bilan qayta yaratilmaydi) eski level pulsatsiya qilaverar, yangisi qilmas edi.
- **Yechim:** `didUpdateWidget` da yoqish/o'chirish.

### 1.8 Avatar saqlash natijasi kutilmasdi
- **Joy:** `avatar_selector_page.dart`
- **Muammo:** `updateProfile` kutilmasdan sahifa yopilardi — xato bo'lsa foydalanuvchi bilmas edi, tugmani ikki marta bosish ham mumkin edi.
- **Yechim:** so'rov kutiladi, loader ko'rsatiladi, faqat muvaffaqiyatda yopiladi.

### 1.9 Kichik xatolar
- `map_route_page.dart`: `_audioPlayer.dispose()` `super.dispose()` dan keyin edi; fon musiqasi xatosi ushlanmasdi.
- `api_service.dart` → `getUnreadNotificationsCount`: `response.data["count"]` son bo'lmasa `TypeError`.
- `train`, `sound`, `cloud` o'yinlarida eskirgan `onWillAccept/onAccept` → `onWillAcceptWithDetails/onAcceptWithDetails`.

---

## 2. Responsivlik xatolari (tuzatildi)

| # | Sahifa | Muammo | Yechim |
|---|---|---|---|
| 1 | `train_game_page.dart` | Qattiq `50.h` yuqori bo'shliq (notch ostida qolardi); 3 tadan ko'p rasm/vagon `Row` dan chiqib ketardi | `SafeArea`, `FittedBox(scaleDown)` |
| 2 | `sound_game_page.dart` | `50.h + 200.h + 50.h + 150.h` qattiq balandliklar — kichik ekranda variantlar pastdan chiqardi | `SafeArea`, `Flexible` rasm, `Spacer` |
| 3 | `breath_game.dart` | Qattiq `50.h` header | `SafeArea` |
| 4 | `puzzle_game_widget.dart` | Qism `180.w + 16` qattiq: `2×196 > 375` — tor ekranda qismlar ustma-ust | O'lcham ekran kengligidan hisoblanadi |
| 5 | `drag_drop_game_page.dart` | 4 tadan ko'p element yoki past ekranda ustunlar chiqib ketardi | `FittedBox(scaleDown)` |
| 6 | `arrow_game_page.dart` | Maydon balandligi `440.h`, radius esa `.w` da — planshet/keng ekranda harflar header ustiga chiqardi | Balandlik doiradan kam bo'lmaydi |
| 7 | `game_video_page.dart` | `160.h + 0.6·H + tugma` — past ekranda "Davom etish" ko'rinmasdi | Video `Expanded + FittedBox` |
| 8 | `forgot_password_page.dart` | `IntrinsicHeight` scroll'siz — klaviatura ochilganda "Bottom overflowed" | `LayoutBuilder + SingleChildScrollView` |
| 9 | `resource_download_page.dart` | Katta shriftda matnlar sig'masdi | `SingleChildScrollView` |
| 10 | `diagnostic_group_page.dart` | `60 + 200.h + 460.h` — ekrandan oshib ketardi | `SafeArea`, rasm `Expanded` |
| 11 | `diagnostic_start/end_page.dart` | Avatar `width: 80.h, height: 80.w` (almashgan) — cho'zilardi | `80.w × 80.w` |
| 12 | `advise_alphabet_page.dart` | Karta `height: 115` qattiq, yorliq `100×25` qattiq, matn `Expanded` siz | `minHeight`, padding, `Expanded` |
| + | `alphabet_page.dart`, `first_speech_categories_page.dart` | Qattiq `60px` yuqori bo'shliq | `SafeArea` |

---

## 3. Tekshirilgan va to'g'ri ishlayotgan qismlar

- **Yuklab olish mantig'i** (`ResourceManager`): `.part` + `Range` bilan davom ettirish, sha256 tekshiruvi, 5 marta qayta urinish, bo'sh joy tekshiruvi (Android `StatFs`), Wi-Fi/mobil siyosati, `clearAll` paytidagi "generation" himoyasi — yaxshi yozilgan, testlar bilan qoplangan.
- **Yuklangan resursdan foydalanish** (`AppImage`, `AppLottie`, `appAudioSource`, `appVideoController`, `appModelPath`): avval qurilmadagi fayl, bo'lmasa APK asset; buzilgan fayl `reportBroken` orqali qayta yuklanadi. Level ochilishidan oldin `prepareLevelResources` yetishmayotgan fayllarni yuklaydi.
- **Sozlamalar:** barcha switch'lar saqlanadi va darhol qo'llanadi (mavzu, push token backend bilan sinxron).
- **Yulduzlar:** serverga yuborilmagan natijalar navbatda saqlanadi va keyin yuboriladi (offline'da yo'qolmaydi).
- **Obuna/to'lov:** balans tekshiruvi, promokod turlari, faol rejadan qisqasini tanlashni bloklash — to'g'ri.

---

## 4. Tuzatilmagan — qaror talab qiladigan kuzatuvlar

1. **STT API kaliti kod ichida** (`uzbekvoice_stt_service.dart`). APK'dan oson olinadi va boshqalar sizning hisobingizdan foydalanishi mumkin. Tavsiya: STT so'rovini backend orqali proksi qilish.
2. **Ball serverga yuborilmaydi** — `_syncScoreToBackend` / `_fetchScoreFromBackend` bo'sh. Hozir ball faqat qurilmada saqlanadi (1.2 tuzatishdan keyin), boshqa qurilmada ko'rinmaydi. Backend endpoint kerak.
3. **Ishlatilmayotgan fayllar** (hech qayerdan ochilmaydi): `society/*`, `profile/MyChildrenPage.dart`, `profile/MyExpertPage.dart`, `main/soundpracrice/*`, `games/test_page.dart`, `games/keyboard_game_page.dart`, `start/splash_screen.dart`, `start/onboard_*`, `diagnostic/ResultPage.dart`, `auth/register_survey_page.dart` (bo'sh). `test_page.dart` APK'da yo'q `assets/animation/candle.json` ni chaqiradi. O'chirish tavsiya etiladi.
4. **Video darslar sahifasi qolip holatida** — `VideosPape.dart` 5 ta "Dars nomi" ko'rsatadi, hech narsa o'ynatmaydi; "Qoralamalar" bo'sh.
5. **Diagnostika ovozi** — `voice_diagnostic_page.dart` `AssetSource("sound/diagnostic/$voiceFile")` ni to'g'ridan-to'g'ri ishlatadi; APK'da faqat 3 ta fayl (`sabzi`, `asal`, `gilos`). Backend to'liq URL bersa muammo yo'q, fayl nomi bersa — ovoz chiqmaydi.
6. **`test/widget_test.dart`** — Flutter'ning standart "Counter" shabloni, ilovaga aloqasi yo'q va doim yiqiladi. O'chirish yoki haqiqiy smoke-test bilan almashtirish kerak.

---

## 5. Tekshiruv
```
flutter analyze   → 0 error, 0 warning (121 info: nomlash/style)
flutter test      → resource_manager, ui_overflow, voice_match, voice_targets,
                    profile_billing: 41/41 o'tdi
```
Qurilmada ishga tushirib sinalmadi — UI o'zgarishlarini kichik (≈5") va katta ekranli telefonda, katta shrift bilan ko'rib chiqish tavsiya etiladi.
