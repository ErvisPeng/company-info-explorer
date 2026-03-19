import 'package:company_info_explorer/core/error/failures.dart';
import 'package:company_info_explorer/domain/repositories/company_repository.dart';

class AddToWatchlistUseCase {
  final CompanyRepository repository;

  AddToWatchlistUseCase(this.repository);

  Future<void> call(String stockCode) async {
    try {
      await repository.addToWatchlist(stockCode);
    } on Failure {
      rethrow;
    } catch (e) {
      throw CacheFailure('無法加入追蹤: $e');
    }
  }
}
