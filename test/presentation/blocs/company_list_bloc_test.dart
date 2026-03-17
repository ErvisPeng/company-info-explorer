import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:company_info_explorer/domain/usecases/get_companies_by_industry_usecase.dart';
import 'package:company_info_explorer/presentation/blocs/company_list/company_list_bloc.dart';
import 'package:company_info_explorer/presentation/blocs/company_list/company_list_event.dart';
import 'package:company_info_explorer/presentation/blocs/company_list/company_list_state.dart';
import '../../helpers/test_data.dart';

void main() {
  group('CompanyListBloc', () {
    blocTest<CompanyListBloc, CompanyListState>(
      'emits [CompanyListLoaded] with filtered companies for industry 01',
      build: () => CompanyListBloc(
        getCompaniesByIndustry: GetCompaniesByIndustryUseCase(),
      ),
      act: (bloc) => bloc.add(LoadCompanyList(testCompanies, '01')),
      expect: () => [
        isA<CompanyListLoaded>()
            .having((s) => s.companies.length, 'company count', 2)
            .having(
              (s) => s.companies.first.stockCode,
              'first stock code',
              '1101',
            ),
      ],
    );

    blocTest<CompanyListBloc, CompanyListState>(
      'emits [CompanyListLoaded] with filtered companies for industry 24',
      build: () => CompanyListBloc(
        getCompaniesByIndustry: GetCompaniesByIndustryUseCase(),
      ),
      act: (bloc) => bloc.add(LoadCompanyList(testCompanies, '24')),
      expect: () => [
        isA<CompanyListLoaded>()
            .having((s) => s.companies.length, 'company count', 1)
            .having(
              (s) => s.companies.first.stockCode,
              'first stock code',
              '2330',
            ),
      ],
    );

    blocTest<CompanyListBloc, CompanyListState>(
      'emits [CompanyListLoaded] with empty list for unknown industry',
      build: () => CompanyListBloc(
        getCompaniesByIndustry: GetCompaniesByIndustryUseCase(),
      ),
      act: (bloc) => bloc.add(LoadCompanyList(testCompanies, '99')),
      expect: () => [
        isA<CompanyListLoaded>()
            .having((s) => s.companies.length, 'company count', 0),
      ],
    );

    blocTest<CompanyListBloc, CompanyListState>(
      'companies are sorted by stock code',
      build: () => CompanyListBloc(
        getCompaniesByIndustry: GetCompaniesByIndustryUseCase(),
      ),
      act: (bloc) => bloc.add(LoadCompanyList(testCompanies, '01')),
      expect: () => [
        isA<CompanyListLoaded>().having(
          (s) => s.companies.map((c) => c.stockCode).toList(),
          'stock codes',
          ['1101', '1102'],
        ),
      ],
    );
  });
}
