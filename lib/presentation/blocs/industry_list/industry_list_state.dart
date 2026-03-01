import 'package:equatable/equatable.dart';
import 'package:company_info_explorer/domain/entities/industry.dart';

abstract class IndustryListState extends Equatable {
  const IndustryListState();
  @override
  List<Object> get props => [];
}

class IndustryListInitial extends IndustryListState {}

class IndustryListLoaded extends IndustryListState {
  final List<Industry> industries;
  const IndustryListLoaded(this.industries);
  @override
  List<Object> get props => [industries];
}
