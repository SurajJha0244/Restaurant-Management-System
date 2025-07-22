// File: services/attendant_service.dart
import 'dart:convert';
import 'dart:io';
import '../models/attendant.dart';
import '../models/user.dart';

class AttendantService {
  final String _filePath = 'data/attendants.json';
  final String _logPath = 'data/attendant_log.json';
  List<Attendant> attendants = [];

  AttendantService() {
    _loadAttendants();
  }

  void _loadAttendants() {
    final f = File(_filePath);
    if (f.existsSync()) {
      final data = jsonDecode(f.readAsStringSync()) as List;
      attendants = data.map((e) => Attendant.fromJson(e)).toList();
    } else {
      _saveAttendants();
    }
  }

  void _saveAttendants() {
    File(_filePath).writeAsStringSync(json.encode(attendants.map((a) => a.toJson()).toList()));
  }

  void checkIn(User user) {
    final now = DateTime.now();
    final existing = attendants.firstWhere(
        (a) => a.sid == user.username,
        orElse: () => Attendant(sid: user.username, name: user.username, role: user.role, logs: []));

    existing.role = user.role;
    existing.logs.add({'checkIn': now.toIso8601String(), 'checkOut': ''});
    if (!attendants.contains(existing)) attendants.add(existing);
    _saveAttendants();
    print("✅ ${user.username} checked in at $now");
  }

  void checkOut(User user) {
    final now = DateTime.now();
    final att = attendants.firstWhere((a) => a.sid == user.username, orElse: () => Attendant(sid: '', name: '', role: '', logs: []));
    if (att.sid != '') {
      final last = att.logs.last;
      last['checkOut'] = now.toIso8601String();
      _saveAttendants();
      print("👋 ${user.username} checked out at $now");
    }
  }

  void viewAttendants() {
    if (attendants.isEmpty) {
      print("📭 No attendants.");
      return;
    }
    print("🧍 Attendants:");
    for (var a in attendants) {
      print("${a.sid} | ${a.name} | ${a.role}");
      for (var log in a.logs) {
        print("  ⏰ In: ${log['checkIn']} – Out: ${log['checkOut']}");
      }
    }
  }

  void generateAttendanceReport(String role) {
    if (role != 'admin') {
      print("❌ Only admin can generate attendance report.");
      return;
    }

    final f = File(_logPath);
    if (!f.existsSync()) {
      print("📭 No logs found.");
      return;
    }
    final logs = jsonDecode(f.readAsStringSync()) as List;
    final buf = StringBuffer();
    buf.writeln("SID,Name,Role,CheckIn,CheckOut");

    for (var log in logs) {
      buf.writeln("${log['sid']},${log['name']},${log['role']},${log['checkIn']},${log['checkOut']}");
    }

    File("data/attendant_report.csv").writeAsStringSync(buf.toString());
    print("📊 Report generated: data/attendant_report.csv");
  }
}
