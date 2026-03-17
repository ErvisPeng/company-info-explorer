import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:company_info_explorer/core/error/failures.dart';
import 'package:company_info_explorer/domain/usecases/load_companies_usecase.dart';
import 'app_event.dart';
import 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final LoadCompaniesUseCase loadCompanies;

  AppBloc({required this.loadCompanies}) : super(AppInitial()) {
    on<AppStarted>(_onAppStarted);
  }

  Future<void> _onAppStarted(
    AppStarted event,
    Emitter<AppState> emit,
  ) async {
    emit(AppLoading());
    try {
      final companies = await loadCompanies();
      emit(AppLoaded(companies));
    } on Failure catch (f) {
      emit(AppError(f.message));
    } catch (e) {
      emit(AppError('發生未預期的錯誤: $e'));
    }
  }
}
