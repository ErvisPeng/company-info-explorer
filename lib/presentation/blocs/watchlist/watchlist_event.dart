import 'package:equatable/equatable.dart';
import 'package:company_info_explorer/domain/entities/company.dart';

abstract class WatchlistEvent extends Equatable {
  const WatchlistEvent();
  @override
  List<Object> get props => [];
}

class LoadWatchlist extends WatchlistEvent {
  final List<Company> allCompanies;
  const LoadWatchlist(this.allCompanies);
  @override
  List<Object> get props => [allCompanies];
}

class RemoveFromWatchlistEvent extends WatchlistEvent {
  final String stockCode;
  final List<Company> allCompanies;
  const RemoveFromWatchlistEvent(this.stockCode, this.allCompanies);
  @override
  List<Object> get props => [stockCode, allCompanies];
}
