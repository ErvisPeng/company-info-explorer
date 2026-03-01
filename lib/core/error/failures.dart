import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = '伺服器錯誤']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = '本地儲存錯誤']);
}
