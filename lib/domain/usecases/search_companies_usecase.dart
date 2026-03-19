import 'package:company_info_explorer/domain/entities/company.dart';

class SearchCompaniesUseCase {
  List<Company> call(List<Company> companies, String query) {
    if (query.trim().isEmpty) return [];

    final queryLower = query.trim().toLowerCase();

    final results = companies.where((company) {
      final matchesStockCode =
          company.stockCode.toLowerCase().startsWith(queryLower);
      final matchesShortName =
          company.shortName.toLowerCase().contains(queryLower);
      return matchesStockCode || matchesShortName;
    }).toList();

    results.sort((a, b) => a.stockCode.compareTo(b.stockCode));
    return results;
  }
}
