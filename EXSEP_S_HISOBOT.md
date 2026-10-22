# `assets/exsepS.json` — S tovushi bo'yicha hisobot

**Sana:** 2026-10-22
**Yaratilgan fayl:** `assets/exsepS.json` (58 ta bosqich, id 1–58)
**Ulash:** `level_provider.dart` → `'S': 'assets/exsepS.json'`, `pubspec.yaml` ga qo'shildi. Xaritada **S** harfi bosilganda ochiladi.

## Umumiy xulosa

| Holat | Soni |
|---|---|
| ✅ To'liq tayyor (kerakli resurs bilan) | 48 |
| ⚠️ Ishlaydi, lekin vaqtincha/o'xshash resurs qo'yilgan | 10 |
| **Jami** | **58** |

> Belgilar: ✅ tayyor · ⚠️ resurs yo'qligi sababli o'rnini bosuvchi qo'yilgan (almashtirish kerak) · 🛑 siz ro'yxatda `s_assets` dan olinadigan deb belgilagan.

- JSON dagi **barcha** `assets/...` yo'llari diskda mavjudligi skript bilan tekshirildi — topilmagan fayl yo'q.
- `flutter analyze` o'zgargan Dart fayllarda yangi xato bermadi. Ilova qurilmada ishga tushirib sinalmadi.

> **Raqamlash haqida:** ro'yxatda `31` ikki marta yozilgan (31 echki chiziqli o'yin va 31 koptok nafas). Shuning uchun koptok **32** bo'ldi, undan keyingi barcha bosqichlar **+1** ga surildi. Jadvalda "Ro'yxat №" ustuni sizning raqamingiz, "id" — JSON dagi raqam.

---

## To'liq jadval

