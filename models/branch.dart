// File: models/branch.dart
import 'inventory_item.dart';
class Branch {
  final String name;
  final String location;
  final List<InventoryItem> inventory;

  Branch({
    required this.name,
    required this.location,
    required this.inventory,
  });

  factory Branch.fromJson(Map<String, dynamic> json) => Branch(
        name: json['name'],
        location: json['location'],
        inventory: (json['inventory'] as List)
            .map((item) => InventoryItem.fromJson(item))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'location': location,
        'inventory': inventory.map((item) => item.toJson()).toList(),
      };
}