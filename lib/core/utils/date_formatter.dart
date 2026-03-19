String formatDate(String raw) {
  if (raw.length != 8) return raw;
  return '${raw.substring(0, 4)}/${raw.substring(4, 6)}/${raw.substring(6, 8)}';
}
