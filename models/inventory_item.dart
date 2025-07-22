// File: models/inventory_item.dart
class InventoryItem {
  String name;
  double price;
  int quantity;
  String unit;

  InventoryItem({
    required this.name,
    required this.price,
    required this.quantity,
    this.unit = 'units',
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) => InventoryItem(
        name: json['name'],
        price: (json['price'] as num).toDouble(),
        quantity: json['quantity'],
        unit: json['unit'] ?? 'units',
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'price': price,
        'quantity': quantity,
        'unit': unit,
      };

  @override
  String toString() {
    return '$name: $quantity $unit (\$$price per unit)';
  }
}