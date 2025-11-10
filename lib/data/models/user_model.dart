import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String publicId;
  final String name;
  final String email;

  const User({required this.publicId, required this.name, required this.email});

  /// Represents an empty, uninitialized user.
  static const empty = User(publicId: '', name: '', email: '');

  @override
  List<Object> get props => [publicId, name, email];

  User copyWith({String? name}) {
    return User(
      publicId: publicId,
      name: name ?? this.name,
      email: email,
    );
  }
}