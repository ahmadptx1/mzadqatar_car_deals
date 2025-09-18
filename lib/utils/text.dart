String decodeUnicodeEscapes(String input) {
  // Replace sequences like \u0627 with actual unicode characters
  return input.replaceAllMapped(RegExp(r"\\u([0-9a-fA-F]{4})"), (m) {
    final code = int.parse(m[1]!, radix: 16);
    return String.fromCharCode(code);
  });
}
