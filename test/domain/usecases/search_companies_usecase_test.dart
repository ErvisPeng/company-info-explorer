import 'package:flutter_test/flutter_test.dart';
import 'package:company_info_explorer/domain/entities/company.dart';
import 'package:company_info_explorer/domain/usecases/search_companies_usecase.dart';

import '../../helpers/test_data.dart';

void main() {
  late SearchCompaniesUseCase useCase;

  setUp(() {
    useCase = SearchCompaniesUseCase();
  });

  group('SearchCompaniesUseCase', () {
    test('空 query 應回傳空列表', () {
      expect(useCase(testCompanies, ''), isEmpty);
    });

    test('純空白 query 應回傳空列表', () {
      expect(useCase(testCompanies, '   '), isEmpty);
    });

    test('stockCode 前綴搜尋：「233」應找到「2330」', () {
      final result = useCase(testCompanies, '233');
      expect(result.length, 1);
      expect(result.first.stockCode, '2330');
    });

    test('stockCode 前綴不匹配中間：「330」不應找到「2330」', () {
      final result = useCase(testCompanies, '330');
      expect(result, isEmpty);
    });

    test('shortName 包含搜尋：「積」應找到「台積電」', () {
      final result = useCase(testCompanies, '積');
      expect(result.length, 1);
      expect(result.first.stockCode, '2330');
    });

    test('同時匹配代號和名稱的公司不應重複出現', () {
      // testCompany3 stockCode 是 '2330'，shortName 是 '台積電'
      // 用 '2330' 搜尋時，只命中 stockCode，結果應只有一筆
      final result = useCase(testCompanies, '2330');
      expect(result.length, 1);
      expect(result.first.stockCode, '2330');
    });

    test('結果應按 stockCode 排序', () {
      // '1' 前綴可命中 '1101' 和 '1102'
      final result = useCase(testCompanies, '1');
      expect(result.length, 2);
      expect(result[0].stockCode, '1101');
      expect(result[1].stockCode, '1102');
    });

    test('無匹配 → 回傳空列表', () {
      expect(useCase(testCompanies, 'xyz'), isEmpty);
    });

    test('空公司列表 → 回傳空列表', () {
      expect(useCase([], '台'), isEmpty);
    });

    test('shortName 包含搜尋：「泥」應同時找到「台泥」和「亞泥」並按 stockCode 排序', () {
      final result = useCase(testCompanies, '泥');
      expect(result.length, 2);
      expect(result[0].stockCode, '1101');
      expect(result[1].stockCode, '1102');
    });
  });
}
