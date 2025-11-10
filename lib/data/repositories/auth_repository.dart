import 'dart:async';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthRepository {
  final _controller = StreamController<AuthStatus>();

  Stream<AuthStatus> get status async* {
    await Future<void>.delayed(const Duration(seconds: 1));
    yield AuthStatus.unauthenticated;
    yield* _controller.stream;
  }

  Future<void> logIn({
    required String email,
    required String password,
  }) async {
    // In a real app, you'd make a network request here.
    await Future.delayed(
      const Duration(milliseconds: 300),
      () => _controller.add(AuthStatus.authenticated),
    );
  }

  Future<void> logOut() async {
    // In a real app, you'd clear tokens and notify the server.
    await Future.delayed(
      const Duration(milliseconds: 300),
      () => _controller.add(AuthStatus.unauthenticated),
    );
  }

  void dispose() => _controller.close();
}