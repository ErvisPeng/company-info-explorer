import 'package:company_info_explorer/data/datasources/twse_remote_datasource.dart';
import 'package:company_info_explorer/data/datasources/watchlist_local_datasource.dart';
import 'package:company_info_explorer/domain/entities/company.dart';
import 'package:company_info_explorer/domain/repositories/company_repository.dart';

class CompanyRepositoryImpl implements CompanyRepository {
  final TwseRemoteDataSource remoteDataSource;
  final WatchlistLocalDataSource localDataSource;
  List<Company>? _cachedCompanies;

  CompanyRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<Company>> fetchAllCompanies() async {
    if (_cachedCompanies != null) return _cachedCompanies!;
    final models = await remoteDataSource.fetchCompanies();
    _cachedCompanies = models;
    return models;
  }

  @override
  Future<List<String>> getWatchlist() async {
    return localDataSource.getWatchlist();
  }

  @override
  Future<void> addToWatchlist(String stockCode) async {
    final current = localDataSource.getWatchlist();
    if (current.contains(stockCode)) return;
    await localDataSource.saveWatchlist([...current, stockCode]);
  }

  @override
  Future<void> removeFromWatchlist(String stockCode) async {
    final current = localDataSource.getWatchlist();
    final updated = current.where((id) => id != stockCode).toList();
    await localDataSource.saveWatchlist(updated);
  }
}
