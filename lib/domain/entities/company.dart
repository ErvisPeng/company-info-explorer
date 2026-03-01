import 'package:equatable/equatable.dart';

class Company extends Equatable {
  final String stockCode;
  final String name;
  final String shortName;
  final String industryCode;
  final String chairman;
  final String generalManager;
  final String address;
  final String phone;
  final String taxId;
  final String foundedDate;
  final String listedDate;
  final double paidInCapital;
  final String parValueDesc;
  final double parValue;
  final int specialShares;
  final int privateShares;
  final String? website;

  const Company({
    required this.stockCode,
    required this.name,
    required this.shortName,
    required this.industryCode,
    required this.chairman,
    required this.generalManager,
    required this.address,
    required this.phone,
    required this.taxId,
    required this.foundedDate,
    required this.listedDate,
    required this.paidInCapital,
    required this.parValueDesc,
    required this.parValue,
    required this.specialShares,
    required this.privateShares,
    this.website,
  });

  @override
  List<Object?> get props => [
    stockCode,
    name,
    shortName,
    industryCode,
    chairman,
    generalManager,
    address,
    phone,
    taxId,
    foundedDate,
    listedDate,
    paidInCapital,
    parValueDesc,
    parValue,
    specialShares,
    privateShares,
    website,
  ];
}
