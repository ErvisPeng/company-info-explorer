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
    final parValueDesc = json['普通股每股面額'] as String? ?? '';
    final websiteRaw = json['網址'] as String? ?? '';

    return CompanyModel(
      stockCode: json['公司代號'] as String? ?? '',
      name: json['公司名稱'] as String? ?? '',
      shortName: json['公司簡稱'] as String? ?? '',
      industryCode: json['產業別'] as String? ?? '',
      chairman: json['董事長'] as String? ?? '',
      generalManager: json['總經理'] as String? ?? '',
      address: json['住址'] as String? ?? '',
      phone: json['總機電話'] as String? ?? '',
      taxId: json['營利事業統一編號'] as String? ?? '',
      foundedDate: json['成立日期'] as String? ?? '',
      listedDate: json['上市日期'] as String? ?? '',
      paidInCapital:
          double.tryParse(json['實收資本額'] as String? ?? '0') ?? 0,
      parValueDesc: parValueDesc,
      parValue: parseParValue(parValueDesc),
      specialShares: int.tryParse(json['特別股'] as String? ?? '0') ?? 0,
      privateShares: int.tryParse(json['私募股數'] as String? ?? '0') ?? 0,
      website: (websiteRaw.isEmpty || websiteRaw == '－') ? null : websiteRaw,
    );
  }
}
