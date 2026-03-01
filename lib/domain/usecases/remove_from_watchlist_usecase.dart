import 'package:company_info_explorer/domain/repositories/company_repository.dart';

class RemoveFromWatchlistUseCase {
  final CompanyRepository repository;

  RemoveFromWatchlistUseCase(this.repository);

  Future<void> call(String stockCode) =>
      repository.removeFromWatchlist(stockCode);
}
