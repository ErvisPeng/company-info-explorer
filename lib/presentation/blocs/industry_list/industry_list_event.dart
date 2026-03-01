import 'package:equatable/equatable.dart';
import 'package:company_info_explorer/domain/entities/company.dart';

abstract class IndustryListEvent extends Equatable {
  const IndustryListEvent();
  @override
  List<Object> get props => [];
}

class LoadIndustries extends IndustryListEvent {
  final List<Company> companies;
  const LoadIndustries(this.companies);
  @override
  List<Object> get props => [companies];
}
