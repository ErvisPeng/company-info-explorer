import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:company_info_explorer/core/error/failures.dart';
import 'package:company_info_explorer/domain/repositories/company_repository.dart';
import 'package:company_info_explorer/domain/usecases/add_to_watchlist_usecase.dart';
import 'package:company_info_explorer/domain/usecases/remove_from_watchlist_usecase.dart';
import 'package:company_info_explorer/presentation/blocs/company_detail/company_detail_bloc.dart';
import 'package:company_info_explorer/presentation/blocs/company_detail/company_detail_event.dart';
import 'package:company_info_explorer/presentation/blocs/company_detail/company_detail_state.dart';

class MockCompanyRepository extends Mock implements CompanyRepository {}

void main() {
  late MockCompanyRepository mockRepo;

  setUp(() {
    mockRepo = MockCompanyRepository();
  });

  group('CompanyDetailBloc', () {
    group('LoadCompanyDetail', () {
      blocTest<CompanyDetailBloc, CompanyDetailState>(
        'emits [CompanyDetailLoaded(isWatched: true)] when stock is in watchlist',
        build: () {
          when(() => mockRepo.getWatchlist())
              .thenAnswer((_) async => ['1101', '2330']);
          return CompanyDetailBloc(
            repository: mockRepo,
            addToWatchlist: AddToWatchlistUseCase(mockRepo),
            removeFromWatchlist: RemoveFromWatchlistUseCase(mockRepo),
          );
        },
        act: (bloc) => bloc.add(const LoadCompanyDetail('1101')),
        expect: () => [
          isA<CompanyDetailLoaded>()
              .having((s) => s.isWatched, 'isWatched', true),
        ],
      );

      blocTest<CompanyDetailBloc, CompanyDetailState>(
        'emits [CompanyDetailLoaded(isWatched: false)] when stock is not in watchlist',
        build: () {
          when(() => mockRepo.getWatchlist())
              .thenAnswer((_) async => ['2330']);
          return CompanyDetailBloc(
            repository: mockRepo,
            addToWatchlist: AddToWatchlistUseCase(mockRepo),
            removeFromWatchlist: RemoveFromWatchlistUseCase(mockRepo),
          );
        },
        act: (bloc) => bloc.add(const LoadCompanyDetail('1101')),
        expect: () => [
          isA<CompanyDetailLoaded>()
              .having((s) => s.isWatched, 'isWatched', false),
        ],
      );

      blocTest<CompanyDetailBloc, CompanyDetailState>(
        'emits [CompanyDetailError] when loading fails',
        build: () {
          when(() => mockRepo.getWatchlist())
              .thenThrow(const CacheFailure('讀取失敗'));
          return CompanyDetailBloc(
            repository: mockRepo,
            addToWatchlist: AddToWatchlistUseCase(mockRepo),
            removeFromWatchlist: RemoveFromWatchlistUseCase(mockRepo),
          );
        },
        act: (bloc) => bloc.add(const LoadCompanyDetail('1101')),
        expect: () => [isA<CompanyDetailError>()],
      );
    });

    group('ToggleWatchlist', () {
      blocTest<CompanyDetailBloc, CompanyDetailState>(
        'adds to watchlist and emits [CompanyDetailLoaded(isWatched: true)]',
        build: () {
          when(() => mockRepo.addToWatchlist('1101'))
              .thenAnswer((_) async {});
          return CompanyDetailBloc(
            repository: mockRepo,
            addToWatchlist: AddToWatchlistUseCase(mockRepo),
            removeFromWatchlist: RemoveFromWatchlistUseCase(mockRepo),
          );
        },
        act: (bloc) => bloc.add(const ToggleWatchlist('1101', false)),
        expect: () => [
          isA<CompanyDetailLoaded>()
              .having((s) => s.isWatched, 'isWatched', true),
        ],
        verify: (_) {
          verify(() => mockRepo.addToWatchlist('1101')).called(1);
        },
      );

      blocTest<CompanyDetailBloc, CompanyDetailState>(
        'removes from watchlist and emits [CompanyDetailLoaded(isWatched: false)]',
        build: () {
          when(() => mockRepo.removeFromWatchlist('1101'))
              .thenAnswer((_) async {});
          return CompanyDetailBloc(
            repository: mockRepo,
            addToWatchlist: AddToWatchlistUseCase(mockRepo),
            removeFromWatchlist: RemoveFromWatchlistUseCase(mockRepo),
          );
        },
        act: (bloc) => bloc.add(const ToggleWatchlist('1101', true)),
        expect: () => [
          isA<CompanyDetailLoaded>()
              .having((s) => s.isWatched, 'isWatched', false),
        ],
        verify: (_) {
          verify(() => mockRepo.removeFromWatchlist('1101')).called(1);
        },
      );

      blocTest<CompanyDetailBloc, CompanyDetailState>(
        'emits [CompanyDetailError] when toggle fails',
        build: () {
          when(() => mockRepo.addToWatchlist('1101'))
              .thenThrow(const CacheFailure('儲存失敗'));
          return CompanyDetailBloc(
            repository: mockRepo,
            addToWatchlist: AddToWatchlistUseCase(mockRepo),
            removeFromWatchlist: RemoveFromWatchlistUseCase(mockRepo),
          );
        },
        act: (bloc) => bloc.add(const ToggleWatchlist('1101', false)),
        expect: () => [isA<CompanyDetailError>()],
      );
    });
  });
}
