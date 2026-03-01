import 'package:company_info_explorer/domain/entities/company.dart';

class GetCompaniesByIndustryUseCase {
  List<Company> call(List<Company> companies, String industryCode) {
    return companies
        .where((c) => c.industryCode == industryCode)
        .toList()
      ..sort((a, b) => a.stockCode.compareTo(b.stockCode));
  }
}
