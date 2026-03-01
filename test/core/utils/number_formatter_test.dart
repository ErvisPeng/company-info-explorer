import 'package:flutter_test/flutter_test.dart';
import 'package:company_info_explorer/core/utils/number_formatter.dart';

void main() {
  group('formatWithCommas', () {
    test('should format large numbers with commas', () {
      expect(formatWithCommas(73561817420), '73,561,817,420');
    });
    test('should format zero', () {
      expect(formatWithCommas(0), '0');
    });
    test('should format numbers less than 1000 without commas', () {
      expect(formatWithCommas(999), '999');
    });
    test('should format exactly 1000', () {
      expect(formatWithCommas(1000), '1,000');
    });
    test('should handle negative numbers', () {
      expect(formatWithCommas(-1234567), '-1,234,567');
    });
  });
}
