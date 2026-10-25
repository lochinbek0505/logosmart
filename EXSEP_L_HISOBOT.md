# `assets/exsepL.json` — L tovushi bo'yicha tekshiruv hisoboti

**Sana:** 2026-10-16
**Tekshirilgan fayl:** `assets/exsepL.json` (dastlab 65 ta element; ko'chirishlardan keyin 58 ta, id 1–58)

## Umumiy xulosa

`exsepL.json` ning **id 1–55** qismi hali ham **R tovushi** dasturining shabloni (R videolari, `Drrr`/`Trrr`/`Rrrr` chiziqli o'yinlar, R so'zli rasm topish va h.k.). L tovushi uchun faqat **chiziqli (path_game) o'yinlar** tayyorlangan, ular ham ro'yxat oxiriga — **id 56–65** ga qo'shib qo'yilgan, o'z joylariga qo'yilmagan.

| Holat | Soni |
|---|---|
| ✅ O'z joyida (tayyor) | 38 |
| 🔀 Mavjud, lekin joyi almashgan | 6 |
| ⚠️ Turi bor, lekin kontenti R uchun (L ga moslash kerak) | 6 |
| ❌ Hali setup qilinmagan | 8 |
| **Jami (ro'yxatda)** | **58** |

> Belgilar: ✅ joyida · 🔀 joyi almashgan (JSONda boshqa id da bor) · ⚠️ joyi almashgan va kontenti R uchun, L ga o'zgartirish kerak · ❌ setup qilinmagan · 🛑 siz ro'yxatda belgilagan.
>
> Nafas, og'iz, lab va barmoq mashqlari tovushga bog'liq emas, shuning uchun R shablonidagisi ham L uchun yaroqli deb hisoblandi.

> **Ro'yxat raqamlari haqida:** ro'yxatda `22` ikki marta (koptok va "Lo lo lo"), `36` ham ikki marta (to'rtburchak LLLLLi va gul kalasi) yozilgan. Hisobotda sizning raqamlaringiz saqlandi; "gul kalasi" **36b** deb belgilandi (38 dan keyin keladi). "Lo lo lo" 23-o'rinda deb olindi.

---

## To'liq jadval

"Hozir JSONda" ustuni — sizning ro'yxatingizdagi raqam bilan bir xil `id` dagi element.

| #   | Kerakli mashq/o'yin | Hozir JSONda (shu id da) | Holat | Izoh |
|-----|---|---|-------|---|
| 1   | 👅 Og'iz: tilni chiqarish | exercise `tilni_chiqarish.mp4` (past) | ✅     | |
| 2   | 🫁 Nafas: tanga | breath `coins` | ✅     | |
| 3   | 👅 Og'iz: o'ng-chap | exercise `ong_chap.mp4` | ✅     | |
| 4 ✅ | 🎁 L li bo'g'inni topish, olmaxon-yong'oq (ra, sa, la, ya), mikrofonsiz | wolf_game (olmaxon, 4 ta yong'oq, to'g'risi = LA) | ✅     | 2026-10-16 da sozlandi |
| 5   | 🫁 Nafas: raketa | breath `rocket` | ✅     | |
| 6   | 🤟 Barmoq: sovg'a qutisi | hand_game `hand_1–4` | ✅     | |
| 7   | 📽 L tovushi videosi (qizcha o'rgatadi) 🛑 | video `map_video/r.MP4` | ❌     | Bu R videosi. L videosi `assets/videos/` da yo'q |
| 8   | 〽️ To'lqin: L-L-L-L | path_game `Drrr` (dron, R) | 🔀    | L versiyasi tayyor: **id 56** (`Llll`, ilon, to'lqin) → 8 ga ko'chirish kerak |
| 9   | 👅 Og'iz: tish-lab | exercise `ong_chap.mp4` (takror) | ✅     | `tish_lab.mp4` video va `ogiz_lab_tish.tflite` model bor, lekin JSONda bu mashq yo'q |
| 10  | 🤡 Qutili o'yin (tana harakati) | hand_game `face_5–8` | ⚠️    | Turi to'g'ri, lekin rasmlar yuz (emotsiya) — tana harakati rasmlari yo'q. Balki bu 41/50 dagi emotsiya o'yini |
| 11  | 🫁 Nafas: gul | breath `flower.json` | ✅ | Yangi yozuv: ilgari ishlatilmagan `flower.json` animatsiyasi |
| 12  | 〽️ To'rtburchak: ALLLLL | path_game `Aaal` (chumoli, to'rtburchak) | ✅     | id 57 dan ko'chirildi (`Trrr` o'chirildi) |
| 13  | 👄 Lab mashqi (4 talik) | train_game (bo'g'in poyezdi, R, locked) | 🔀    | Lab qutili o'yini **id 40** da (`lib_1–4`) |
| 14  | 🌄 L li hasharotni top va ayt | hand_game `face_1,2,3,8` | ❌     | find_image shabloni **id 28, 39** da (R so'zlari). L so'zli hasharot rasmlari/ovozlari yo'q |
| 15  | 👅 Og'iz: tepa-past (5 mashq) | exercise `til_ogiz_tashqari_tepa_past.mp4` | ✅ | id 24 dan ko'chirildi |
| 16  | 〽️ Zigzag: OoooL | path_game `Oool` (olmaxon, zigzag) | ✅ | id 58 dan ko'chirildi |
| 17  | 🖇 Tortib qo'shish: aL oL uL iL eL | arrow (A, O, U, O' → **R**) | ⚠️    | Turi joyida, kontent R. `center_letter: "L"` va L ovozlari kerak (`assets/sound/arrow/` da `OLLL`, `ULLL`, `ILLLL` bor; `aL`, `eL` yo'q) |
| 18  | 🫁 Nafas: dron | breath `drone` | ✅ | id 20 dan ko'chirildi |
| 19  | 📹 "La la la, o'tkir tishli akula" | video `la_akula.mp4` | ✅     | 2026-10-16 da sozlandi |
| 20  | 🧩 Pazl: ari-arilar, daraxt-daraxtlar 🛑 | puzzle_game (ari, arilar, daraxt, daraxtlar) | ✅ | id 21 dan ko'chirildi. 🛑 belgisi sababi aniqlashtirilsin |
| 21  | 〽️ Suv oqishi: uuuuuuL | path_game `Uuul` (laylak) | ✅ | id 59 dan ko'chirildi |
| 22  | 🫁 Nafas: koptok | breath `ball` | ✅ | id 31 dan ko'chirildi (`Rrrr` o'chirildi) |
| 23  | 📹 "Lo lo lo, terdim qip-qizil lola" | video `lo_lola.mp4` | ✅     | 2026-10-16 da sozlandi |
| 24  | 🤙 Barmoq: quticha rasm (4 lik) | hand_game `hand_5–8` | ✅ | id 25 dan ko'chirildi |
| 25  | 📹 L tovushi videosi (qizcha qo'li bilan ko'rsatadi) 🛑 | hand_game `hand_5–8` | ❌     | L videosi yo'q (id 26 da R videosi `r.MP4`) |
| 26  | 〽️ Spiral: IIIIIIIL | path_game `Iiil` (yo'lbars, spiral) | ✅ | id 60 dan ko'chirildi (`r.MP4` o'chirildi) |
| 27 | L qatnashmagan bo'g'inni topish, qush uyi, mikrofonsiz | wolf_game (bulbul, 4 ta uya: la, al, lo, **sa** — to'g'risi SA) | ✅     | 2026-10-16 da sozlandi |
| 28  | 🌄 L so'z boshida — rasmni top va ayt 🛑 | find_image (randa, arava, arra… — R) | ⚠️    | Turi joyida, kontent R. L so'zli rasm/ovozlar yo'q |
| 29  | 🖇 Tortib qo'shish: la lu li le lo | sound_game (raketa, R, locked) | ❌     | arrow shabloni id 30 da, lekin u ham unli → R. `LLLLA`, `LLLLi`, `LLLLo`, `LLLe` ovozlari bor, `lu` yo'q |
| 30  | 〽️ To'lqin: eeeeeeL | path_game `Eeel` (laylak, to'lqin) | ✅ | id 61 dan ko'chirildi |
| 31  | 🫁 Nafas: shar | breath `redBallon` | ✅ | id 18 dan ko'chirildi |
| 32  | ☁️ Bulutli mashq | cloud (ar, ir, ur, er, re, or, ru, ro, ri, ra — R) | ⚠️    | Turi joyida, kontent R. `assets/sound/cloud_game/` da L bo'g'in ovozlari yo'q |
| 33  | 📹 "Li li li, menda bor tufli" | video `li_tufli.mp4` | ✅     | 2026-10-16 da sozlandi |
| 34  | 👅 Og'iz: otcha, og'iz ichida tepa-past (7 mashq) | exercise `til_ogiz_ichida_tepa_past.mp4` | ✅     | |
| 35  | 🤘 Barmoq (4 talik) | hand_game `hand_9–12` | ✅     | |
| 36  | 〽️ To'rtburchak: LLLLLi | path_game `Llli` (chumoli, to'rtburchak) | ✅ | id 62 dan ko'chirildi |
| 37  | 🥘 Yegulikni yedir (mikrofonda muammo) 🛑 | cooking (sho'rva, pamidor, bodring, rediska, anor — R) | ⚠️ | id 36 dan ko'chirildi, joyi to'g'ri. Mahsulotlar hali R so'zlari, L so'zlari kerak |
| 38  | 📹 "Al al al, asal" | video `al_asal.mp4` | ✅     | 2026-10-16 da sozlandi (sham 44 ga ko'chirildi) |
| 36b | 🫁 Nafas: gul kalasi | find_image (id 39) | 🔀    | Gul animatsiyasi **id 43** da (`flower2`). Ehtimol 11-dagi "gul" bilan bitta animatsiya ishlatiladi — alohida "gul kalasi" animatsiyasi yo'q |
| 39  | 🌄 L so'z o'rtasida — rasmni top va ayt 🛑 | find_image (kurtka, fudbolka… — R) | ⚠️    | Turi joyida, kontent R |
| 40  | 🤡 Emotsiya (qutili o'yin) | hand_game `lib_1–4` (lab) | 🔀    | Emotsiya (yuz) o'yini **id 14** (`face_1,2,3,8`) yoki **id 10** (`face_5–8`) da |
| 41  | 👅 Og'iz: ichida tepa-past, otcha (6 mashq) | exercise `otchaa.mp4` | ✅     | |
| 42  | 📹 "El el el, birga o'ynaymiz kel" | video `el_kel.mp4` | ✅     | 2026-10-16 da sozlandi |
| 43  | 🤘 Barmoq (4 talik) | breath `flower2` | ❌     | Barmoq rasmlari faqat 3 to'plam (`hand_1–12`) bor, ular id 6, 25, 35 da ishlatilgan. Yangi rasmlar kerak |
| 44  | 🫁 Nafas: sham | breath `candle` | ✅     | id 38 dan ko'chirildi (`Rrro` o'chirildi) |
| 45  | 👄 Lab: quticha rasm (4 lik) | hand_game `lib_5–8` (locked) | ✅ | id 46 dan ko'chirildi (R bo'ri o'yini o'chirildi) |
| 46  | 〽️ Zigzag ("rrrro" deb yozilgan) | path_game `Llla` (yo'lbars, zigzag) | ✅ | id 63 dan ko'chirildi. Ro'yxatdagi "rrrro" matni aniqlashtirilsin |
| 47  | 🫁 Nafas: qor | breath `snow` | ✅     | id 51 dan ko'chirildi (kapalak 53 ga o'tdi) |
| 48  | 👅 Og'iz: o'ng-chap | exercise `ong_chap.mp4` | ✅     | |
| 49  | 🤡 Emotsiya (qutili o'yin) | video `ru.mp4` | 🔀    | Emotsiya o'yini id 10 / 14 da (40 bilan bir xil to'plam ishlatilsa) |
| 50  | 〽️ Suv oqishi: LLLLLE | path_game `Llle` (ilon) | ✅ | id 65 dan ko'chirildi (buzuq za/zi bulut o'yini o'chirildi) |
| 51  | 📹 "Ul ul ul, tomda sayraydi bulbul" | video `ul_bulbul.mp4` | ✅     | 2026-10-16 da sozlandi (qor 47 ga ko'chirildi) |
| 52  | 🖇 Tortib qo'shish: al ol ul il el | exercise `ogiz_ichida_aylantirish.mp4` | ❌     | L arrow konfiguratsiyasi yo'q |
| 53  | 🫁 Nafas: kapalak | breath `butterfly` | ✅     | id 47 dan ko'chirildi (R find_image `traktor` o'chirildi) |
| 54  | 👅 Og'iz: murabbo (9 mashq) | video `ur.mp4` | 🔀    | Murabbo/aylantirish mashqi **id 52** da (`ogiz_ichida_aylantirish.mp4`) |
| 55  | 🌄 L so'z oxirida — rasmni top va ayt 🛑 | cooking (maktab: daftar, ruchka… — R) | ❌     | find_image shabloni id 15, 28, 39 da (R so'zlari). L so'zli rasmlar yo'q |
| 56  | 🤘 Barmoq (4 talik) | path_game `Llll` | ❌     | 43 bilan bir xil muammo — yangi barmoq rasmlari kerak |
| 57  | 📹 "Il il il, fil" | video `il_fil.mp4` | ✅     | 2026-10-16 da sozlandi (`Aaal` 12 ga ko'chirildi) |

---

## Ro'yxatda yo'q, lekin JSONda turgan elementlar (R qoldiqlari)

To'g'ri tartibga keltirilgach, bularni olib tashlash yoki L ga moslash kerak:

| id | Element | Izoh |
|---|---|---|
| 17 | arrow — unlilar → R | 17, 29, 52 dagi L "tortib qo'shish" o'yinlari uchun shablon bo'ladi |
| 8 | path_game `Drrr` (dron) | R |
| 9 | exercise `ong_chap` | 3 va 48 ning takrori |
| 13 | train_game (qor, arri, vertolyot) | R, ro'yxatda yo'q |
| 29 | sound_game (RA-KE-TA) | R, ro'yxatda yo'q (4-o'yin uchun shablon bo'lishi mumkin) |
| 55 | cooking (maktab) | R |
| 7, 49, 54 | R videolari (`r`, `ru`, `ur`) | 7 uchun L videosi hali yo'q; 49 va 54 boshqa mashqlar o'rnida turibdi. `ar`, `or`, `ra`, `ro`, `ir` fayllari endi JSONda ishlatilmaydi |
| **58** | path_game `Lllo` (olmaxon, to'rtburchak; avval id 64) | L uchun tayyor, lekin ro'yxatda **Lllo** yo'q. 46-o'ringa shakli zigzag bo'lgani uchun `Llla` qo'yildi. Kerak bo'lmasa o'chirish mumkin |

---

## Nima qilish kerak (ustuvorlik bo'yicha)

1. **Tartibni to'g'rilash (🔀, 6 ta qoldi: 8, 13, 36b, 40, 49, 54):** mavjud elementlarni ro'yxatdagi o'rniga ko'chirish. Bunga yangi asset kerak emas.
2. **L kontentini to'ldirish (⚠️):** arrow (17, 29, 52), cloud (32), find_image (14, 28, 39, 55), cooking (37) — turi tayyor, faqat L so'zlari, rasmlari va ovozlari kerak.
3. **Yangi assetlar (❌):**
   - L videolari — **2 ta** qoldi (7, 25 — qizcha o'rgatadigan videolar)
   - Tish-lab mashqi (9) — video va model bor, faqat JSON yozuvi kerak
   - Qo'shimcha barmoq rasmlari (43, 56)
   - Tana harakati rasmlari (10)
4. **Aniqlashtirish kerak:** 46-o'yin matni ("rrrro") va id 58 (`Lllo`) kerakmi; 20-pazldagi 🛑 belgisi sababi; 54 (murabbo) uchun `ogiz_ichida_aylantirish.mp4` mos keladimi.

---

> 11, 15, 16, 17, 18, 20, 21, 22, 26, 29, 30, 31, 32, 36, 46, 50, 52, 54-o'rinlar bo'yicha batafsil tahlil va ko'chirish rejasi: [EXSEP_TAHLIL_18_ORIN.md](EXSEP_TAHLIL_18_ORIN.md)
