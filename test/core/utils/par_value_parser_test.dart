import 'package:flutter_test/flutter_test.dart';
import 'package:company_info_explorer/core/utils/par_value_parser.dart';

void main() {
  group('parseParValue', () {
    test('should parse "新台幣 10.0000元" to 10.0', () {
      expect(parseParValue('新台幣 10.0000元'), 10.0);
    });
    test('should parse "新台幣 1.0000元" to 1.0', () {
      expect(parseParValue('新台幣 1.0000元'), 1.0);
    });
    test('should return 0 for empty string', () {
      expect(parseParValue(''), 0.0);
    });
    test('should return 0 for unparseable string', () {
      expect(parseParValue('－'), 0.0);
    });
  });

  group('calculateIssuedShares', () {
    test('should calculate issued shares correctly', () {
      expect(calculateIssuedShares(73561817420, 10.0, 0), 7356181742);
    });
    test('should subtract special shares', () {
      expect(calculateIssuedShares(100000000, 10.0, 200000), 9800000);
    });
    test('should return 0 when par value is 0', () {
      expect(calculateIssuedShares(100000000, 0.0, 0), 0);
    });
  });
}
