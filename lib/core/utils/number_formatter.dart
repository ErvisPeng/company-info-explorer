String formatWithCommas(num value) {
  final isNegative = value < 0;
  final absString = value.abs().toInt().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < absString.length; i++) {
    if (i > 0 && (absString.length - i) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(absString[i]);
  }
  return isNegative ? '-${buffer.toString()}' : buffer.toString();
}
