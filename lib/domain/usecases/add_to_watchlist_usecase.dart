import 'package:company_info_explorer/domain/repositories/company_repository.dart';

class AddToWatchlistUseCase {
  final CompanyRepository repository;

  AddToWatchlistUseCase(this.repository);

  Future<void> call(String stockCode) => repository.addToWatchlist(stockCode);
}
