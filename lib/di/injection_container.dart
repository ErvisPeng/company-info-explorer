import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:company_info_explorer/data/datasources/twse_remote_datasource.dart';
import 'package:company_info_explorer/data/datasources/watchlist_local_datasource.dart';
import 'package:company_info_explorer/data/repositories/company_repository_impl.dart';
import 'package:company_info_explorer/domain/repositories/company_repository.dart';
import 'package:company_info_explorer/domain/usecases/load_companies_usecase.dart';
import 'package:company_info_explorer/domain/usecases/get_industries_usecase.dart';
import 'package:company_info_explorer/domain/usecases/get_companies_by_industry_usecase.dart';
import 'package:company_info_explorer/domain/usecases/get_watchlist_usecase.dart';
import 'package:company_info_explorer/domain/usecases/add_to_watchlist_usecase.dart';
import 'package:company_info_explorer/domain/usecases/remove_from_watchlist_usecase.dart';
import 'package:company_info_explorer/domain/usecases/search_companies_usecase.dart';
import 'package:company_info_explorer/presentation/blocs/app/app_bloc.dart';
import 'package:company_info_explorer/presentation/blocs/industry_list/industry_list_bloc.dart';
import 'package:company_info_explorer/presentation/blocs/stock_search/stock_search_bloc.dart';
import 'package:company_info_explorer/presentation/blocs/company_list/company_list_bloc.dart';
import 'package:company_info_explorer/presentation/blocs/company_detail/company_detail_bloc.dart';
import 'package:company_info_explorer/presentation/blocs/watchlist/watchlist_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => prefs);
  sl.registerLazySingleton(() => http.Client());

  // Data Sources
  sl.registerLazySingleton(() => TwseRemoteDataSource(sl()));
  sl.registerLazySingleton(() => WatchlistLocalDataSource(sl()));

  // Repository
  sl.registerLazySingleton<CompanyRepository>(
    () => CompanyRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => LoadCompaniesUseCase(sl()));
  sl.registerLazySingleton(() => GetIndustriesUseCase());
  sl.registerLazySingleton(() => GetCompaniesByIndustryUseCase());
  sl.registerLazySingleton(() => GetWatchlistUseCase(sl()));
  sl.registerLazySingleton(() => AddToWatchlistUseCase(sl()));
  sl.registerLazySingleton(() => RemoveFromWatchlistUseCase(sl()));
  sl.registerLazySingleton(() => SearchCompaniesUseCase());

  // BLoCs
  sl.registerFactory(() => AppBloc(loadCompanies: sl()));
  sl.registerFactory(() => StockSearchBloc(searchCompanies: sl()));
  sl.registerFactory(() => IndustryListBloc(getIndustries: sl()));
  sl.registerFactory(() => CompanyListBloc(getCompaniesByIndustry: sl()));
  sl.registerFactory(
    () => CompanyDetailBloc(
      repository: sl(),
      addToWatchlist: sl(),
      removeFromWatchlist: sl(),
    ),
  );
  sl.registerFactory(
    () => WatchlistBloc(
      getWatchlist: sl(),
      removeFromWatchlist: sl(),
    ),
  );
}
