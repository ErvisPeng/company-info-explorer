import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:company_info_explorer/domain/usecases/get_industries_usecase.dart';
import 'industry_list_event.dart';
import 'industry_list_state.dart';

class IndustryListBloc extends Bloc<IndustryListEvent, IndustryListState> {
  final GetIndustriesUseCase getIndustries;

  IndustryListBloc({required this.getIndustries})
      : super(IndustryListInitial()) {
    on<LoadIndustries>(_onLoadIndustries);
  }

  void _onLoadIndustries(
    LoadIndustries event,
    Emitter<IndustryListState> emit,
  ) {
    final industries = getIndustries(event.companies);
    emit(IndustryListLoaded(industries));
  }
}
