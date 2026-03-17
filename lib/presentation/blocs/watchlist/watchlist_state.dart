import 'package:equatable/equatable.dart';
import 'package:company_info_explorer/domain/entities/company.dart';

abstract class WatchlistState extends Equatable {
  const WatchlistState();
  @override
  List<Object> get props => [];
}

class WatchlistInitial extends WatchlistState {}

class WatchlistLoading extends WatchlistState {}

class WatchlistLoaded extends WatchlistState {
  final List<Company> companies;
  const WatchlistLoaded(this.companies);
  @override
  List<Object> get props => [companies];
}

class WatchlistError extends WatchlistState {
  final String message;
  const WatchlistError(this.message);
  @override
  List<Object> get props => [message];
}
