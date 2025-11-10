import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_shopping_mate/bloc/auth/auth_event.dart';
import 'package:my_shopping_mate/bloc/auth/auth_state.dart';
import 'package:my_shopping_mate/data/models/user_model.dart';
import 'package:my_shopping_mate/data/repositories/auth_repository.dart';

class AuthBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  final AuthRepository _authRepository;
  late StreamSubscription<AuthStatus> _authStatusSubscription;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthenticationState.unknown()) {
    on<AuthStatusChanged>(_onAuthStatusChanged);
    on<LogoutRequested>(_onLogoutRequested);

    _authStatusSubscription = _authRepository.status.listen(
      (status) => add(AuthStatusChanged(status)),
    );
  }

  void _onAuthStatusChanged(
    AuthStatusChanged event,
    Emitter<AuthenticationState> emit,
  ) {
    switch (event.status) {
      case AuthStatus.unauthenticated:
        return emit(const AuthenticationState.unauthenticated());
      case AuthStatus.authenticated:
        // In a real app, you'd fetch the user from the repository.
        const user = User(publicId: 'fake-id', name: 'John Doe', email: 'john@doe.com');
        return emit(const AuthenticationState.authenticated(user));
      case AuthStatus.unknown:
        return emit(const AuthenticationState.unknown());
    }
  }

  void _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthenticationState> emit,
  ) {
    _authRepository.logOut();
  }

  @override
  Future<void> close() {
    _authStatusSubscription.cancel();
    _authRepository.dispose();
    return super.close();
  }
}