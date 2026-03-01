import 'package:company_info_explorer/core/utils/html_entity_decoder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('decodeHtmlEntities', () {
    test('應解碼十進位 numeric entity', () {
      expect(decodeHtmlEntities('余凌&#20914;'), '余凌冲');
    });

    test('應解碼十六進位 numeric entity', () {
      expect(decodeHtmlEntities('&#x4e2d;&#x83EF;'), '中華');
    });

    test('應解碼多個 entities', () {
      expect(decodeHtmlEntities('&#26519;&#20426;&#23439;'), '林俊宏');
    });

    test('無 entity 時原樣回傳', () {
      expect(decodeHtmlEntities('蔡清松'), '蔡清松');
    });

    test('空字串回傳空字串', () {
      expect(decodeHtmlEntities(''), '');
    });
  });
}
