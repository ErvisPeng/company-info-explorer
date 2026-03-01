import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:company_info_explorer/domain/repositories/company_repository.dart';
import 'package:company_info_explorer/domain/usecases/add_to_watchlist_usecase.dart';
import 'package:company_info_explorer/domain/usecases/remove_from_watchlist_usecase.dart';

class MockCompanyRepository extends Mock implements CompanyRepository {}

void main() {
  late MockCompanyRepository mockRepository;

  setUp(() {
    mockRepository = MockCompanyRepository();
  });

  group('AddToWatchlistUseCase', () {
    test('should call repository addToWatchlist', () async {
      when(() => mockRepository.addToWatchlist('1101'))
          .thenAnswer((_) async {});

      final useCase = AddToWatchlistUseCase(mockRepository);
      await useCase('1101');

      verify(() => mockRepository.addToWatchlist('1101')).called(1);
    });
  });

  group('RemoveFromWatchlistUseCase', () {
    test('should call repository removeFromWatchlist', () async {
      when(() => mockRepository.removeFromWatchlist('1101'))
          .thenAnswer((_) async {});

      final useCase = RemoveFromWatchlistUseCase(mockRepository);
      await useCase('1101');

      verify(() => mockRepository.removeFromWatchlist('1101')).called(1);
    });
  });
}
