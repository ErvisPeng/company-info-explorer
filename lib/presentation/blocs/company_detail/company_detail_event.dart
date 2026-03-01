import 'package:equatable/equatable.dart';

abstract class CompanyDetailEvent extends Equatable {
  const CompanyDetailEvent();
  @override
  List<Object> get props => [];
}

class LoadCompanyDetail extends CompanyDetailEvent {
  final String stockCode;
  const LoadCompanyDetail(this.stockCode);
  @override
  List<Object> get props => [stockCode];
}

class ToggleWatchlist extends CompanyDetailEvent {
  final String stockCode;
  final bool currentlyWatched;
  const ToggleWatchlist(this.stockCode, this.currentlyWatched);
  @override
  List<Object> get props => [stockCode, currentlyWatched];
}
