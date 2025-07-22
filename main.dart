// RESTAURANT_SYSTEM/main.dart

import 'dart:io';
import 'models/menu_item.dart';
import 'models/order.dart';
import 'models/inventory_item.dart';
import 'models/user.dart'; // Added this for User type
import 'services/menu_service.dart';
import 'services/table_service.dart';
import 'services/order_service.dart';
import 'services/billing_service.dart';
import 'services/report_service.dart';
import 'services/inventory_service.dart';
import 'services/auth_service.dart';
import 'services/branch_service.dart';
import 'services/attendant_service.dart';

void showBanner() {
  final banner = '''
  ███████╗██╗     ██╗ ██████╗ ██╗  ██╗████████╗    ██████╗ ██╗███████╗████████╗
  ██╔════╝██║     ██║██╔════╝ ██║  ██║╚══██╔══╝    ██╔══██╗██║██╔════╝╚══██╔══╝
  █████╗  ██║     ██║██║  ███╗███████║   ██║       ██║  ██║██║█████╗     ██║   
  ██╔══╝  ██║     ██║██║   ██║██╔══██║   ██║       ██║  ██║██║██╔══╝     ██║   
  ███████╗███████╗██║╚██████╔╝██║  ██║   ██║       ██████╔╝██║███████╗   ██║   
  ╚══════╝╚══════╝╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝       ╚═════╝ ╚═╝╚══════╝   ╚═╝   
  ''';

  for (var i = 0; i < banner.length; i++) {
    stdout.write(banner[i]);
    sleep(const Duration(milliseconds: 0));
  }
  sleep(const Duration(milliseconds: 0));
}

Future<void> main() async {
  while (true) {
    showBanner();

    Directory('data/invoices').createSync(recursive: true);
    File('data/menu.json').createSync(recursive: true);
    File('data/tables.json').createSync(recursive: true);
    File('data/inventory.json').createSync(recursive: true);
    File('data/users.json').createSync(recursive: true);
    File('data/branches.json').createSync(recursive: true);

    final menuService = MenuService();
    final tableService = TableService();
    final inventoryService = InventoryService();
    final orderService = OrderService(menuService, inventoryService);
    final billingService = BillingService();
    final reportService = ReportService();
    final attendantService = AttendantService();
    final authService = AuthService(attendantService);
    final branchService = BranchService();

    // Awaiting async functions
    await menuService.loadMenu();
    await tableService.loadTables();
    await inventoryService.loadInventory();

    bool shouldExit = false;
    while (!shouldExit) {
      print("\n🔐 Restaurant Management System Login");
      print("Enter 'exit' at any time to quit the system");
      stdout.write("Username: ");
      final username = stdin.readLineSync()?.trim() ?? '';

      if (username.toLowerCase() == 'exit') {
        exit(0);
      }

      stdout.write("Password: ");
      final password = stdin.readLineSync()?.trim() ?? '';

      if (password.toLowerCase() == 'exit') {
        exit(0);
      }

      final user = authService.login(username, password);
      if (user == null) {
        print("❌ Invalid username or password");
        continue;
      }

      print("\n👋 Welcome, ${user.username.toUpperCase()}!");

      attendantService.checkIn(user);

      switch (user.role) {
        case 'admin':
          shouldExit = adminMenu(
            menuService,
            reportService,
            inventoryService,
            branchService,
            attendantService,
            user,
          );
          break;
        case 'waiter':
          shouldExit = waiterMenu(
            menuService,
            tableService,
            orderService,
            inventoryService,
          );
          break;
        case 'cashier':
          shouldExit = cashierMenu(orderService, billingService);
          break;
        default:
          print("❌ Unauthorized access");
      }

      attendantService.checkOut(user);
    }

    if (shouldExit) {
      print("\n👋 Thank you for using the Restaurant Management System!");
      break;
    }
  }
}

// ================= Admin Menu =================
bool adminMenu(
  MenuService menu,
  ReportService report,
  InventoryService inventory,
  BranchService branchService,
  AttendantService attendantService,
  User user,
) {
  while (true) {
    print("\n🛠 ADMIN MENU:");
    print("1. Menu Management");
    print("2. Inventory Management");
    print("3. Sales Reports");
    print("4. Branch Management");
    print("5. Attendant Report");
    print("0. Logout & Exit System");

    stdout.write("Choice: ");
    final choice = stdin.readLineSync()?.trim() ?? '';

    if (choice.toLowerCase() == 'exit') {
      return true;
    }

    switch (choice) {
      case '1':
        if (menuManagementMenu(menu)) return true;
        break;
      case '2':
        if (inventoryManagementMenu(inventory)) return true;
        break;
      case '3':
        report.generateReport();
        break;
      case '4':
        if (branchManagementMenu(branchService)) return true;
        break;
      case '5':
        attendantService.generateAttendanceReport(user.username);
        break;
      case '0':
        return true;
      default:
        print("❌ Invalid choice");
    }
  }
}

