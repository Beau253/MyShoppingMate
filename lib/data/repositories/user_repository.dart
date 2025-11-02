import 'package:my_shopping_mate/data/models/user_model.dart';

/// The abstract interface for the user repository.
abstract class UserRepository {
  Future<User> getUser();
  Future<void> updateUser({required String name});
}

/// The placeholder implementation of the repository.
/// This simulates network calls and can be easily swapped with a real
/// HttpUserRepository without changing any other code.
class FakeUserRepository implements UserRepository {
  // Our placeholder user data.
  User _user = const User(
    publicId: 'uuid-1234-abcd-5678',
    name: 'John Doe',
    email: 'you@example.com',
  );

  @override
  Future<User> getUser() async {
    // Simulate network latency
    await Future.delayed(const Duration(milliseconds: 500));
    return _user;
  }

  @override
  Future<void> updateUser({required String name}) async {
    // Simulate network latency
    await Future.delayed(const Duration(seconds: 1));
    _user = _user.copyWith(name: name);
  }
}