import 'package:company_info_explorer/core/error/failures.dart';
import 'package:company_info_explorer/domain/repositories/company_repository.dart';

class RemoveFromWatchlistUseCase {
  final CompanyRepository repository;

  RemoveFromWatchlistUseCase(this.repository);

  Future<void> call(String stockCode) async {
    try {
      await repository.removeFromWatchlist(stockCode);
    } on Failure {
      rethrow;
    } catch (e) {
      throw CacheFailure('無法移除追蹤: $e');
    }
  }
}
