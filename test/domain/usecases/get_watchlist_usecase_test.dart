import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:company_info_explorer/domain/repositories/company_repository.dart';
import 'package:company_info_explorer/domain/usecases/get_watchlist_usecase.dart';

import '../../helpers/test_data.dart';

class MockCompanyRepository extends Mock implements CompanyRepository {}

void main() {
  late GetWatchlistUseCase useCase;
  late MockCompanyRepository mockRepository;

  setUp(() {
    mockRepository = MockCompanyRepository();
    useCase = GetWatchlistUseCase(mockRepository);
  });

  group('GetWatchlistUseCase', () {
    test('should return watched companies from repository', () async {
      when(() => mockRepository.getWatchlist())
          .thenAnswer((_) async => ['1101', '2330']);

      final result = await useCase(testCompanies);

      expect(result.length, 2);
      expect(result[0].stockCode, '1101');
      expect(result[1].stockCode, '2330');
      verify(() => mockRepository.getWatchlist()).called(1);
    });

    test('should return empty list when no companies are watched', () async {
      when(() => mockRepository.getWatchlist())
          .thenAnswer((_) async => []);

      final result = await useCase(testCompanies);

      expect(result, isEmpty);
    });

    test('should skip watchlist IDs that do not match any company', () async {
      when(() => mockRepository.getWatchlist())
          .thenAnswer((_) async => ['9999']);

      final result = await useCase(testCompanies);

      expect(result, isEmpty);
    });
  });
}
