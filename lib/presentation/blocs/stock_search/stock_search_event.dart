import 'package:equatable/equatable.dart';
import 'package:company_info_explorer/domain/entities/company.dart';

abstract class StockSearchEvent extends Equatable {
  const StockSearchEvent();
  @override
  List<Object> get props => [];
}

class SearchStocks extends StockSearchEvent {
  final String query;
  final List<Company> companies;
  const SearchStocks(this.query, this.companies);
  @override
  List<Object> get props => [query, companies];
}

class ClearSearch extends StockSearchEvent {
  const ClearSearch();
}
