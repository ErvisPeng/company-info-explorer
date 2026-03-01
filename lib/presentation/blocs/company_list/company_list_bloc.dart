import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:company_info_explorer/domain/usecases/get_companies_by_industry_usecase.dart';
import 'company_list_event.dart';
import 'company_list_state.dart';

class CompanyListBloc extends Bloc<CompanyListEvent, CompanyListState> {
  final GetCompaniesByIndustryUseCase getCompaniesByIndustry;

  CompanyListBloc({required this.getCompaniesByIndustry})
      : super(CompanyListInitial()) {
    on<LoadCompanyList>(_onLoadCompanyList);
  }

  void _onLoadCompanyList(
    LoadCompanyList event,
    Emitter<CompanyListState> emit,
  ) {
    final companies =
        getCompaniesByIndustry(event.allCompanies, event.industryCode);
    emit(CompanyListLoaded(companies));
  }
}