bool menuManagementMenu(MenuService menu) {
  while (true) {
    print("\n🍽 MENU MANAGEMENT:");
    print("1. Add Menu Item");
    print("2. View Menu");
    print("3. Delete Menu Item");
    print("0. Back");

    stdout.write("Choice: ");
    final choice = stdin.readLineSync()?.trim() ?? '';

    if (choice.toLowerCase() == 'exit') {
      return true;
    }

    switch (choice) {
      case '1':
        stdout.write("Item Name: ");
        final name = stdin.readLineSync()?.trim() ?? '';
        if (name.toLowerCase() == 'exit') return true;

        stdout.write("Price: ");
        final priceInput = stdin.readLineSync()?.trim() ?? '';
        if (priceInput.toLowerCase() == 'exit') return true;
        final price = double.tryParse(priceInput) ?? 0.0;

        stdout.write("Category: ");
        final category = stdin.readLineSync()?.trim() ?? '';
        if (category.toLowerCase() == 'exit') return true;

        stdout.write("Available (yes/no): ");
        final availableInput = stdin.readLineSync()?.trim() ?? '';
        if (availableInput.toLowerCase() == 'exit') return true;
        final available = availableInput.toLowerCase() == 'yes';

        menu.addMenuItem(
          MenuItem(
            name: name,
            price: price,
            category: category,
            isAvailable: available,
          ),
        );
        menu.saveMenu();
        break;

      case '2':
        menu.viewMenu();
        break;

      case '3':
        stdout.write("Enter item name to delete: ");
        final name = stdin.readLineSync()?.trim() ?? '';
        if (name.toLowerCase() == 'exit') return true;
        menu.deleteMenuItem(name);
        menu.saveMenu();
        break;

      case '0':
        return false;

      default:
        print("❌ Invalid choice");
    }
  }
}

bool inventoryManagementMenu(InventoryService inventory) {
  while (true) {
    print("\n📦 INVENTORY MANAGEMENT:");
    print("1. View Inventory");
    print("2. Add Inventory Item");
    print("3. Update Inventory Item");
    print("0. Back");

    stdout.write("Choice: ");
    final choice = stdin.readLineSync()?.trim() ?? '';

    if (choice.toLowerCase() == 'exit') {
      return true;
    }

    switch (choice) {
      case '1':
        inventory.viewInventory();
        break;
      case '2':
        stdout.write("Item Name: ");
        final name = stdin.readLineSync()?.trim() ?? '';
        if (name.toLowerCase() == 'exit') return true;

        stdout.write("Price: ");
        final priceInput = stdin.readLineSync()?.trim() ?? '';
        if (priceInput.toLowerCase() == 'exit') return true;
        final price = double.tryParse(priceInput) ?? 0.0;

        stdout.write("Quantity: ");
        final quantityInput = stdin.readLineSync()?.trim() ?? '';
        if (quantityInput.toLowerCase() == 'exit') return true;
        final quantity = int.tryParse(quantityInput) ?? 0;

        stdout.write("Unit: ");
        final unit = stdin.readLineSync()?.trim() ?? 'units';
        if (unit.toLowerCase() == 'exit') return true;

        inventory.addItem(
          InventoryItem(
            name: name,
            price: price,
            quantity: quantity,
            unit: unit,
          ),
        );
        inventory.saveInventory();
        break;
      case '3':
        stdout.write("Item Name: ");
        final name = stdin.readLineSync()?.trim() ?? '';
        if (name.toLowerCase() == 'exit') return true;

        stdout.write("New Quantity: ");
        final quantityInput = stdin.readLineSync()?.trim() ?? '';
        if (quantityInput.toLowerCase() == 'exit') return true;
        final quantity = int.tryParse(quantityInput) ?? 0;

        inventory.updateQuantity(name, quantity);
        inventory.saveInventory();
        break;
      case '0':
        return false;
      default:
        print("❌ Invalid choice");
    }
  }
}

// ================= Branch Management =================
bool branchManagementMenu(BranchService branchService) {
  while (true) {
    print("\n🏢 BRANCH MANAGEMENT:");
    print("1. View All Branches");
    print("2. Transfer Items Between Branches");
    print("0. Back");

    stdout.write("Choice: ");
    final choice = stdin.readLineSync()?.trim() ?? '';

    if (choice.toLowerCase() == 'exit') {
      return true;
    }

    switch (choice) {
      case '1':
        viewAllBranches(branchService);
        break;
      case '2':
        if (transferItemsMenu(branchService)) return true;
        break;
      case '0':
        return false;
      default:
        print("❌ Invalid choice");
    }
  }
}

