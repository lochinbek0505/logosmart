/// STT (uzbekvoice) qaytargan matnni kutilgan matn bilan solishtirish.
///
/// STT ning odatiy xatolari va ular qanday hal qilinadi:
/// * Cho'ziq tovushga unli qo'shadi: "drrrr" → "dardardar". [lenient] rejimida
///   maqsadda yo'q unlilar tashlab yuboriladi.
/// * Kirill yoki turkcha harflarda yozadi (шар, ғ, ş): lotinga o'giriladi.
/// * Apostrofni har xil belgi bilan qo'yadi (o‘, oʻ, o'): bittaga keltiriladi.
/// * h/x ni almashtiradi (timsoh / timsox): bir xil hisoblanadi.
///
/// sh, ch, o', g' bitta tovush sifatida solishtiriladi, shuning uchun
/// "Ssss" maqsadiga "shshsh", "G" ga "g'" mos kelmaydi.
bool voiceMatches(String recognized, String target, {bool lenient = false}) {
  final cleanTarget = _phonemes(target, lenient: lenient);
  final cleanRecognized = _phonemes(recognized, lenient: lenient);
  if (cleanTarget.isEmpty || cleanRecognized.isEmpty) return false;

  final pattern = _repeatPattern(cleanTarget);
  if (pattern.hasMatch(cleanRecognized)) return true;
  if (!lenient) return false;

  final targetVowels = cleanTarget.split('').where(_vowels.contains).toSet();
  final reduced = cleanRecognized
      .split('')
      .where((c) => !_vowels.contains(c) || targetVowels.contains(c))
      .join();
  return reduced.isNotEmpty && pattern.hasMatch(reduced);
}

/// STT umuman nutq topmadi (bo'sh yoki faqat tinish belgilari).
/// Bu bolaning xatosi emas — urinish qayta beriladi.
bool isEmptyTranscript(String recognized) =>
    _phonemes(recognized, lenient: true).isEmpty;

/// Matnni so'zlarga ajratadi; har bir so'z [phonemeWord] ko'rinishida.
List<String> phonemeWords(String text) => text
    .split(RegExp(r'\s+'))
    .map((w) => _phonemes(w, lenient: false))
    .where((w) => w.isNotEmpty)
    .toList();

/// Bitta so'z yoki tovush (masalan "Sh") [phonemeWords] bilan bir xil ko'rinishda.
String phonemeWord(String text) => _phonemes(text, lenient: false);

// Digraflar bitta belgiga almashtiriladi (katta harflar normalizatsiyadan
// keyin bo'sh, shuning uchun to'qnashmaydi).
const _oApostrophe = 'O';
const _gApostrophe = 'G';
const _sh = 'S';
const _ch = 'C';

const _vowels = {'a', 'e', 'i', 'o', 'u', _oApostrophe};

const _cyrillic = {
  'а': 'a', 'б': 'b', 'в': 'v', 'г': 'g', 'д': 'd', 'е': 'e', 'ё': 'yo',
  'ж': 'j', 'з': 'z', 'и': 'i', 'й': 'y', 'к': 'k', 'л': 'l', 'м': 'm',
  'н': 'n', 'о': 'o', 'п': 'p', 'р': 'r', 'с': 's', 'т': 't', 'у': 'u',
  'ф': 'f', 'х': 'x', 'ц': 'ts', 'ч': 'ch', 'ш': 'sh', 'щ': 'sh', 'ъ': "'",
  'ы': 'i', 'ь': '', 'э': 'e', 'ю': 'yu', 'я': 'ya', 'ў': "o'", 'қ': 'q',
  'ғ': "g'", 'ҳ': 'h',
  // turkcha/boshqa lotin harflari
  'ş': 'sh', 'ç': 'ch', 'ğ': "g'", 'ö': "o'", 'ü': 'u', 'ı': 'i',
};

String _phonemes(String text, {required bool lenient}) {
  final buffer = StringBuffer();
  for (final ch in text.toLowerCase().split('')) {
    buffer.write(_cyrillic[ch] ?? ch);
  }
  var s = buffer
      .toString()
      .replaceAll(RegExp("[‘’ʻʼ`´]"), "'")
      .replaceAll("o'", _oApostrophe)
      .replaceAll("g'", _gApostrophe)
      .replaceAll('sh', _sh)
      .replaceAll('ch', _ch)
      .replaceAll('x', 'h')
      .replaceAll(RegExp('[^a-z$_oApostrophe$_gApostrophe$_sh$_ch]'), '');
  // Tovush taqlidida o' va o farqi muhim emas (O' tuguni "oorr" deb yozilgan)
  if (lenient) s = s.replaceAll(_oApostrophe, 'o');
  return s;
}

/// "Drrr" → d+r+ : har bir tovush istalgancha takrorlanishi mumkin.
RegExp _repeatPattern(String target) {
  final buffer = StringBuffer();
  for (int i = 0; i < target.length; i++) {
    if (i == 0 || target[i] != target[i - 1]) {
      buffer.write('${RegExp.escape(target[i])}+');
    }
  }
  return RegExp(buffer.toString());
}
