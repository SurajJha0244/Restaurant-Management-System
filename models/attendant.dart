//file: models/attendant.dart
class Attendant {
  String sid;
  String name;
  String role;
  List<Map<String, String>> logs;

  Attendant({
    required this.sid,
    required this.name,
    this.role = '',
    required this.logs,
  });

  factory Attendant.fromJson(Map<String, dynamic> json) => Attendant(
        sid: json['sid'],
        name: json['name'],
        role: json['role'] ?? '',
        logs: List<Map<String, String>>.from(json['logs'].map((e) => Map<String, String>.from(e))),
      );

  Map<String, dynamic> toJson() => {
        'sid': sid,
        'name': name,
        'role': role,
        'logs': logs,
      };
}