void viewAllBranches(BranchService branchService) {
  final branches = branchService.getBranches();
  print("\n🌿 AVAILABLE BRANCHES:");
  for (var branch in branches) {
    print("\n${branch.name.toUpperCase()} (${branch.location})");
    if (branch.inventory.isEmpty) {
      print("  No inventory items");
    } else {
      print("  INVENTORY:");
      for (var item in branch.inventory) {
        print("  - ${item.name}: ${item.quantity} ${item.unit}");
      }
    }
  }
}

bool transferItemsMenu(BranchService branchService) {
  final branches = branchService.getBranches();

  print("\n🔄 ITEM TRANSFER");
  print("\nAvailable Branches:");
  for (var i = 0; i < branches.length; i++) {
    print("${i + 1}. ${branches[i].name}");
  }

  stdout.write("\nSelect source branch (number): ");
  final fromInput = stdin.readLineSync()?.trim() ?? '';
  if (fromInput.toLowerCase() == 'exit') return true;
  final fromIndex = int.tryParse(fromInput) ?? 0;
  if (fromIndex < 1 || fromIndex > branches.length) {
    print("❌ Invalid branch selection");
    return false;
  }
  final fromBranch = branches[fromIndex - 1];

  stdout.write("Select destination branch (number): ");
  final toInput = stdin.readLineSync()?.trim() ?? '';
  if (toInput.toLowerCase() == 'exit') return true;
  final toIndex = int.tryParse(toInput) ?? 0;
  if (toIndex < 1 || toIndex > branches.length) {
    print("❌ Invalid branch selection");
    return false;
  }
  final toBranch = branches[toIndex - 1];

  print("\nAvailable Items in ${fromBranch.name}:");
  if (fromBranch.inventory.isEmpty) {
    print("No items available for transfer");
    return false;
  }

  for (var i = 0; i < fromBranch.inventory.length; i++) {
    final item = fromBranch.inventory[i];
    print("${i + 1}. ${item.name} (${item.quantity} ${item.unit})");
  }

  stdout.write("\nSelect item to transfer (number): ");
  final itemInput = stdin.readLineSync()?.trim() ?? '';
  if (itemInput.toLowerCase() == 'exit') return true;
  final itemIndex = int.tryParse(itemInput) ?? 0;
  if (itemIndex < 1 || itemIndex > fromBranch.inventory.length) {
    print("❌ Invalid item selection");
    return false;
  }
  final selectedItem = fromBranch.inventory[itemIndex - 1];

  stdout.write("Enter quantity to transfer (max ${selectedItem.quantity}): ");
  final quantityInput = stdin.readLineSync()?.trim() ?? '';
  if (quantityInput.toLowerCase() == 'exit') return true;
  final quantity = int.tryParse(quantityInput) ?? 0;
  if (quantity <= 0 || quantity > selectedItem.quantity) {
    print("❌ Invalid quantity");
    return false;
  }

  print("\nTRANSFER SUMMARY:");
  print("From: ${fromBranch.name}");
  print("To: ${toBranch.name}");
  print("Item: ${selectedItem.name}");
  print("Quantity: $quantity");
  stdout.write("\nConfirm transfer? (yes/no): ");
  final confirm = stdin.readLineSync()?.trim().toLowerCase() == 'yes';

  if (confirm) {
    try {
      branchService.transferItem(
        itemName: selectedItem.name,
        quantity: quantity,
        fromBranchName: fromBranch.name,
        toBranchName: toBranch.name,
      );
      print("✅ Transfer completed successfully!");
    } catch (e) {
      print("❌ Error: ${e.toString()}");
    }
  } else {
    print("🚫 Transfer canceled");
  }

  return false;
}

