import 'package:equatable/equatable.dart';
import 'package:my_shopping_mate/data/models/user_model.dart';
import 'package:my_shopping_mate/data/repositories/auth_repository.dart';

export 'package:my_shopping_mate/data/repositories/auth_repository.dart' show AuthStatus;

class AuthenticationState extends Equatable {
  const AuthenticationState._({
    this.status = AuthStatus.unknown,
    this.user = User.empty,
  });

  const AuthenticationState.unknown() : this._();

  const AuthenticationState.authenticated(User user)
      : this._(status: AuthStatus.authenticated, user: user);

  const AuthenticationState.unauthenticated()
      : this._(status: AuthStatus.unauthenticated);

  final AuthStatus status;
  final User user;

  @override
  List<Object> get props => [status, user];
}