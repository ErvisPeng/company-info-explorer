import 'package:company_info_explorer/core/constants/industry_codes.dart';
import 'package:company_info_explorer/domain/entities/company.dart';
import 'package:company_info_explorer/domain/entities/industry.dart';

class GetIndustriesUseCase {
  List<Industry> call(List<Company> companies) {
    final grouped = <String, int>{};
    for (final company in companies) {
      if (!industryCodeToName.containsKey(company.industryCode)) continue;
      grouped[company.industryCode] =
          (grouped[company.industryCode] ?? 0) + 1;
    }

    final industries = <Industry>[];
    for (final code in industryCodeOrder) {
      if (grouped.containsKey(code)) {
        industries.add(Industry(
          code: code,
          name: industryCodeToName[code]!,
          companyCount: grouped[code]!,
        ));
      }
    }
    return industries;
  }
}
