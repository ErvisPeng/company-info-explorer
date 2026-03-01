double parseParValue(String raw) {
  if (raw.isEmpty || raw == '－') return 0.0;
  final match = RegExp(r'[\d.]+').firstMatch(raw);
  if (match == null) return 0.0;
  return double.tryParse(match.group(0)!) ?? 0.0;
}

int calculateIssuedShares(
  double paidInCapital,
  double parValue,
  int specialShares,
) {
  if (parValue == 0.0) return 0;
  return (paidInCapital / parValue).toInt() - specialShares;
}
