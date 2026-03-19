import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:company_info_explorer/domain/usecases/search_companies_usecase.dart';
import 'package:company_info_explorer/presentation/blocs/stock_search/stock_search_bloc.dart';
import 'package:company_info_explorer/presentation/blocs/stock_search/stock_search_event.dart';
import 'package:company_info_explorer/presentation/blocs/stock_search/stock_search_state.dart';
import '../../helpers/test_data.dart';

void main() {
  group('StockSearchBloc', () {
    test('初始狀態為 StockSearchInitial', () {
      final bloc = StockSearchBloc(searchCompanies: SearchCompaniesUseCase());
      expect(bloc.state, isA<StockSearchInitial>());
      bloc.close();
    });

    blocTest<StockSearchBloc, StockSearchState>(
      'SearchStocks("233", companies) → StockSearchResults([台積電])',
      build: () => StockSearchBloc(searchCompanies: SearchCompaniesUseCase()),
      act: (bloc) => bloc.add(SearchStocks('233', testCompanies)),
      expect: () => [
        isA<StockSearchResults>().having(
          (s) => s.results,
          'results',
          [testCompany3],
        ),
      ],
    );

    blocTest<StockSearchBloc, StockSearchState>(
      'SearchStocks("不存在", companies) → StockSearchEmpty("不存在")',
      build: () => StockSearchBloc(searchCompanies: SearchCompaniesUseCase()),
      act: (bloc) => bloc.add(SearchStocks('不存在', testCompanies)),
      expect: () => [
        isA<StockSearchEmpty>().having((s) => s.query, 'query', '不存在'),
      ],
    );

    blocTest<StockSearchBloc, StockSearchState>(
      'SearchStocks("", companies) → StockSearchInitial',
      build: () => StockSearchBloc(searchCompanies: SearchCompaniesUseCase()),
      act: (bloc) => bloc.add(SearchStocks('', testCompanies)),
      expect: () => [isA<StockSearchInitial>()],
    );

    blocTest<StockSearchBloc, StockSearchState>(
      'ClearSearch → StockSearchInitial',
      build: () => StockSearchBloc(searchCompanies: SearchCompaniesUseCase()),
      seed: () => const StockSearchResults([testCompany1]),
      act: (bloc) => bloc.add(const ClearSearch()),
      expect: () => [isA<StockSearchInitial>()],
    );
  });
}