| id | Ro'yxat № | Mashq/o'yin | JSON dagi turi va resurs | Holat | Izoh |
|----|----|---|---|---|---|
| 1 | 1 | 👅 Og'iz: tilni chiqarish | exercise `tilni_chiqarish.mp4` | ✅ | |
| 2 | 2 | 🫁 Nafas: shar | breath `redBallon` | ✅ | |
| 3 | 3 | 👅 Og'iz: o'ng-chap | exercise `ong_chap.mp4` | ✅ | |
| 4 | 4 | 🎁 S li bo'g'inni top, tipratikan-savat (sa, za, sha, ya), mikrofonsiz | wolf_game: `tipratikan`, 4 ta `savat`, fon `ormon`; to'g'risi **SA** | ✅ | Resurs `s_assets/4. tipratikan` dan |
| 5 | 5 | 🫁 Nafas: raketa | breath `rocket` | ✅ | |
| 6 | 6 | 🤟 Barmoq: podarkali (sovg'a qutisi) | hand_game `hand_1–4` | ✅ | |
| 7 | 7 | 📽 S tovushi videosi (real qizcha) | video `map_video/s.mp4` | ✅ | `VIDEOLAR/7.S.mp4` |
| 8 | 8 | 〽️ To'rtburchak tepadan: Sssss, timsoh | path_game `Ssss`, rasm `ajdar`, fon `dragon` | ⚠️ | Timsoh rasmi va sof "Sssss" ovozi yo'q → `ajdar` + `SSSSA.mp3` |
| 9 | 9 | 👅 Og'iz: tish-lab | exercise `tish_lab.mp4` | ✅ | |
| 10 | 10 | 🤡 Qutili o'yin (tana harakati) | hand_game `face_5–8` | ✅ | L dagi bilan bir xil |
| 11 | 11 | 🫁 Nafas: tanga | breath `coins` | ✅ | |
| 12 | 12 | 〽️ Zigzag tepadan: Asssss, sigir | path_game `Asss`, `ASSSS.mp3`, rasm `sigir` | ✅ | Sigir rasmi `s_assets/29` dan |
| 13 | 13 | 👄 Lab mashqi 4 talik | hand_game `lib_1–4` | ✅ | |
| 14 | 14 | 🌄 S li hasharotni top va ayt (suvarak) 🛑 | find_image: chumoli, **suvarak**, xonqizi, qo'ng'iz; fon `yolak_hasharot` | ✅ | `s_assets/14.sqatnashgan` |
| 15 | 15 | 📹 "As as atlas" | video `as_atlas.mp4` | ✅ | |
| 16 | 16 | 👅 Og'iz: tepa-past (5 mashq) | exercise `til_ogiz_tashqari_tepa_past.mp4` | ✅ | |
| 17 | 17 | 〽️ Yo'l: Ooooos, yo'lbars | path_game `Ooos`, `OSSSS.mp3`, rasm `tiger` | ✅ | |
| 18 | 18 | 🖇 Tortib qo'shish: as os us is es 🛑 | arrow, markaz **S**, 5 tugun: A, O, U, I, E | ✅ | `ASSSS/OSSSS/USSSS/ISSSS` + `es.mp3` (s_assets/28) |
| 19 | 19 | 🫁 Nafas: gul kala | breath `flower2` | ✅ | |
| 20 | 20 | 📹 "Os os gilos" | video `os_gilos.mp4` | ✅ | |
| 21 | 21 | 🧩 Pazl: ko'p-kam 🛑 | puzzle_game: savat–savatlar, gilos–giloslar; fon `bog` | ⚠️ | Ro'yxatda "ananas–ananaslar", resursda **gilos** bor edi — gilos qo'yildi |
| 22 | 22 | 〽️ To'lqin: Uuuuus, sichqon | path_game `Uuus`, `USSSS.mp3`, rasm `squirrel` | ⚠️ | Sichqon rasmi yo'q → olmaxon |
| 23 | 23 | 🫁 Nafas: dron | breath `drone` | ✅ | |
| 24 | 24 | 📹 "Us us avtobus" | video `us_avtobus.mp4` | ✅ | |
| 25 | 25 | 🤙 Barmoq: quticha rasm (4 lik) | hand_game `hand_5–8` | ✅ | |
| 26 | 26 | 〽️ Spiral: Eeees, timsoh | path_game `Eees`, rasm `ajdar` | ⚠️ | "ESSS" ovozi yo'q → `ISSSS.mp3`; timsoh → `ajdar` |
| 27 | 27 | 📹 "Es es tort kes" | video `es_tort_kes.mp4` | ✅ | |
| 28 | 28 | S qatnashmagan bo'g'inni top, sut-stakan, mikrofonsiz 🛑 | wolf_game: `sut`, 4 ta `stakan` (as, os, **esh**, es); fon `oshxona` | ✅ | Ro'yxatda "as, sa, is, ish", papkada as/os/es/esh bor edi — shular ishlatildi |
| 29 | 29 | 🌄 S so'z boshida — rasmni top 🛑 | find_image: ot, echki, **sigir**, qo'y | ✅ | `s_assets/29. ssozboshi` |
| 30 | 30 | 🖇 Tortib qo'shish: sa so su si se 🛑 | arrow, markaz **S**, 4 tugun: A, O, U, I | ⚠️ | "se" ovozi yo'q — E tugun qo'yilmadi |
| 31 | 31 | 〽️ To'lqin: Ssssa, echki | path_game `Sssa`, `SSSSA.mp3`, rasm `echki` | ✅ | |
| 32 | 31 (2) | 🫁 Nafas: koptok | breath `ball` | ✅ | |
| 33 | 32 | ☁️ Bulutli mashq: sa so su es… 🛑 | cloud: sa, as, so, os, su, us, si, is, es | ✅ | Ovozlar `s_assets` (4, 28, 45) va `sound/arrow` dan |
| 34 | 33 | 📹 "Sa sa sa, sariq ko'ylak" 🛑 | video `s.mp4` (vaqtincha) | ⚠️ | **Video `VIDEOLAR` da yo'q** |
| 35 | 34 | 👅 Og'iz: ichida tepa-past (7 mashq) | exercise `til_ogiz_ichida_tepa_past.mp4` | ✅ | |
| 36 | 35 | 🤘 Barmoq 4 talik | hand_game `hand_9–12` | ✅ | |
| 37 | 36 | 〽️ Zigzag chapdan: Ssssso, suvarak | path_game `Ssso`, `SSSSO.mp3`, rasm `suvarak` | ✅ | Zigzag L shablonidan chapdan boshlanadigan qilib aylantirildi |
| 38 | 37 | 🥘 Yegulikni yedir 🛑 | cooking: salat, sabzi, asal, pitsa, gilos | ✅ | JSON tayyor; ro'yxatdagi "mikrofonda muammo" kodiga tegilmadi |
| 39 | 38 | 📹 "So so somsa" | video `so_somsa.mp4` | ✅ | |
| 40 | 39 | 🫁 Nafas: qor | breath `snow` | ✅ | |
| 41 | 40 | 🌄 S so'z o'rtasida — rasmni top 🛑 | find_image: qoshiq, **kosa**, likopcha, piyola; fon `oshxona` | ✅ | |
| 42 | 41 | 🤡 Emotsiya (qutili o'yin) 🛑 | hand_game `face_1–4` | ✅ | Alohida resurs papkasi yo'q edi, mavjud yuz rasmlari |
| 43 | 42 | 👅 Og'iz: otcha (6 mashq) | exercise `otchaa.mp4` | ✅ | |
| 44 | 43 | 〽️ Yo'l: Sssssu, timsoh | path_game `Sssu`, `SSSSU.mp3`, rasm `ajdar` | ⚠️ | Timsoh rasmi yo'q → `ajdar` |
| 45 | 44 | 📹 "Sin sin apelsin" | video `sin_apelsin.mp4` | ✅ | |
| 46 | 45 | So'z tuz: so-ya-bon (raketa kabi) 🛑 | sound_game: SO _ BON, variantlar SA / **YA** / ZA; rasm `soyabon` | ✅ | |
| 47 | 46 | 🫁 Nafas: sham | breath `candle` | ✅ | |
| 48 | 47 | 👄 Lab mashqi quticha rasm 🛑 | hand_game `lib_5–8` | ✅ | |
| 49 | 48 | 〽️ To'rtburchak pastdan: Ssssi, sichqon | path_game `Sssi`, `SSSSI.mp3`, rasm `squirrel` | ⚠️ | Sichqon o'rniga olmaxon (22 bilan bir xil) |
| 50 | 49 | 🫁 Nafas: gul | breath `flower` | ✅ | |
| 51 | 50 | 👅 Og'iz: o'ng-chap | exercise `ong_chap.mp4` | ✅ | |
| 52 | 51 | 〽️ Yo'l tepaga: Sssss, sigir | path_game `Ssss`, rasm `sigir` | ⚠️ | Ovoz 8-bosqichdagi kabi `SSSSA.mp3` (sof "Sssss" yo'q) |
| 53 | 52 | 📹 Sss o'rgatgan real qizcha | video `s.mp4` | ✅ | |
| 54 | 53 | 🖇 Vagon: 1 sut, 2 savat, 3 soyabon 🛑 | train_game: `sut_1`, `savat_2`, `soyabon_3`; fon `vagon` | ✅ | |
| 55 | 54 | 🫁 Nafas: kapalak | breath `butterfly` | ✅ | |
| 56 | 55 | 👅 Og'iz: murabbo (9 mashq) | exercise `ogiz_ichida_aylantirish.mp4` | ✅ | |
| 57 | 56 | 🌄 S so'z oxirida — rasmni top 🛑 | find_image: nok, uzum, **kakos**, banan; fon `bog` | ✅ | |
| 58 | 57 | 🤘 Barmoq 4 talik (ikonkalar takrorlanmasin) 🛑 | hand_game `hand_2, 7, 12, 9` | ⚠️ | Yangi barmoq rasmlari yo'q — 12 ta `hand_*` hammasi ishlatilgan, takror bor |

> ⚠️ bosqichlar: 8, 21, 22, 26, 30, 34, 44, 49, 52, 58.

---

## Kerak bo'ladigan resurslar (⚠️ larni yopish uchun)

| # | Nima kerak | Qaysi bosqich (id) |
|---|---|---|
| 1 | **"Sa sa sa, sariq ko'ylak" videosi** | 34 |
| 2 | Sof **"Sssss"** ovozi | 8, 52 |
| 3 | **"Eeees"** ovozi | 26 |
| 4 | **"se"** (SSSSE) ovozi | 30 |
| 5 | **Timsoh** rasmi | 8, 26, 44 |
| 6 | **Sichqon** rasmi | 22, 49 |
| 7 | Ananas / ananaslar rasm + ovoz (agar gilos o'rniga kerak bo'lsa) | 21 |
| 8 | Yangi 4 ta barmoq mashqi rasmi | 58 |

Resurs kelgach faqat `assets/exsepS.json` dagi tegishli yo'lni almashtirish yetarli.

---

## Kod o'zgarishlari

| Fayl | O'zgarish |
|---|---|
| `lib/ui/pages/games/alphabet_map/provider/level_provider.dart` | `soundLevelFiles` ga `'S': 'assets/exsepS.json'` qo'shildi |
| `pubspec.yaml` | `assets/exsepS.json` qo'shildi |
| `lib/ui/pages/games/train_game/train_game_page.dart` | Fon rasmi endi JSON dagi `background_image` dan olinadi (bo'lmasa eski `fon_q.webp`) — vagon o'yini o'z fonini ko'rsatishi uchun |

## Resurslarni ko'chirish

`s_assets/` dan `assets/` ichidagi o'yin turiga mos papkalarga ko'chirildi. Nomlar kichik harf, lotin, probelsiz (`_`), apostrofsiz qilindi.

| Tur | Soni | Ishlov |
|---|---|---|
| Rasmlar (`.png` → `.webp`) | 45 | `cwebp -q 80`; 1536px ovqat rasmlari 512px ga kichraytirildi |
| Audio (`.mp3`) | 52 | Nomi o'zgartirilib nusxalandi |
| Videolar (`.mp4`) | 7 | H.264, CRF 26, kengligi max 1080px, AAC 96k |

**Video hajmlari:**

| Manba | Yangi fayl | Oldin → Keyin |
|---|---|---|
| `7.S.mp4` | `videos/map_video/s.mp4` | 29 MB → 5.0 MB |
| `As atlas.mp4` | `as_atlas.mp4` | 3.2 MB → 0.3 MB |
| `Os os gilos.mp4` | `os_gilos.mp4` | 15 MB → 2.0 MB |
| `Us us us aftobus.mp4` | `us_avtobus.mp4` | 7.9 MB → 2.0 MB |
| `es es tortni kes.mp4` | `es_tort_kes.mp4` | 6.4 MB → 2.0 MB |
| `So so somsa.mp4` | `so_somsa.mp4` | 19 MB → 2.0 MB |
| `Sin:apelsin.mp4` | `sin_apelsin.mp4` | 6.6 MB → 1.0 MB |

**Nomlash qoidasi (to'qnashuvlar):**
- Mavjud fayl bilan bir xil nom bo'lsa `_s` qo'shildi: `chumoli_s`, `qongiz_s`, `gilos_s`.
- macOS da `SA.mp3` va `sa.mp3` bir fayl hisoblanadi, shuning uchun tipratikan ovozlari `tipratikan_sa/za/sha/ya.mp3` deb nomlandi.
- Start ovozlari: `s_hasharot_start`, `s_boshida_start`, `s_ortasida_start`, `s_oxirida_start`, `tipratikan_start`, `sut_start`, `savat_start`, `soyabon_start`, `yegulik_start`, `s_train_start`.

---

## Qolgan ishlar

- `s_assets/` papkasi o'chirilmadi (videolarning siqilmagan asl nusxalari bor). Kerak bo'lmasa o'chirish mumkin.
- Git da `assets/sound/cooking/Yeguliklarni ustiga bos nomini ayt va menga ber.mp3` `AD` holatda (indeksga qo'shilgan, diskdan o'chirilgan). Endi uning o'rniga `sound/cooking/yegulik_start.mp3` ishlatiladi — indeksdan olib tashlash kerak (`git rm --cached`).
- 38-bosqich (yegulik) dagi mikrofon muammosi alohida tekshirilishi kerak.
- O'zgarishlar commit qilinmadi.
