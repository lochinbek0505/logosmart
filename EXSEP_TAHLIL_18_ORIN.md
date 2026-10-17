# `exsep.json` — 18 ta o'rin bo'yicha batafsil tahlil

**O'rinlar:** 11, 15, 16, 17, 18, 20, 21, 22, 26, 29, 30, 31, 32, 36, 46, 50, 52, 54
**Asosiy hisobot:** [EXSEP_L_HISOBOT.md](EXSEP_L_HISOBOT.md)

*2026-10-16 holatiga ko'ra `exsep.json` bo'yicha.*

> ✅ **Bajarildi (2026-10-16):** 🟢 guruhidagi barcha ko'chirishlar JSON da amalga oshirildi. Oxiridagi takror manbalar (eski id 58–63, 65) o'chirildi, `Lllo` id 64 → **58**. Levellar endi **58 ta**, id lar 1–58 uzluksiz: `unlock()` keyingi levelni `id + 1` bo'yicha ochadi. 🟡 54 va 🔴 17, 29, 32, 52 hali ochiq.

### Xulosa

| Guruh | O'rinlar | Nima kerak |
|---|---|---|
| 🟢 **Darhol joylash mumkin** (yangi resurs kerak emas) | 11, 15, 16, 18, 20, 21, 22, 26, 30, 31, 36, 46, 50 | Faqat JSON da ko'chirish |
| 🟡 **Joylash mumkin, lekin aniqlashtirish kerak** | 54 | Murabbo mashqi uchun mavjud video mos keladimi |
| 🔴 **Yangi ovozlar kerak** | 17, 29, 32, 52 | L bo'g'in ovozlari |

### Har bir o'rin

