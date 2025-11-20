import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_shopping_mate/data/services/api_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthRepository {
  final _controller = StreamController<AuthStatus>();
  final ApiService _apiService;
  final FlutterSecureStorage _storage;

  AuthRepository({ApiService? apiService, FlutterSecureStorage? storage})
      : _apiService = apiService ?? ApiService(),
        _storage = storage ?? const FlutterSecureStorage();

  Stream<AuthStatus> get status async* {
    // Check for persisted token on startup
    final token = await _storage.read(key: 'auth_token');
    if (token != null) {
      _apiService.setToken(token);
      yield AuthStatus.authenticated;
    } else {
      yield AuthStatus.unauthenticated;
    }
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
        final token = response['token'];
        await _storage.write(key: 'auth_token', value: token);
        _apiService.setToken(token);
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

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _apiService.post('/auth/register', body: {
        'email': email,
        'password': password,
        'name': name,
      });

      if (response != null && response['token'] != null) {
        final token = response['token'];
        await _storage.write(key: 'auth_token', value: token);
        _apiService.setToken(token);
        _controller.add(AuthStatus.authenticated);
      } else {
        throw Exception('Sign up failed: No token received');
      }
    } catch (e) {
      print('Sign up error: $e');
      _controller.add(AuthStatus.unauthenticated);
      rethrow;
    }
  }

  Future<void> logOut() async {
    await _storage.delete(key: 'auth_token');
    _apiService.clearToken();
    _controller.add(AuthStatus.unauthenticated);
  }

  void dispose() => _controller.close();
}
