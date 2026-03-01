import 'package:flutter_test/flutter_test.dart';
import 'package:company_info_explorer/domain/entities/company.dart';
import 'package:company_info_explorer/domain/usecases/get_industries_usecase.dart';

import '../../helpers/test_data.dart';

void main() {
  late GetIndustriesUseCase useCase;

  setUp(() {
    useCase = GetIndustriesUseCase();
  });

  group('GetIndustriesUseCase', () {
    test('should group companies by industry and return sorted industries', () {
      final result = useCase(testCompanies);

      expect(result.length, 2);
      expect(result[0].code, '01');
      expect(result[0].name, '水泥工業');
      expect(result[0].companyCount, 2);
      expect(result[1].code, '24');
      expect(result[1].name, '半導體業');
      expect(result[1].companyCount, 1);
    });

    test('should return empty list for empty input', () {
      expect(useCase([]), isEmpty);
    });

    test('should skip companies with unknown industry codes', () {
      const unknownCompany = Company(
        stockCode: '9999',
        name: 'Test',
        shortName: 'Test',
        industryCode: 'XX',
        chairman: '',
        generalManager: '',
        address: '',
        phone: '',
        taxId: '',
        foundedDate: '',
        listedDate: '',
        paidInCapital: 0,
        parValueDesc: '',
        parValue: 0,
        specialShares: 0,
        privateShares: 0,
      );
      expect(useCase([unknownCompany]), isEmpty);
    });
  });
}