| # | Kerak | Hozir JSONda | Manba (qayerdan olinadi) | Holat | Izoh |
|---|---|---|---|---|---|
| 11 | 🫁 Nafas: gul | breath `coins` (2-ning takrori) | `animation/breath/flower.json` — **hech qayerda ishlatilmagan**, `flower_background.jpg` bilan | 🟢 | Avvalgi savolga javob: "gul" uchun `flower.json`, "gul kalasi" (36b) uchun `flower2.json` (hozir id 43 da). Ikkalasi ham bor |
| 15 | 👅 Og'iz: tepa-past (5 mashq) | find_image (R hasharot: ari, pashsha…) | id 24 — `til_ogiz_tashqari_tepa_past.mp4` | 🟢 | Zanjir: 24 → 15, so'ng 25 (barmoq `hand_5–8`) → 24. R hasharot o'yini o'chadi (find_image shabloni 28 va 39 da ham bor) |
| 16 | 〽️ Zigzag: OoooL | exercise `lap_chochaytirish.mp4` (ro'yxatda yo'q) | id 58 — `Oool` (olmaxon, zigzag) | 🟢 | Lab cho'chaytirish mashqi ro'yxatda yo'q, o'chadi |
| 17 | 🖇 Tortib qo'shish: aL oL uL iL eL | arrow: A, O, U, O' → **R** | Shablon shu yerda | 🔴 | `center_letter: "L"` va 5 ta tugun kerak (kod istalgan sondagi tugunni qo'llaydi, burchaklarni 72° dan qo'yish kerak). Ovozlar: `OLLL`, `ULLL`, `ILLLL` **bor**; **`ALLL`, `ELLL` yo'q** |
| 18 | 🫁 Nafas: dron | breath `redBallon` (shar) | id 20 — `drone.json` | 🟢 | Shar 31 ga o'tadi |
| 20 | 🧩 Pazl: ari-arilar, daraxt-daraxtlar 🛑 | breath `drone` | id 21 — puzzle (ari, arilar, daraxt, daraxtlar) | 🟢 | Kontent ro'yxatga **aynan mos**. So'zlarda R bor, lekin L ko'plik qo'shimchasidagi **-lar** da keladi, demak L dasturiga ham to'g'ri. 🛑 belgisi nima uchun qo'yilganini aniqlashtirish kerak |
| 21 | 〽️ Suv oqishi: uuuuuuL | puzzle_game | id 59 — `Uuul` (laylak) | 🟢 | Pazl 20 ga o'tadi |
| 22 | 🫁 Nafas: koptok | path_game `Rrrr` (sher, R) | id 31 — `ball.json` | 🟢 | `Rrrr` R qoldig'i, o'chadi |
| 26 | 〽️ Spiral: IIIIIIIL | video `r.MP4` (R) | id 60 — `Iiil` (yo'lbars, spiral) | 🟢 | R videosi o'chadi. 25-o'rindagi "qizcha qo'li bilan" L videosi hali yo'q |
| 29 | 🖇 Tortib qo'shish: la lu li le lo | sound_game RA-KE-TA (R, `locked: true`) | arrow shabloni (id 17/30) | 🔴 | Markazda L, atrofda unlilar (yo'nalish teskari). Ovozlar: `LLLLA`, `LLLLi`, `LLLLo`, `LLLe` **bor**; **`LLLLu` yo'q**. `locked: true` ni ham `false` qilish kerak |
| 30 | 〽️ To'lqin: eeeeeeL | arrow (R, 17 ning takrori) | id 61 — `Eeel` (laylak, to'lqin) | 🟢 | |
| 31 | 🫁 Nafas: shar | breath `ball` (koptok) | id 18 — `redBallon.json` | 🟢 | Koptok 22 ga o'tadi |
| 32 | ☁️ Bulutli mashq | cloud: ar, ir, ur, er, re, or, ru, ro, ri, ra (R) | — | 🔴 | 10 ta L bo'g'in kerak: al, il, ul, el, ol, la, li, lu, le, lo. Loyihada bor: `wolf_game/al.mp3`, `wolf_game/lo.mp3`, `wolf_game/LA.mp3` (yoki `sound_game/la.mp3`). **7 ta yo'q**: il, ul, el, ol, li, lu, le. Bulutlar sonini 3 taga qisqartirib vaqtincha ishga tushirish mumkin |
| 36 | 〽️ To'rtburchak: LLLLLi | cooking (sho'rva, pamidor… — R) | id 62 — `Llli` (chumoli) | 🟢 | Cooking — 37 ("yegulikni yedir") uchun yagona ishlaydigan shablon (55 dagisining rasmlari yo'q). Uni o'chirmasdan 37 ga ko'chirish kerak (37 da hozir R videosi `ir.mp4`) |
| 46 | 〽️ Zigzag ("rrrro") | hand_game `lib_5–8` | id 63 — `Llla` (yo'lbars, zigzag) | 🟢 | Shakli bo'yicha faqat `Llla` zigzag. `Lllo` (id 64) — to'rtburchak, zigzag emas. Lab o'yini (`lib_5–8`) 45 ga o'tishi kerak |
| 50 | 〽️ Suv oqishi: LLLLLE | cloud za, zi — **buzuq** (`za.mp3`, `zi.mp3` yo'q) | id 65 — `Llle` (ilon) | 🟢 | Buzuq bulut o'yini ham shu bilan yo'qoladi |
| 52 | 🖇 Tortib qo'shish: al ol ul il el | exercise `ogiz_ichida_aylantirish.mp4` | arrow shabloni | 🔴 | 17 ga o'xshaydi, lekin bo'g'inlar qisqa. Ovozlardan faqat `wolf_game/al.mp3` bor. Uzun shakllar (`OLLL`, `ULLL`, `ILLLL`) ham ishlatilsa, `ALLL`, `ELLL` yetishmaydi, 17 bilan bir xil |
| 54 | 👅 Og'iz: murabbo (9 mashq) | video `ur.mp4` (R) | id 52 — `ogiz_ichida_aylantirish.mp4` (o'ng, tepa, chap, past) | 🟡 | "Murabbo" odatda til bilan **lab atrofini tashqaridan** yalash. Mavjud video esa **og'iz ichida** aylantirish. Mos bo'lmasa, yangi video va model kerak. "9 mashq" ham hozirgi 4 qadamga to'g'ri kelmaydi |

### 🟢 Ko'chirish rejasi — ✅ bajarildi

| Qayerdan | Qayerga | Element |
|---|---|---|
| `flower.json` (yangi yozuv) | 11 | Nafas: gul |
| 24 | 15 | Og'iz: tepa-past |
| 25 | 24 | Barmoq `hand_5–8` |
| 58 | 16 | Zigzag `Oool` |
| 20 | 18 | Nafas: dron |
| 21 | 20 | Pazl |
| 59 | 21 | Suv oqishi `Uuul` |
| 31 | 22 | Nafas: koptok |
| 60 | 26 | Spiral `Iiil` |
| 61 | 30 | To'lqin `Eeel` |
| 18 | 31 | Nafas: shar |
| 36 | 37 | Cooking (R, keyin L ga moslanadi) |
| 62 | 36 | To'rtburchak `Llli` |
| 46 | 45 | Lab `lib_5–8` |
| 63 | 46 | Zigzag `Llla` |
| 65 | 50 | Suv oqishi `Llle` |

**O'chirilganlar** (hammasi R qoldig'i, takror yoki buzuq): 15 R hasharot, 16 lab cho'chaytirish, 22 `Rrrr`, 26 `r.MP4`, 30 arrow takrori, 37 `ir.mp4`, 45 wolf_game (bo'ri — R uchun), 50 buzuq bulut. 54 (`ur.mp4`) 🟡 bo'lgani uchun tegilmadi.

### 🔴 Yozdirish kerak bo'lgan ovozlar

| O'yin | Yetishmaydigan ovozlar |
|---|---|
| 17, 52 (unli → L) | `ALLL`, `ELLL` (52 uchun qisqasi: `ol`, `ul`, `il`, `el`) |
| 29 (L → unli) | `LLLLu` |
| 32 (bulut) | `il`, `ul`, `el`, `ol`, `li`, `lu`, `le` |
