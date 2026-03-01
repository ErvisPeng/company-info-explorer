import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:company_info_explorer/domain/usecases/get_watchlist_usecase.dart';
import 'package:company_info_explorer/domain/usecases/remove_from_watchlist_usecase.dart';
import 'watchlist_event.dart';
import 'watchlist_state.dart';

class WatchlistBloc extends Bloc<WatchlistEvent, WatchlistState> {
  final GetWatchlistUseCase getWatchlist;
  final RemoveFromWatchlistUseCase removeFromWatchlist;

  WatchlistBloc({
    required this.getWatchlist,
    required this.removeFromWatchlist,
  }) : super(WatchlistInitial()) {
    on<LoadWatchlist>(_onLoad);
    on<RemoveFromWatchlistEvent>(_onRemove);
  }

  Future<void> _onLoad(
    LoadWatchlist event,
    Emitter<WatchlistState> emit,
  ) async {
    emit(WatchlistLoading());
    final companies = await getWatchlist(event.allCompanies);
    emit(WatchlistLoaded(companies));
  }

  Future<void> _onRemove(
    RemoveFromWatchlistEvent event,
    Emitter<WatchlistState> emit,
  ) async {
    await removeFromWatchlist(event.stockCode);
    final companies = await getWatchlist(event.allCompanies);
    emit(WatchlistLoaded(companies));
  }
}
