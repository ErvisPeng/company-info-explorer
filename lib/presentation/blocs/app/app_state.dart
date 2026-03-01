import 'package:equatable/equatable.dart';
import 'package:company_info_explorer/domain/entities/company.dart';

abstract class AppState extends Equatable {
  const AppState();
  @override
  List<Object> get props => [];
}

class AppInitial extends AppState {}

class AppLoading extends AppState {}

class AppLoaded extends AppState {
  final List<Company> companies;
  const AppLoaded(this.companies);
  @override
  List<Object> get props => [companies];
}

class AppError extends AppState {
  final String message;
  const AppError(this.message);
  @override
  List<Object> get props => [message];
}
