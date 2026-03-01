import 'package:company_info_explorer/core/utils/html_entity_decoder.dart';
import 'package:company_info_explorer/core/utils/par_value_parser.dart';
import 'package:company_info_explorer/domain/entities/company.dart';

class CompanyModel extends Company {
  const CompanyModel({
    required super.stockCode,
    required super.name,
    required super.shortName,
    required super.industryCode,
    required super.chairman,
    required super.generalManager,
    required super.address,
    required super.phone,
    required super.taxId,
    required super.foundedDate,
    required super.listedDate,
    required super.paidInCapital,
    required super.parValueDesc,
    required super.parValue,
    required super.specialShares,
    required super.privateShares,
    super.website,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    String field(String key) =>
        decodeHtmlEntities(json[key] as String? ?? '');

    final parValueDesc = field('普通股每股面額');
    final websiteRaw = field('網址');

    return CompanyModel(
      stockCode: field('公司代號'),
      name: field('公司名稱'),
      shortName: field('公司簡稱'),
      industryCode: field('產業別'),
      chairman: field('董事長'),
      generalManager: field('總經理'),
      address: field('住址'),
      phone: field('總機電話'),
      taxId: field('營利事業統一編號'),
      foundedDate: field('成立日期'),
      listedDate: field('上市日期'),
      paidInCapital:
          double.tryParse(field('實收資本額')) ?? 0,
      parValueDesc: parValueDesc,
      parValue: parseParValue(parValueDesc),
      specialShares: int.tryParse(field('特別股')) ?? 0,
      privateShares: int.tryParse(field('私募股數')) ?? 0,
      website: (websiteRaw.isEmpty || websiteRaw == '－') ? null : websiteRaw,
    );
  }
}
