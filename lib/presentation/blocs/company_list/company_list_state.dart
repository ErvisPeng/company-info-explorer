import 'package:equatable/equatable.dart';
import 'package:company_info_explorer/domain/entities/company.dart';

abstract class CompanyListState extends Equatable {
  const CompanyListState();
  @override
  List<Object> get props => [];
}

class CompanyListInitial extends CompanyListState {}

class CompanyListLoaded extends CompanyListState {
  final List<Company> companies;
  const CompanyListLoaded(this.companies);
  @override
  List<Object> get props => [companies];
}
