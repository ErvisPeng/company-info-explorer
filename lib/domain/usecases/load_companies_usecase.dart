import 'package:company_info_explorer/domain/entities/company.dart';
import 'package:company_info_explorer/domain/repositories/company_repository.dart';

class LoadCompaniesUseCase {
  final CompanyRepository repository;

  LoadCompaniesUseCase(this.repository);

  Future<List<Company>> call() => repository.fetchAllCompanies();
}
