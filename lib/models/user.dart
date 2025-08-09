// File: lib/models/user.dart
class User {
  final String username;
  final String email;
  final String token;

  User({required this.username, required this.email, required this.token});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['user']['user_name'] ?? '',
      email: json['user']['user_email'] ?? '',
      token: json['token'] ?? '',
    );
  }
}
