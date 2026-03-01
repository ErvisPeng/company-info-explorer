import 'package:equatable/equatable.dart';
import 'package:company_info_explorer/domain/entities/company.dart';

abstract class CompanyListEvent extends Equatable {
  const CompanyListEvent();
  @override
  List<Object> get props => [];
}

class LoadCompanyList extends CompanyListEvent {
  final List<Company> allCompanies;
  final String industryCode;
  const LoadCompanyList(this.allCompanies, this.industryCode);
  @override
  List<Object> get props => [allCompanies, industryCode];
}
