// File: models/user.dart
class User {
  final String username;
  final String password;
  final String role; // 'admin', 'waiter', 'cashier'

  User({
    required this.username,
    required this.password,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        username: json['username'],
        password: json['password'],
        role: json['role'],
      );

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
        'role': role,
      };
}