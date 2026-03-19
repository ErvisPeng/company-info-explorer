import 'package:equatable/equatable.dart';
import 'package:company_info_explorer/domain/entities/company.dart';

abstract class StockSearchState extends Equatable {
  const StockSearchState();
  @override
  List<Object> get props => [];
}

class StockSearchInitial extends StockSearchState {}

class StockSearchResults extends StockSearchState {
  final List<Company> results;
  const StockSearchResults(this.results);
  @override
  List<Object> get props => [results];
}

class StockSearchEmpty extends StockSearchState {
  final String query;
  const StockSearchEmpty(this.query);
  @override
  List<Object> get props => [query];
}
