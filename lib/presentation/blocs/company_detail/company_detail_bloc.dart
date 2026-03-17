import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:company_info_explorer/core/error/failures.dart';
import 'package:company_info_explorer/domain/usecases/add_to_watchlist_usecase.dart';
import 'package:company_info_explorer/domain/usecases/remove_from_watchlist_usecase.dart';
import 'package:company_info_explorer/domain/repositories/company_repository.dart';
import 'company_detail_event.dart';
import 'company_detail_state.dart';

class CompanyDetailBloc
    extends Bloc<CompanyDetailEvent, CompanyDetailState> {
  final CompanyRepository repository;
  final AddToWatchlistUseCase addToWatchlist;
  final RemoveFromWatchlistUseCase removeFromWatchlist;

  CompanyDetailBloc({
    required this.repository,
    required this.addToWatchlist,
    required this.removeFromWatchlist,
  }) : super(CompanyDetailInitial()) {
    on<LoadCompanyDetail>(_onLoad);
    on<ToggleWatchlist>(_onToggle);
  }

  Future<void> _onLoad(
    LoadCompanyDetail event,
    Emitter<CompanyDetailState> emit,
  ) async {
    try {
      final watchlist = await repository.getWatchlist();
      final isWatched = watchlist.contains(event.stockCode);
      emit(CompanyDetailLoaded(isWatched: isWatched));
    } on Failure catch (f) {
      emit(CompanyDetailError(f.message));
    } catch (e) {
      emit(CompanyDetailError('無法載入公司詳情: $e'));
    }
  }

  Future<void> _onToggle(
    ToggleWatchlist event,
    Emitter<CompanyDetailState> emit,
  ) async {
    try {
      if (event.currentlyWatched) {
        await removeFromWatchlist(event.stockCode);
      } else {
        await addToWatchlist(event.stockCode);
      }
      emit(CompanyDetailLoaded(isWatched: !event.currentlyWatched));
    } on Failure catch (f) {
      emit(CompanyDetailError(f.message));
    } catch (e) {
      emit(CompanyDetailError('無法更新追蹤狀態: $e'));
    }
  }
}
