import 'package:flutter_bloc/flutter_bloc.dart';
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
    final watchlist = await repository.getWatchlist();
    final isWatched = watchlist.contains(event.stockCode);
    emit(CompanyDetailLoaded(isWatched: isWatched));
  }

  Future<void> _onToggle(
    ToggleWatchlist event,
    Emitter<CompanyDetailState> emit,
  ) async {
    if (event.currentlyWatched) {
      await removeFromWatchlist(event.stockCode);
    } else {
      await addToWatchlist(event.stockCode);
    }
    emit(CompanyDetailLoaded(isWatched: !event.currentlyWatched));
  }
}
