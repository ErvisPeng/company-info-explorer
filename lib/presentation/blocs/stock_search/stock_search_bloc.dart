import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:company_info_explorer/domain/usecases/search_companies_usecase.dart';
import 'stock_search_event.dart';
import 'stock_search_state.dart';

class StockSearchBloc extends Bloc<StockSearchEvent, StockSearchState> {
  final SearchCompaniesUseCase searchCompanies;

  StockSearchBloc({required this.searchCompanies})
      : super(StockSearchInitial()) {
    on<SearchStocks>(_onSearchStocks);
    on<ClearSearch>(_onClearSearch);
  }

  void _onSearchStocks(
    SearchStocks event,
    Emitter<StockSearchState> emit,
  ) {
    if (event.query.trim().isEmpty) {
      emit(StockSearchInitial());
      return;
    }

    final results = searchCompanies(event.companies, event.query);

    if (results.isEmpty) {
      emit(StockSearchEmpty(event.query));
    } else {
      emit(StockSearchResults(results));
    }
  }

  void _onClearSearch(
    ClearSearch event,
    Emitter<StockSearchState> emit,
  ) {
    emit(StockSearchInitial());
  }
}
