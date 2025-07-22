// File: services/branch_service.dart
import 'dart:convert';
import 'dart:io';// for firstWhereOrNull
import '../models/branch.dart';
import '../models/inventory_item.dart';

class BranchService {
  final String _filePath = 'data/branches.json';
  List<Branch> _branches = [];

  BranchService() {
    _loadBranches();
  }

  void _loadBranches() {
    final file = File(_filePath);
    if (file.existsSync()) {
      final data = file.readAsStringSync();
      _branches = (json.decode(data) as List)
          .map((item) => Branch.fromJson(item))
          .toList();
    } else {
      _branches = [
        Branch(name: 'Dang', location: 'Dang', inventory: []),
        Branch(name: 'Chitwan', location: 'Chitwan', inventory: []),
        Branch(name: 'Ilam', location: 'Ilam', inventory: []),
        Branch(name: 'Pokhara', location: 'Pokhara', inventory: []),
      ];
      _saveBranches();
    }
  }

  void _saveBranches() {
    File(_filePath).writeAsStringSync(json.encode(_branches));
  }

  List<Branch> getBranches() => List.from(_branches);

 void transferItem({
  required String itemName,
  required int quantity,
  required String fromBranchName,
  required String toBranchName,
}) {
  try {
    final fromBranch = _branches.firstWhere((b) => b.name == fromBranchName);
    final toBranch = _branches.firstWhere((b) => b.name == toBranchName);

    final fromItem = fromBranch.inventory.firstWhere(
      (item) => item.name == itemName,
      orElse: () => InventoryItem(name: '', price: 0, quantity: 0),
    );

    if (fromItem.name.isEmpty) {
      throw Exception('Item not found in $fromBranchName');
    }

    if (fromItem.quantity < quantity) {
      throw Exception('Not enough quantity in $fromBranchName');
    }

    // Update source branch
    fromItem.quantity -= quantity;
    if (fromItem.quantity <= 0) {
      fromBranch.inventory.removeWhere((item) => item.name == itemName);
    }

    // Update destination branch
    final toItemIndex = toBranch.inventory.indexWhere((item) => item.name == itemName);
    if (toItemIndex != -1) {
      toBranch.inventory[toItemIndex].quantity += quantity;
    } else {
      toBranch.inventory.add(InventoryItem(
        name: itemName,
        price: fromItem.price,
        quantity: quantity,
        unit: fromItem.unit,
      ));
    }

    _saveBranches();
  } catch (e) {
    throw Exception('Transfer failed: ${e.toString()}');
  }
}


  void addItemToBranch(String branchName, InventoryItem item) {
    final branch = _branches.firstWhere((b) => b.name == branchName);
    final existingItemIndex = branch.inventory.indexWhere((i) => i.name == item.name);
    
    if (existingItemIndex != -1) {
      branch.inventory[existingItemIndex].quantity += item.quantity;
    } else {
      branch.inventory.add(item);
    }
    
    _saveBranches();
  }
}