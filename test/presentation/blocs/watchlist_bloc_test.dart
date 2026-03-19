import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:company_info_explorer/core/error/failures.dart';
import 'package:company_info_explorer/domain/usecases/get_watchlist_usecase.dart';
import 'package:company_info_explorer/domain/usecases/remove_from_watchlist_usecase.dart';
import 'package:company_info_explorer/domain/repositories/company_repository.dart';
import 'package:company_info_explorer/presentation/blocs/watchlist/watchlist_bloc.dart';
import 'package:company_info_explorer/presentation/blocs/watchlist/watchlist_event.dart';
import 'package:company_info_explorer/presentation/blocs/watchlist/watchlist_state.dart';
import '../../helpers/test_data.dart';

class MockCompanyRepository extends Mock implements CompanyRepository {}

void main() {
  late MockCompanyRepository mockRepo;
  setUp(() {
    mockRepo = MockCompanyRepository();
  });

  group('WatchlistBloc', () {
    blocTest<WatchlistBloc, WatchlistState>(
      'emits [WatchlistLoading, WatchlistLoaded] on LoadWatchlist',
      build: () {
        when(() => mockRepo.getWatchlist())
            .thenAnswer((_) async => ['1101']);
        return WatchlistBloc(
          getWatchlist: GetWatchlistUseCase(mockRepo),
          removeFromWatchlist: RemoveFromWatchlistUseCase(mockRepo),
        );
      },
      act: (bloc) => bloc.add(LoadWatchlist(testCompanies)),
      expect: () => [
        isA<WatchlistLoading>(),
        isA<WatchlistLoaded>()
            .having((s) => s.companies.length, 'watched count', 1),
      ],
    );

    blocTest<WatchlistBloc, WatchlistState>(
      'emits updated list after RemoveFromWatchlistEvent',
      build: () {
        when(() => mockRepo.removeFromWatchlist('1101'))
            .thenAnswer((_) async {});
        when(() => mockRepo.getWatchlist()).thenAnswer((_) async => []);
        return WatchlistBloc(
          getWatchlist: GetWatchlistUseCase(mockRepo),
          removeFromWatchlist: RemoveFromWatchlistUseCase(mockRepo),
        );
      },
      act: (bloc) =>
          bloc.add(RemoveFromWatchlistEvent('1101', testCompanies)),
      expect: () => [
        isA<WatchlistLoaded>()
            .having((s) => s.companies.length, 'watched count', 0),
      ],
    );

    blocTest<WatchlistBloc, WatchlistState>(
      'emits [WatchlistLoading, WatchlistError] when load fails',
      build: () {
        when(() => mockRepo.getWatchlist())
            .thenThrow(const CacheFailure('讀取失敗'));
        return WatchlistBloc(
          getWatchlist: GetWatchlistUseCase(mockRepo),
          removeFromWatchlist: RemoveFromWatchlistUseCase(mockRepo),
        );
      },
      act: (bloc) => bloc.add(LoadWatchlist(testCompanies)),
      expect: () => [
        isA<WatchlistLoading>(),
        isA<WatchlistError>(),
      ],
    );

    blocTest<WatchlistBloc, WatchlistState>(
      'emits [WatchlistError] when remove fails',
      build: () {
        when(() => mockRepo.removeFromWatchlist('1101'))
            .thenThrow(const CacheFailure('移除失敗'));
        return WatchlistBloc(
          getWatchlist: GetWatchlistUseCase(mockRepo),
          removeFromWatchlist: RemoveFromWatchlistUseCase(mockRepo),
        );
      },
      act: (bloc) =>
          bloc.add(RemoveFromWatchlistEvent('1101', testCompanies)),
      expect: () => [isA<WatchlistError>()],
    );
  });
}
