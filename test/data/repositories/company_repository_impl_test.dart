import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:company_info_explorer/data/datasources/twse_remote_datasource.dart';
import 'package:company_info_explorer/data/datasources/watchlist_local_datasource.dart';
import 'package:company_info_explorer/data/models/company_model.dart';
import 'package:company_info_explorer/data/repositories/company_repository_impl.dart';

class MockRemoteDataSource extends Mock implements TwseRemoteDataSource {}

class MockLocalDataSource extends Mock implements WatchlistLocalDataSource {}

void main() {
  late CompanyRepositoryImpl repository;
  late MockRemoteDataSource mockRemote;
  late MockLocalDataSource mockLocal;

  setUp(() {
    mockRemote = MockRemoteDataSource();
    mockLocal = MockLocalDataSource();
    repository = CompanyRepositoryImpl(
      remoteDataSource: mockRemote,
      localDataSource: mockLocal,
    );
  });

  final testModels = [
    const CompanyModel(
      stockCode: '1101',
      name: '臺灣水泥股份有限公司',
      shortName: '台泥',
      industryCode: '01',
      chairman: '張安平',
      generalManager: '張安平',
      address: '台北市中山北路2段113號',
      phone: '(02)2531-7099',
      taxId: '11913502',
      foundedDate: '19501229',
      listedDate: '19620209',
      paidInCapital: 73561817420,
      parValueDesc: '新台幣 10.0000元',
      parValue: 10.0,
      specialShares: 0,
      privateShares: 0,
      website: 'https://www.taiwancement.com',
    ),
  ];

  group('fetchAllCompanies', () {
    test('should return companies from remote data source', () async {
      when(() => mockRemote.fetchCompanies())
          .thenAnswer((_) async => testModels);

      final result = await repository.fetchAllCompanies();

      expect(result.length, 1);
      expect(result[0].stockCode, '1101');
      verify(() => mockRemote.fetchCompanies()).called(1);
    });

    test('should cache companies after first fetch', () async {
      when(() => mockRemote.fetchCompanies())
          .thenAnswer((_) async => testModels);

      await repository.fetchAllCompanies();
      final result = await repository.fetchAllCompanies();

      expect(result.length, 1);
      verify(() => mockRemote.fetchCompanies()).called(1);
    });
  });

  group('watchlist operations', () {
    test('addToWatchlist should add stock code and save', () async {
      when(() => mockLocal.getWatchlist()).thenReturn([]);
      when(() => mockLocal.saveWatchlist(any())).thenAnswer((_) async {});

      await repository.addToWatchlist('1101');

      verify(() => mockLocal.saveWatchlist(['1101'])).called(1);
    });

    test('addToWatchlist should not add duplicate', () async {
      when(() => mockLocal.getWatchlist()).thenReturn(['1101']);
      when(() => mockLocal.saveWatchlist(any())).thenAnswer((_) async {});

      await repository.addToWatchlist('1101');

      verifyNever(() => mockLocal.saveWatchlist(any()));
    });

    test('removeFromWatchlist should remove stock code and save', () async {
      when(() => mockLocal.getWatchlist()).thenReturn(['1101', '2330']);
      when(() => mockLocal.saveWatchlist(any())).thenAnswer((_) async {});

      await repository.removeFromWatchlist('1101');

      verify(() => mockLocal.saveWatchlist(['2330'])).called(1);
    });

    test('getWatchlist should return list from local data source', () async {
      when(() => mockLocal.getWatchlist()).thenReturn(['1101']);

      final result = await repository.getWatchlist();

      expect(result, ['1101']);
    });
  });
}