// ================= Waiter Menu =================
bool waiterMenu(
  MenuService menu,
  TableService table,
  OrderService orderService,
  InventoryService inventory,
) {
  while (true) {
    print("\n🧑‍🍳 WAITER MENU:");
    print("1. View Menu");
    print("2. View Tables");
    print("3. Book Table");
    print("4. Free Table");
    print("5. Take Order");
    print("0. Logout & Exit System");

    stdout.write("Choice: ");
    final choice = stdin.readLineSync()?.trim() ?? '';

    if (choice.toLowerCase() == 'exit') {
      return true;
    }

    switch (choice) {
      case '1':
        menu.viewMenu();
        break;

      case '2':
        table.showTableStatus();
        break;

      case '3':
        stdout.write("Enter table number to book: ");
        final numInput = stdin.readLineSync()?.trim() ?? '';
        if (numInput.toLowerCase() == 'exit') return true;
        final num = int.tryParse(numInput) ?? 0;
        table.bookTable(num);
        break;

      case '4':
        stdout.write("Enter table number to free: ");
        final numInput = stdin.readLineSync()?.trim() ?? '';
        if (numInput.toLowerCase() == 'exit') return true;
        final num = int.tryParse(numInput) ?? 0;
        table.freeTable(num);
        break;

      case '5':
        if (takeOrder(menu, table, orderService, inventory)) return true;
        break;

      case '0':
        return true;

      default:
        print("❌ Invalid choice");
    }
  }
}

// ================= Cashier Menu =================
bool cashierMenu(OrderService orderService, BillingService billingService) {
  while (true) {
    print("\n💰 CASHIER MENU:");
    print("1. View Orders");
    print("2. Generate Bill");
    print("0. Logout & Exit System");

    stdout.write("Choice: ");
    final choice = stdin.readLineSync()?.trim() ?? '';

    if (choice.toLowerCase() == 'exit') {
      return true;
    }

    switch (choice) {
      case '1':
        orderService.showOrders();
        break;

      case '2':
        stdout.write("Enter table number to bill: ");
        final tableInput = stdin.readLineSync()?.trim() ?? '';
        if (tableInput.toLowerCase() == 'exit') return true;
        final tableNo = int.tryParse(tableInput) ?? 0;
        final order = orderService.getOrders().firstWhere(
          (o) => o.tableNumber == tableNo,
          orElse: () => Order(tableNumber: 0, items: []),
        );

        if (order.items.isEmpty) {
          print("❌ No order found for table $tableNo");
        } else {
          billingService.generateBill(order);
        }
        break;

      case '0':
        return true;

      default:
        print("❌ Invalid choice");
    }
  }
}

// ================= Take Order =================
bool takeOrder(
  MenuService menu,
  TableService table,
  OrderService orderService,
  InventoryService inventory,
) {
  stdout.write("Enter table number: ");
  final tableInput = stdin.readLineSync()?.trim() ?? '';
  if (tableInput.toLowerCase() == 'exit') return true;
  final tableNo = int.tryParse(tableInput) ?? 0;

  final tableIsBooked = table.tables.any(
    (t) => t.tableNumber == tableNo && t.isOccupied,
  );
  if (!tableIsBooked) {
    print("⚠️ Table not booked. Please book first.");
    return false;
  }

  final items = <OrderItem>[];

  while (true) {
    menu.viewMenu();
    stdout.write("Enter item name (or 'done'): ");
    final itemName = stdin.readLineSync()?.trim() ?? '';
    if (itemName.toLowerCase() == 'exit') return true;
    if (itemName.toLowerCase() == 'done') break;

    final item = menu.menuList.firstWhere(
      (i) => i.name.toLowerCase() == itemName.toLowerCase() && i.isAvailable,
      orElse: () =>
          MenuItem(name: '', price: 0, category: '', isAvailable: false),
    );
    if (item.name.isEmpty) {
      print("❌ Item not found or unavailable.");
      continue;
    }

    stdout.write("Quantity: ");
    final qtyInput = stdin.readLineSync()?.trim() ?? '';
    if (qtyInput.toLowerCase() == 'exit') return true;
    final qty = int.tryParse(qtyInput) ?? 0;
    if (qty <= 0) {
      print("❌ Quantity must be positive");
      continue;
    }

    // Fix: use inventory.items not inventoryList
    final inventoryItem = inventory.inventoryList.firstWhere(
      (invItem) => invItem.name.toLowerCase() == item.name.toLowerCase(),
      orElse: () => InventoryItem(name: '', price: 0, quantity: 0, unit: ''),
    );

    if (inventoryItem.name.isEmpty || inventoryItem.quantity < qty) {
      print(
        "❌ Not enough inventory for ${item.name}. Available: ${inventoryItem.quantity}",
      );
      continue;
    }

    items.add(OrderItem(itemName: item.name, quantity: qty, price: item.price));
    inventory.reduceStock(item.name, qty.toDouble());
    inventory.saveInventory(); // ✅ Add this line here
  }

  if (items.isNotEmpty) {
    final order = Order(tableNumber: tableNo, items: items);
    orderService.placeOrder(order);
    print("✅ Order placed for Table $tableNo");
  } else {
    print("❌ No items in order");
  }

  return false;
}
