import 'package:company_info_explorer/domain/entities/company.dart';

abstract class CompanyRepository {
  Future<List<Company>> fetchAllCompanies();
  Future<List<String>> getWatchlist();
  Future<void> addToWatchlist(String stockCode);
  Future<void> removeFromWatchlist(String stockCode);
}
