/// Normalizes French accented characters to their base ASCII equivalents
/// and strips spaces, punctuation, and special characters.
///
/// Used for forgiving answer validation. The original text should always
/// be preserved for display; this function is only for comparison purposes.
String normalizeAccents(String input) {
  final buffer = StringBuffer();
  for (final codeUnit in input.trim().toLowerCase().runes) {
    final normalized = _normalizeCodeUnit(codeUnit);
    // Keep only letters and digits, skip spaces/punctuation/special chars.
    if (_isLetterOrDigit(normalized)) {
      buffer.writeCharCode(normalized);
    }
  }
  return buffer.toString();
}

bool _isLetterOrDigit(int rune) {
  return (rune >= 0x61 && rune <= 0x7a) || // a-z
      (rune >= 0x30 && rune <= 0x39); // 0-9
}

int _normalizeCodeUnit(int rune) {
  return switch (rune) {
    // à á â ä ã
    0xe0 || 0xe1 || 0xe2 || 0xe4 || 0xe3 => 0x61, // a
    // è é ê ë
    0xe8 || 0xe9 || 0xea || 0xeb => 0x65, // e
    // ì í î ï
    0xec || 0xed || 0xee || 0xef => 0x69, // i
    // ò ó ô ö õ
    0xf2 || 0xf3 || 0xf4 || 0xf6 || 0xf5 => 0x6f, // o
    // ù ú û ü
    0xf9 || 0xfa || 0xfb || 0xfc => 0x75, // u
    // ç
    0xe7 => 0x63, // c
    // ñ
    0xf1 => 0x6e, // n
    // ÿ
    0xff => 0x79, // y
    _ => rune,
  };
}
