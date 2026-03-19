import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:company_info_explorer/domain/entities/company.dart';
import 'package:company_info_explorer/di/injection_container.dart' as di;
import 'package:company_info_explorer/presentation/blocs/company_detail/company_detail_bloc.dart';
import 'package:company_info_explorer/presentation/blocs/company_detail/company_detail_state.dart';
import 'package:company_info_explorer/presentation/blocs/company_detail/company_detail_event.dart';
import 'package:company_info_explorer/presentation/pages/company_detail_page.dart';
import 'package:company_info_explorer/domain/repositories/company_repository.dart';
import 'package:company_info_explorer/domain/usecases/add_to_watchlist_usecase.dart';
import 'package:company_info_explorer/domain/usecases/remove_from_watchlist_usecase.dart';

class MockCompanyRepository extends Mock implements CompanyRepository {}

const _testCompany = Company(
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
);

const _testCompanyWithSpecialShares = Company(
  stockCode: '1102',
  name: '亞洲水泥股份有限公司',
  shortName: '亞泥',
  industryCode: '01',
  chairman: '徐旭東',
  generalManager: '李坤炎',
  address: '台北市民生東路1段27號',
  phone: '(02)2521-7271',
  taxId: '03706301',
  foundedDate: '19570209',
  listedDate: '19620209',
  paidInCapital: 33646617490,
  parValueDesc: '新台幣 10.0000元',
  parValue: 10.0,
  specialShares: 1000000,
  privateShares: 0,
  website: null,
);

void main() {
  late MockCompanyRepository mockRepo;

  setUp(() {
    mockRepo = MockCompanyRepository();
    // Reset GetIt before each test
    if (di.sl.isRegistered<CompanyDetailBloc>()) {
      di.sl.unregister<CompanyDetailBloc>();
    }
  });

  Widget buildTestWidget(Company company) {
    di.sl.registerFactory<CompanyDetailBloc>(
      () => CompanyDetailBloc(
        repository: mockRepo,
        addToWatchlist: AddToWatchlistUseCase(mockRepo),
        removeFromWatchlist: RemoveFromWatchlistUseCase(mockRepo),
      ),
    );

    return MaterialApp(
      home: CompanyDetailPage(
        company: company,
        industryName: '水泥工業',
        allCompanies: const [_testCompany, _testCompanyWithSpecialShares],
      ),
    );
  }

  group('CompanyDetailPage', () {
    testWidgets('displays company basic info', (tester) async {
      when(() => mockRepo.getWatchlist()).thenAnswer((_) async => []);
      await tester.pumpWidget(buildTestWidget(_testCompany));
      await tester.pumpAndSettle();

      expect(find.text('臺灣水泥股份有限公司'), findsOneWidget);
      expect(find.text('張安平'), findsNWidgets(2)); // chairman & GM
      expect(find.text('水泥工業'), findsNWidgets(2)); // appbar + row
      expect(find.text('1950/12/29'), findsOneWidget);
      expect(find.text('1962/02/09'), findsOneWidget);
    });

    testWidgets('hides special shares when value is 0', (tester) async {
      when(() => mockRepo.getWatchlist()).thenAnswer((_) async => []);
      await tester.pumpWidget(buildTestWidget(_testCompany));
      await tester.pumpAndSettle();

      expect(find.text('特別股'), findsNothing);
    });

    testWidgets('shows special shares when value > 0', (tester) async {
      when(() => mockRepo.getWatchlist()).thenAnswer((_) async => []);
      await tester.pumpWidget(buildTestWidget(_testCompanyWithSpecialShares));
      await tester.pumpAndSettle();

      expect(find.text('特別股'), findsOneWidget);
    });

    testWidgets('shows star icon as filled when watched', (tester) async {
      when(() => mockRepo.getWatchlist()).thenAnswer((_) async => ['1101']);
      await tester.pumpWidget(buildTestWidget(_testCompany));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('shows star icon as outline when not watched', (tester) async {
      when(() => mockRepo.getWatchlist()).thenAnswer((_) async => []);
      await tester.pumpWidget(buildTestWidget(_testCompany));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.star_border), findsOneWidget);
    });

    testWidgets('shows website icon when website is present', (tester) async {
      when(() => mockRepo.getWatchlist()).thenAnswer((_) async => []);
      await tester.pumpWidget(buildTestWidget(_testCompany));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.language), findsOneWidget);
    });

    testWidgets('hides website icon when website is null', (tester) async {
      when(() => mockRepo.getWatchlist()).thenAnswer((_) async => []);
      await tester.pumpWidget(buildTestWidget(_testCompanyWithSpecialShares));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.language), findsNothing);
    });
  });
}
