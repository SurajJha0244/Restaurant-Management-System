// File: services/order_service.dart
import '../models/order.dart';
import 'menu_service.dart';
import 'inventory_service.dart';
import '../models/inventory_item.dart';

class OrderService {
  final MenuService menuService;
  final InventoryService inventoryService;
  List<Order> orderList = [];

  OrderService(this.menuService, this.inventoryService);

  bool checkInventory(String itemName, int qty) {
    final invItem = inventoryService.inventory.firstWhere(
      (i) => i.name.toLowerCase() == itemName.toLowerCase(),
      orElse: () => InventoryItem(name: '', price: 0, quantity: 0),
    );
    return invItem.name.isNotEmpty && invItem.quantity >= qty;
  }

  Future<void> placeOrder(Order order) async {
    for (var it in order.items) {
      inventoryService.reduceStock(it.itemName, it.quantity.toDouble());
    }
    inventoryService.saveInventory();
    orderList.add(order);
    print("📝 Order placed for Table ${order.tableNumber}");
  }

  Future<void> showOrders() async {
    print("\n📦 Orders:");
    for (var o in orderList) {
      print("Table ${o.tableNumber}:");
      for (var i in o.items) {
        print(
          "- ${i.itemName} x${i.quantity} = ₹${i.total.toStringAsFixed(2)}",
        );
      }
      print(
        "Subtotal: ₹${o.subtotal.toStringAsFixed(2)}, GST: ₹${o.gst.toStringAsFixed(2)}, Total: ₹${o.total.toStringAsFixed(2)}",
      );
      print("---------------------------------");
    }
  }

  List<Order> getOrders() => orderList;
}
