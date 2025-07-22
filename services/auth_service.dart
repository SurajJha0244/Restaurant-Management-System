// File: services/auth_service.dart
import 'dart:convert';
import 'dart:io';
import '../models/user.dart';
import 'attendant_service.dart';

class AuthService {
  final String _filePath = 'data/users.json';
  final AttendantService _attendantService;
  List<User> _users = [];

  AuthService(this._attendantService) {
    _loadUsers();
  }

  void _loadUsers() {
    final file = File(_filePath);
    if (file.existsSync()) {
      final data = file.readAsStringSync();
      _users = (json.decode(data) as List).map((e) => User.fromJson(e)).toList();
    } else {
      _users = [
        User(username: 'admin', password: 'admin123', role: 'admin'),
        User(username: 'waiter', password: 'waiter123', role: 'waiter'),
        User(username: 'cashier', password: 'cashier123', role: 'cashier'),
      ];
      _saveUsers();
    }
  }

  void _saveUsers() {
    File(_filePath).writeAsStringSync(json.encode(_users.map((u) => u.toJson()).toList()));
  }

  User? login(String username, String password) {
    try {
      final user = _users.firstWhere((u) => u.username == username && u.password == password);

      // Example: check-in attendant if not admin
      if (user.role != 'admin') {
        _attendantService.checkIn(user);
      }

      return user;
    } catch (e) {
      return null;
    }
  }

  void logout(User user) {
    // Example: mark attendant checkout on logout
    if (user.role != 'admin') {
      _attendantService.checkOut(user);
    }
  }
}
