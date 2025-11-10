import 'package:equatable/equatable.dart';
import 'package:my_shopping_mate/data/repositories/auth_repository.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object> get props => [];
}

class AuthStatusChanged extends AuthenticationEvent {
  const AuthStatusChanged(this.status);

  final AuthStatus status;

  @override
  List<Object> get props => [status];
}

class LogoutRequested extends AuthenticationEvent {}