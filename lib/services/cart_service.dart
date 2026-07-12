import 'package:flutter/material.dart';
import 'local_db_service.dart';

class CartService {
  static final CartService instance = CartService._internal();
  CartService._internal();

  final ValueNotifier<List<Map<String, dynamic>>> selectedMCUs = ValueNotifier([]);
  final ValueNotifier<List<Map<String, dynamic>>> selectedSensors = ValueNotifier([]);

  Future<void> loadCart() async {
    final mcuCache = await LocalDatabaseService.instance.getCachedData('cart_mcus', maxAge: const Duration(days: 30));
    final sensorCache = await LocalDatabaseService.instance.getCachedData('cart_sensors', maxAge: const Duration(days: 30));
    
    if (mcuCache != null) {
      selectedMCUs.value = List<Map<String, dynamic>>.from(mcuCache);
    }
    if (sensorCache != null) {
      selectedSensors.value = List<Map<String, dynamic>>.from(sensorCache);
    }
  }

  Future<void> _saveCart() async {
    await LocalDatabaseService.instance.saveToCache('cart_mcus', selectedMCUs.value);
    await LocalDatabaseService.instance.saveToCache('cart_sensors', selectedSensors.value);
  }

  void addComponent(Map<String, dynamic> item) {
    final isMCU = item['category'] == 'Mikrokontroler';
    final targetList = isMCU ? selectedMCUs : selectedSensors;
    final list = List<Map<String, dynamic>>.from(targetList.value);
    final index = list.indexWhere((e) => e['item']['name'] == item['name']);
    
    if (index >= 0) {
      list[index]['qty'] += 1;
    } else {
      list.add({'item': item, 'qty': 1});
    }
    targetList.value = list;
    _saveCart();
  }

  void updateQty(Map<String, dynamic> item, int delta, bool isMCU) {
    final targetList = isMCU ? selectedMCUs : selectedSensors;
    final list = List<Map<String, dynamic>>.from(targetList.value);
    final index = list.indexWhere((e) => e['item']['name'] == item['name']);
    
    if (index >= 0) {
      list[index]['qty'] += delta;
      if (list[index]['qty'] <= 0) {
        list.removeAt(index);
      }
      targetList.value = list;
      _saveCart();
    }
  }

  void clearCart() {
    selectedMCUs.value = [];
    selectedSensors.value = [];
    _saveCart();
  }
}