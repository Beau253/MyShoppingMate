import 'dart:async';
import 'package:my_shopping_mate/data/services/api_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthRepository {
  final _controller = StreamController<AuthStatus>();
  final ApiService _apiService;

  AuthRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  Stream<AuthStatus> get status async* {
    yield AuthStatus.unauthenticated;
    yield* _controller.stream;
  }

  Future<void> logIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post('/auth/login', body: {
        'email': email,
        'password': password,
      });

      if (response != null && response['token'] != null) {
        _apiService.setToken(response['token']);
        _controller.add(AuthStatus.authenticated);
      } else {
        throw Exception('Login failed: No token received');
      }
    } catch (e) {
      print('Login error: $e');
      _controller.add(AuthStatus.unauthenticated);
      rethrow;
    }
  }

  Future<void> logOut() async {
    _apiService.clearToken();
    _controller.add(AuthStatus.unauthenticated);
  }

  void dispose() => _controller.close();
}