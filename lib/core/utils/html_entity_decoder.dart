/// 解碼 HTML numeric entities（&#NNNN; 和 &#xHHHH;）
String decodeHtmlEntities(String input) {
  return input.replaceAllMapped(
    RegExp(r'&#x([0-9a-fA-F]+);|&#(\d+);'),
    (match) {
      final hex = match.group(1);
      final dec = match.group(2);
      final codePoint = hex != null ? int.parse(hex, radix: 16) : int.parse(dec!);
      return String.fromCharCode(codePoint);
    },
  );
}
