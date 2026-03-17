import 'package:company_info_explorer/core/error/failures.dart';
import 'package:company_info_explorer/domain/entities/company.dart';
import 'package:company_info_explorer/domain/repositories/company_repository.dart';

class GetWatchlistUseCase {
  final CompanyRepository repository;

  GetWatchlistUseCase(this.repository);

  Future<List<Company>> call(List<Company> allCompanies) async {
    try {
      final watchlistIds = await repository.getWatchlist();
      final idSet = watchlistIds.toSet();
      return allCompanies.where((c) => idSet.contains(c.stockCode)).toList();
    } on Failure {
      rethrow;
    } catch (e) {
      throw CacheFailure('無法載入追蹤清單: $e');
    }
  }
}
