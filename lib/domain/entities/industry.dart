import 'package:equatable/equatable.dart';

class Industry extends Equatable {
  final String code;
  final String name;
  final int companyCount;

  const Industry({
    required this.code,
    required this.name,
    required this.companyCount,
  });

  @override
  List<Object> get props => [code, name, companyCount];
}
