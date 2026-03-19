import 'package:company_info_explorer/core/error/failures.dart';
import 'package:company_info_explorer/domain/entities/company.dart';
import 'package:company_info_explorer/domain/repositories/company_repository.dart';

class LoadCompaniesUseCase {
  final CompanyRepository repository;

  LoadCompaniesUseCase(this.repository);

  Future<List<Company>> call() async {
    try {
      return await repository.fetchAllCompanies();
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('無法載入公司資料: $e');
    }
  }
}
