import 'package:equatable/equatable.dart';

abstract class CompanyDetailState extends Equatable {
  const CompanyDetailState();
  @override
  List<Object> get props => [];
}

class CompanyDetailInitial extends CompanyDetailState {}

class CompanyDetailLoaded extends CompanyDetailState {
  final bool isWatched;
  const CompanyDetailLoaded({required this.isWatched});
  @override
  List<Object> get props => [isWatched];
}
