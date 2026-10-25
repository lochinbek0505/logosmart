# `assets/exsepSH.json` — Sh tovushi bo'yicha hisobot

**Sana:** 2026-10-26
**Yaratilgan fayl:** `assets/exsepSH.json` (58 ta bosqich, id 1–58, ro'yxat raqami = id)
**Ulash:** `level_provider.dart` → `'Sh': 'assets/exsepSH.json'`, `pubspec.yaml` ga qo'shildi, `alphabet_page.dart` va `advise_alphabet_page.dart` ga **Sh** kartasi qo'shildi (K dan keyin).

- JSON dagi barcha 225 ta `assets/...` yo'li diskda borligi va papkalari `pubspec.yaml` da borligi skript bilan tekshirildi.
- `flutter analyze` o'zgargan Dart fayllarda yangi xato bermadi. Ilova qurilmada ishga tushirib sinalmadi.

> Belgilar: ✅ tayyor · ⚠️ ishlaydi, lekin taxmin qilingan / resurs yetishmaydi.

## To'liq jadval

| id | Mashq/o'yin | JSON dagi turi va resurs | Holat | Izoh |
|----|---|---|---|---|
| 1 | 👅 Og'iz: tilni chiqarish | exercise `tilni_chiqarish.mp4` | ✅ | |
| 2 | 🫁 Nafas: kapalak | breath `butterfly` | ✅ | |
| 3 | 👅 Og'iz: o'ng-chap | exercise `ong_chap.mp4` | ✅ | |
| 4 | 🎁 Sh li bo'g'inni top, toshbaqa–olma, mikrofonsiz | wolf_game: `toshbaqa`, 4 ta `olma` (sa, za, **sha**, ja); fon `daraxtzor` | ⚠️ | Ro'yxatda "ya", papkada `ja.mp3` — shu qo'yildi |
| 5 | 🫁 Nafas: qor | breath `snow` | ✅ | |
| 6 | 🤟 Barmoq: podarkali | hand_game `hand_1–4` | ✅ | |
| 7 | 📽 Sh tovushi videosi (real qizcha) | video `sh.mp4` | ✅ | |
| 8 | 〽️ To'lqin tepadan: Aaaash, tipratikan | path_game `Aaash`, `ASHSHSH.mp3`, fon `yolak_hasharot` | ✅ | |
| 9 | 👅 Og'iz: tish-lab | exercise `tish_lab.mp4` | ✅ | |
| 10 | 🤡 Qutili o'yin | hand_game `face_5–8` | ✅ | |
| 11 | 🫁 Nafas: gul kala | breath `flower2` | ✅ | |
| 12 | 〽️ To'rtburchak pastdan: Ooosh, shilliqqurt | path_game `Ooosh`, `OSHSHSH.mp3`, fon `yolak_hasharot` | ✅ | |
| 13 | 👄 Lab mashqi 4 talik | hand_game `lib_1–4` | ✅ | |
| 14 | 🌄 Sh qatnashgan hayvon (tipratikan, olmaxon, quyon, **toshbaqa**) | find_image; fon `yolak_hasharot` | ⚠️ | **Hayvon nomlarining ovozlari papkada yo'q** — ovozsiz qo'yildi (bosilganda darrov mikrofon yoqiladi) |
| 15 | 📹 "Esh esh esh, doim oling besh" | video `esh_besh.mp4` | ✅ | |
| 16 | 👅 Og'iz: tepa-past (5 mashq) | exercise `til_ogiz_tashqari_tepa_past.mp4` | ✅ | |
| 17 | 〽️ Yo'l tepa o'ngdan: Uuush, toshbaqa | path_game `Uuush`, `USHSHSH.mp3`, fon `paint/utloq` | ✅ | |
| 18 | 🖇 Unlilardan Sh ga: ash osh ush ish esh | arrow, markaz **Sh**, 5 tugun A, O, U, I, E | ✅ | E uchun S dagi `wolf_game/esh.mp3` |
| 19 | 🫁 Nafas: shar | breath `redBallon` | ✅ | |
| 20 | 📹 "Ush ush ush, osmonda uchadi qush" | video `ush_qush.mp4` | ✅ | |
| 21 | 🧩 Pazl: tosh–toshlar, qush–qushlar | puzzle_game; fon `puzzle_game/dala` | ✅ | |
| 22 | 〽️ Zigzag tepadan: Iiiish, quyon | path_game `Iiish`, `ISHSHSH (2).mp3`, fon `yolak_hasharot` | ✅ | |
| 23 | 🫁 Nafas: gul | breath `flower` | ✅ | |
| 24 | 📹 "O'sh o'sh o'sh, savat ichi bo'sh" | video `osh_bosh.mp4` | ✅ | |
| 25 | 🤙 Barmoq: quticha rasm (4 lik) | hand_game `hand_5–8` | ✅ | |
| 26 | 〽️ Pastdan yo'l: Shshshsh, sher | path_game `Shsh`, yangi `SHSHSHSH.mp3`, fon `savanna_k` | ✅ | |
| 27 | Sh qatnashmagan bo'g'inni top, sichqon–pishloq, mikrofonsiz | wolf_game: `sichqon`, 4 ta `pishloq` (ish, **os**, osh, shu); fon `dala` | ⚠️ | Ro'yxatda "ash, sha, ish, is", papkada `ish, os, osh, shu` bor — shular, to'g'risi **OS** |
| 28 | 🌄 Sh so'z boshida (**shim**, ko'ylak, kastyum, paypoq) | find_image; fon `gardirop` | ✅ | |
| 29 | 📹 "Osh osh, yuzimizda bordir qosh" | video `osh_qosh.mp4` | ✅ | |
| 30 | 🖇 Undoshdan Sh: sha sho shu shi she | arrow, markaz **Sh**, 4 tugun A, O, U, I | ⚠️ | "she" (`SHSHSHE`) ovozi yo'q — E tugun qo'yilmadi |
| 31 | 〽️ Spiral: Shshsha, qush | path_game `Shaa`, `SHSHSHA.mp3`, fon `osmon` | ✅ | |
| 32 | 🫁 Nafas: sham | breath `candle` | ✅ | |
| 33 | ☁️ Bulutli mashq | cloud: sha, ash, sho, osh, shu, ush, shi, ish, esh | ✅ | |
| 34 | 📹 "Ish ish ish, kuzdan keyin kelar qish" | video `ish_qish.mp4` | ✅ | |
| 35 | 👅 Og'iz: ichida tepa-past (7 mashq) | exercise `til_ogiz_ichida_tepa_past.mp4` | ✅ | |
| 36 | 🤘 Barmoq 4 talik | hand_game `hand_9–12` | ✅ | |
| 37 | 〽️ Zigzag tepadan: Shshsho, shilliqqurt | path_game `Shoo`, `SHSHSHO.mp3`, fon `yolak_hasharot` | ✅ | 22 dan farqli bo'lishi uchun ko'zgu qilindi |
| 38 | 🥘 Yegulikni yedir (shaftoli, shokolad, shirinlik, sho'lg'om, sho'rva) | cooking; fon `cooking`, oshpaz `chef_girl` | ⚠️ | Papkadagi `oshxona fon.jpg` yotiq (2000×1121) — tik ekranda cho'zilib ketadi, shuning uchun mavjud `cooking.webp` qo'yildi. Sho'rva uchun `.jpg` (oq fonli) o'rniga mavjud shaffof `shorva.webp`. Ro'yxatdagi "mikrofonda muammo" kodiga tegilmadi |
| 39 | 📹 Sh real qizcha | video `sh.mp4` | ✅ | 7 bilan bir xil |
| 40 | 🫁 Nafas: dron | breath `drone` | ✅ | |
| 41 | 🌄 Sh so'z o'rtasida (pichoq, **qoshiq**, kapkir, sanchqi) | find_image; fon `find_image/oshxona` | ✅ | Ro'yxatda "S tovushi" deb yozilgan — Sh deb olindi |
| 42 | 🤡 Emotsiya | hand_game `face_1–4` | ✅ | |
| 43 | 👅 Og'iz: otcha (6 mashq) | exercise `otchaa.mp4` | ✅ | |
| 44 | 〽️ Yo'l tepadan chapdan: Shshshu, toshbaqa | path_game `Shuu`, `SHSHSHU.mp3`, fon `paint/utloq` | ✅ | |
| 45 | 📹 "Sha sha sha, osmonda uchar pasha" | video `sha_pasha.mp4` | ✅ | |
| 46 | So'z tuz: SHO–KO–LAD | sound_game: SHO _ LAD, variantlar KA / **KO** / TA; rasm `shokolad` | ⚠️ | Noto'g'ri variantlar (KA, TA) ro'yxatda yo'q edi |
| 47 | 🫁 Nafas: tanga | breath `coins` | ✅ | |
| 48 | 👄 Lab mashqi quticha rasm | hand_game `lib_5–8` | ✅ | |
| 49 | 〽️ To'lqin tepadan: Shshsho, mushuk | path_game `Shoo`, `SHSHSHO.mp3`, fon `utloq_kichkina` | ⚠️ | Zip nomida "sheeee", ro'yxatda "shshsho" — "she" ovozi yo'q, **SHO** qo'yildi |
| 50 | 🫁 Nafas: raketa | breath `rocket` | ✅ | |
| 51 | 👅 Og'iz: o'ng-chap | exercise `ong_chap.mp4` | ✅ | |
| 52 | 〽️ To'rtburchak tepadan: Shshshi, sher | path_game `Shii`, `SHSHSHI.mp3`, fon `savanna_k` | ✅ | |
| 53 | 📹 "Sho sho sho, mening ismim Oyposho" | video `sho_oyposho.mp4` | ✅ | |
| 54 | 🖇 Vagon: 1 tish, 2 qoshiq, 3 shokolad | train_game; fon `vagon` | ✅ | |
| 55 | 🫁 Nafas: koptok | breath `ball` | ✅ | |
| 56 | 👅 Og'iz: murabbo (9 mashq) | exercise `ogiz_ichida_aylantirish.mp4` | ✅ | |
| 57 | 🌄 Sh so'z oxirida (guruch, loviya, **mosh**, noxat) | find_image; fon `find_image/tuproq` | ✅ | |
| 58 | 🤘 Barmoq 4 talik (takrorlanmasin) | hand_game `hand_2, 7, 12, 9` | ⚠️ | S/K dagi kabi: yangi barmoq rasmlari yo'q |

> ⚠️ bosqichlar: 4, 14, 27, 30, 38, 46, 49, 58.

## Kerak bo'ladigan resurslar

| # | Nima kerak | Qaysi bosqich |
|---|---|---|
| 1 | **tipratikan, olmaxon, quyon, toshbaqa** so'zlari ovozi | 14 |
| 2 | **"she"** (`SHSHSHE`) ovozi | 30, 49 |
| 3 | Yegulik o'yini uchun **tik** (portret) oshxona foni | 38 |
| 4 | **Sh harfi rasmi** (`assets/alphabet/sh.webp`) — hozir vaqtinchalik pushti "Sh" | Alifbo kartasi |
| 5 | Yangi 4 ta barmoq mashqi rasmi | 58 |

## Kod o'zgarishlari

| Fayl | O'zgarish |
|---|---|
| `level_provider.dart` | `'Sh': 'assets/exsepSH.json'` |
| `pubspec.yaml` | `assets/exsepSH.json` |
| `alphabet_page.dart`, `advise_alphabet_page.dart` | Sh kartasi |
| `find_image_game_page.dart` | Rasmning `sound` qiymati bo'sh bo'lsa ovoz chalinmaydi (avval o'yin qotib qolardi) — 14-bosqich uchun |

## Resurslarni ko'chirish

- 80 ta rasm/audio `Sh OYIN HAMMASI/` dan (chiziqli o'yinlar zip lardan ochib) `assets/` ga ko'chirildi, jami 2.1 MB. 1254–1394px li 13 ta rasm 512px ga kichraytirildi.
- Loyihada aynan bor bo'lganlar qayta qo'shilmadi: `sher_k`, `mushuk`, `qoshiq` rasmi, fonlar (`yolak_hasharot`, `gardirop`, `paint/utloq`, `utloq_kichkina`, `savanna_k`, `find_image/oshxona`, `sound_game/xona`, `vagon`), `sound/arrow/*SHSHSH*`, cooking ovozlari (shaftoli, shokolad, sho'rva), start ovozlari (pazl, poyezd, yegulik, so'z tuz).

**Videolar** (H.264, CRF 26, max 1080px, AAC 96k) — 62 MB → 16 MB:

| Manba | Yangi fayl |
|---|---|
| `Sh.mp4` | `sh.mp4` (29 MB → 5 MB) |
| `Esh esh esh doim oling besh.mp4` | `esh_besh.mp4` |
| `Ush ush ush osmonda uchadi qush.mp4` | `ush_qush.mp4` |
| `O'sh o'sh o'sh savat ichi bo'sh.mp4` | `osh_bosh.mp4` |
| `Osh osh yuzimizda bordir qosh.mp4` | `osh_qosh.mp4` |
| `Ish ish ish kuzdan keyin kelar qish.mp4` | `ish_qish.mp4` |
| `Sha sha sha osmonda uchar pasha.mp4` | `sha_pasha.mp4` |
| `sho sho sho mening ismim oyposho.mp4` | `sho_oyposho.mp4` |

Asl videolar `Sh OYIN HAMMASI/videolar_asl/` ga ko'chirildi va git indeksidan olindi.

O'zgarishlar commit qilinmadi.
