import 'package:flutter_test/flutter_test.dart';
import 'package:company_info_explorer/core/utils/date_formatter.dart';

void main() {
  group('formatDate', () {
    test('formats 8-digit date string correctly', () {
      expect(formatDate('19501229'), '1950/12/29');
      expect(formatDate('20240101'), '2024/01/01');
    });

    test('returns raw string if not 8 characters', () {
      expect(formatDate('2024'), '2024');
      expect(formatDate(''), '');
      expect(formatDate('123456789'), '123456789');
    });
  });
}
