import 'dart:convert';
import 'dart:io';
import '../models/inventory_item.dart';
import "dart:async";

class InventoryService {
  final String filePath = 'data/inventory.json';

  // ✅ Single source of truth
  List<InventoryItem> inventory = [];

  // ✅ Correct getter to expose the list
  List<InventoryItem> get inventoryList => inventory;

  // Load inventory from file
  Future<void> loadInventory() async {
    final file = File(filePath);
    if (await file.exists()) {
      final contents = await file.readAsString();
      final data = json.decode(contents) as List<dynamic>;
      inventory = data
          .map((itemJson) => InventoryItem.fromJson(itemJson))
          .toList();
      print("✅ Inventory loaded. Total items: ${inventory.length}");
    } else {
      print(
        "⚠️ Inventory file not found at '$filePath'. Creating a new one...",
      );
      await saveInventory();
    }
  }

  // Save inventory to file
  Future<void> saveInventory() async {
    final file = File(filePath);
    final data = inventory.map((item) => item.toJson()).toList();
    await file.writeAsString(json.encode(data), flush: true);
    print("💾 Inventory saved to '$filePath'");
  }

  Future<void> addItem(InventoryItem item) async {
  inventory.add(item);
  await saveInventory(); // ✅ Save to file after adding
  print("✅ Item added: ${item.name}");
}


  Future<void> viewInventory() async {
    if (inventory.isEmpty) {
      print("📦 Inventory is empty.");
    } else {
      print("📋 Inventory List:");
      for (var item in inventory) {
        print(item);
      }
    }
  }

  Future<void> removeItem(String name) async {
    inventory.removeWhere(
      (item) => item.name.toLowerCase() == name.toLowerCase(),
    );
    print("❌ Item removed: $name");
  }

  Future<void> updateQuantity(String name, int newQty) async {
    for (var item in inventory) {
      if (item.name.toLowerCase() == name.toLowerCase()) {
        item.quantity = newQty;
        print("🔄 Updated quantity for '$name' to $newQty.");
        return;
      }
    }
    print("❌ Item '$name' not found.");
  }

 Future<void> reduceStock(String itemName, double qtyToReduce) async {
    for (var item in inventory) {
      if (item.name.toLowerCase() == itemName.toLowerCase()) {
        if (item.quantity >= qtyToReduce.round()) {
          item.quantity -= qtyToReduce.round();
          print(
            "✅  Order is placed sucessfully and 📉 Reduced stock for '$itemName' by ${qtyToReduce.round()} units.",
          );
        } else {
          print(
            "⚠️ Not enough stock to reduce for '$itemName'. Available: ${item.quantity}",
          );
        }
        return;
      }
    }
    print("❌ Item '$itemName' not found in inventory.");
  }
}
