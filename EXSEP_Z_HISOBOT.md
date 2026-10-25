# `assets/exsepZ.json` — Z tovushi bo'yicha hisobot

**Sana:** 2026-10-26
**Yaratilgan fayl:** `assets/exsepZ.json` (58 ta bosqich, id 1–58, ro'yxat raqami = id)
**Ulash:** `level_provider.dart` → `'Z': 'assets/exsepZ.json'`, `pubspec.yaml`, `alphabet_page.dart` va `advise_alphabet_page.dart` ga **Z** kartasi (Sh dan keyin). Test uchun Z ham `_testAllOpenSounds` ga qo'shildi — hamma bosqich ochiq.

- JSON dagi barcha 225 ta `assets/...` yo'li diskda va papkalari `pubspec.yaml` da borligi skript bilan tekshirildi.
- `flutter analyze` yangi xato bermadi. Ilova qurilmada sinalmadi.

> Belgilar: ✅ tayyor · ⚠️ ishlaydi, lekin taxmin qilingan / resurs yetishmaydi.

## To'liq jadval

| id | Mashq/o'yin | JSON dagi turi va resurs | Holat | Izoh |
|----|---|---|---|---|
| 1 | 👅 Og'iz: tilni chiqarish | exercise `tilni_chiqarish.mp4` | ✅ | |
| 2 | 🫁 Nafas: dron | breath `drone` | ✅ | |
| 3 | 👅 Og'iz: o'ng-chap | exercise `ong_chap.mp4` | ✅ | |
| 4 | 🎁 Z li bo'g'inni top, uzum–yashik (sa, **za**, sha, ja), mikrofonsiz | wolf_game: `uzum`, 4 ta `yashik`; fon `utloq_kichkina` | ✅ | |
| 5 | 🫁 Nafas: gul | breath `flower` | ✅ | |
| 6 | 🤟 Barmoq: podarkali | hand_game `hand_1–4` | ✅ | |
| 7 | 📽 Z tovushi videosi (real qizcha) | video `z.mp4` | ✅ | |
| 8 | 〽️ To'rtburchak tepadan: Aaaaz, to'ng'iz | path_game `Aaaz`, `AZZZZZ.mp3`, fon `savanna_k` | ✅ | |
| 9 | 👅 Og'iz: tish-lab | exercise `tish_lab.mp4` | ✅ | |
| 10 | 🤡 Qutili o'yin | hand_game `face_5–8` | ✅ | |
| 11 | 🫁 Nafas: koptok | breath `ball` | ✅ | |
| 12 | 📹 "Az az az, mening dadam oshpaz" | video `az_oshpaz.mp4` | ✅ | |
| 13 | 〽️ Zigzag tepadan: Ooooz, g'oz | path_game `Oooz`, `OZZZZZ.mp3`, fon `utloq_kichkina` | ✅ | |
| 14 | 👄 Lab mashqi 4 talik | hand_game `lib_1–4` | ✅ | |
| 15 | 🌄 Z qatnashgan hayvon (**zebra**, sher, fil, bo'ri) | find_image; fon `savanna_k` | ✅ | |
| 16 | 📹 "Oz oz oz, rangli qog'oz" | video `oz_qogoz.mp4` | ✅ | |
| 17 | 👅 Og'iz: tepa-past (5 mashq) | exercise `til_ogiz_tashqari_tepa_past.mp4` | ✅ | |
| 18 | 〽️ Yo'l tepa o'ngdan: Iiiiz, zebra | path_game `Iiiz`, `IZZZZZ.mp3`, fon `paint/utloq` | ✅ | |
| 19 | 🖇 Unlilardan Z ga: az oz uz iz | arrow, markaz **Z**, 4 tugun A, O, U, I | ⚠️ | Ro'yxatda "az oz uz iz **oz**" — oz ikki marta (ehtimol "ez"), lekin `EZZZZ` ovozi yo'q |
| 20 | 🫁 Nafas: raketa | breath `rocket` | ✅ | |
| 21 | 📹 "O'z o'z o'z, uzukda bor ko'z" | video `oz_koz.mp4` | ✅ | |
| 22 | 🧩 Pazl: uzuk–uzuklar, zirak–ziraklar | puzzle_game; fon `sound_game/xona` | ✅ | |
| 23 | 〽️ To'lqin tepadan: Uuuuz, qo'ng'iz | path_game `Uuuz`, `UZZZZZ.mp3`, fon `utloq_kichkina` | ✅ | Qo'ng'iz rasmi S dagi `qongiz_s` bilan aynan bir xil |
| 24 | 🫁 Nafas: shar | breath `redBallon` | ✅ | |
| 25 | 📹 "Uz uz uz, ko'chalar muz" | video `uz_muz.mp4` | ✅ | |
| 26 | 🤙 Barmoq: quticha rasm (4 lik) | hand_game `hand_5–8` | ✅ | |
| 27 | 〽️ Pastdan yo'l: Zzzzz, fil | path_game `Zzzz`, yangi `ZZZZ.mp3`, fon `savanna_k` | ✅ | |
| 28 | Z qatnashmagan bo'g'in, qo'ng'iz–uycha, mikrofonsiz | wolf_game: `qongiz_s`, 4 ta `uya` (iz, **si**, za, zi); fon `utloq_kichkina` | ⚠️ | Ro'yxatda "az, za, iz, is", papkada `iz, si, za, zi` — to'g'ri javob **SI** |
| 29 | 🌄 Z so'z boshida (**zirak**, uzuk, ko'zoynak, bilakuzuk) | find_image; fon `gardirop` | ✅ | |
| 30 | 🖇 Undoshdan Z: za zo zu zi | arrow, markaz **Z**, 4 tugun A, O, U, I | ⚠️ | Ro'yxatda "sh ga qarab za zo zu zi **za**" — Z deb olindi; "ze" (`ZZZZZE`) ovozi yo'q |
| 31 | 〽️ Spiral: Zzzza, timsoh | path_game `Zzza`, `ZZZZZA.mp3`, fon `kol` | ✅ | |
| 32 | 🫁 Nafas: gul kala | breath `flower2` | ✅ | |
| 33 | ☁️ Bulutli mashq (chiziqlidagi barcha bo'g'inlar) | cloud: za, az, zo, oz, zu, uz, zi, iz | ✅ | |
| 34 | 📹 "Za za za, ochiq ekan deraza" | video `za_deraza.mp4` | ✅ | |
| 35 | 👅 Og'iz: ichida tepa-past (7 mashq) | exercise `til_ogiz_ichida_tepa_past.mp4` | ✅ | |
| 36 | 🤘 Barmoq 4 talik | hand_game `hand_9–12` | ✅ | |
| 37 | 〽️ To'rtburchak pastdan: Zzzzo, bo'ri | path_game `Zzzo`, `ZZZZZO.mp3`, fon `paint/utloq` | ✅ | |
| 38 | 🥘 Yegulikni yedir (muzqaymoq, tarvuz, uzum, sabzi, qo'ziqorin) | cooking; fon `cooking`, oshpaz `chef_girl` | ✅ | Fon, oshpaz va sabzi loyihadagisi bilan aynan bir xil |
| 39 | 📹 Z o'rgatgan real qizcha | video `z.mp4` | ✅ | 7 bilan bir xil |
| 40 | 🫁 Nafas: sham | breath `candle` | ✅ | |
| 41 | 🌄 Z so'z o'rtasida (**ko'za**, choynak, finjon, piyola) | find_image; fon `find_image/oshxona` | ✅ | Rasm/ovozlar K dagi bilan bir xil |
| 42 | 🤡 Emotsiya | hand_game `face_1–4` | ✅ | |
| 43 | 👅 Og'iz: otcha (6 mashq) | exercise `otchaa.mp4` | ✅ | |
| 44 | 〽️ Zigzag tepadan: Zzzzu, sher | path_game `Zzzu`, `ZZZZZU.mp3`, fon `savanna_k` | ✅ | 13 dan farqli bo'lishi uchun ko'zgu qilindi |
| 45 | 📹 "Zu zu zu, to'tiqushim bor Zuzu" | video `zu_zuzu.mp4` | ✅ | |
| 46 | So'z tuz: MUZ–QAY–MOQ | sound_game: MUZ _ MOQ, variantlar KA / **QAY** / TA; rasm `muzqaymoq` | ⚠️ | Noto'g'ri variantlar (KA, TA) ro'yxatda yo'q edi |
| 47 | 🫁 Nafas: kapalak | breath `butterfly` | ✅ | |
| 48 | 👄 Lab mashqi quticha rasm | hand_game `lib_5–8` | ✅ | |
| 49 | 〽️ To'lqin tepadan: Zzzzi, mushuk | path_game `Zzzi`, `ZZZZZI.mp3`, fon `utloq_kichkina` | ✅ | |
| 50 | 🫁 Nafas: tanga | breath `coins` | ✅ | |
| 51 | 👅 Og'iz: o'ng-chap | exercise `ong_chap.mp4` | ✅ | |
| 52 | 📹 "Zi zi zi, chaynayapman men Zizi" | video `zi_zizi.mp4` | ✅ | |
| 53 | 🖇 Vagon: 1 ko'z, 2 tarvuz, 3 qo'ziqorin | train_game; fon `vagon` | ⚠️ | **Qo'ziqorin 4 bo'g'inli** (qo-'zi-qo-rin), lekin ro'yxat bo'yicha 3-vagonga qo'yildi |
| 54 | 🫁 Nafas: qor | breath `snow` | ✅ | |
| 55 | 👅 Og'iz: murabbo (9 mashq) | exercise `ogiz_ichida_aylantirish.mp4` | ✅ | |
| 56 | 🌄 Z so'z oxirida (qo'l, lab, **ko'z**, qosh) | find_image; fon `sound_game/xona` | ✅ | |
| 57 | 〽️ Spiral: Zzzzz, qush | path_game `Zzzz`, `ZZZZ.mp3`, fon `osmon` | ✅ | 31 dan farqli bo'lishi uchun ko'zgu qilindi |
| 58 | 🤘 Barmoq 4 talik (takrorlanmasin) | hand_game `hand_2, 7, 12, 9` | ⚠️ | S/K/Sh dagi kabi: yangi barmoq rasmlari yo'q |

> ⚠️ bosqichlar: 19, 28, 30, 46, 53, 58.

## Kerak bo'ladigan resurslar

| # | Nima kerak | Qaysi bosqich |
|---|---|---|
| 1 | **"ez"** (`EZZZZ`) ovozi, agar 19 da 5-tugun kerak bo'lsa | 19 |
| 2 | **"ze"** (`ZZZZZE`) ovozi, agar 30 da 5-tugun kerak bo'lsa | 30 |
| 3 | 3 bo'g'inli Z li so'z rasmi+ovozi (qo'ziqorin o'rniga), yoki ro'yxatni tasdiqlash | 53 |
| 4 | **Z harfi rasmi** (`assets/alphabet/z.webp`) — hozir vaqtinchalik pushti Z | Alifbo kartasi |
| 5 | Yangi 4 ta barmoq mashqi rasmi | 58 |

## Resurslarni ko'chirish

- 71 ta rasm/audio `Z OYIN HAMMASI/` dan `assets/` ga ko'chirildi (2 ta keng rasm 512px ga kichraytirildi).
- Loyihada aynan bor bo'lganlar qayta qo'shilmadi: qo'ng'iz, ko'z, ko'za, choynak, finjon, piyola, timsoh, qush, mushuk, sabzi rasmlari; barcha fonlar (`savanna_k`, `utloq`, `utloq_kichkina`, `gardirop`, `find_image/oshxona`, `sound_game/xona`, `vagon`, `kol`, `osmon`, `cooking`, `chef_girl`); `sound/arrow/*ZZZZZ*`, ko'za/choynak/finjon/ko'z/sabzi ovozlari va start ovozlari.
- Nom to'qnashuvlari: `paint/zebra_z`, `paint/bori_z`, `paint/sher_z` (loyihadagi zebra/bo'ri/sher boshqa rasmlar).

**Videolar** (H.264, CRF 26, max 1080px, AAC 96k) — 94 MB → 15 MB:

| Manba | Yangi fayl |
|---|---|
| `Z.mp4` | `z.mp4` (36 MB → 5 MB) |
| `az az az mening dadam oshpaz.mp4` | `az_oshpaz.mp4` |
| `oz oz oz rangli qog'oz.mp4` | `oz_qogoz.mp4` |
| `o'z o'z o'z uzukda bor ko'z.mp4` | `oz_koz.mp4` |
| `uz uz uz ko'chalar muz.mp4` | `uz_muz.mp4` |
| `za za za ochiq ekan deraza.mp4` | `za_deraza.mp4` |
| `zu zu zu to'tiqushim bor zuzu.mp4` | `zu_zuzu.mp4` |
| `zi zi zi chaynayapman men zizi.mp4` | `zi_zizi.mp4` |

Asl videolar `Z OYIN HAMMASI/videolar_asl/` ga ko'chirildi va git indeksidan olindi.

O'zgarishlar commit qilinmadi.
