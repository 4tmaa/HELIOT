import 'package:flutter/material.dart';

class CartService {
  static final CartService instance = CartService._internal();
  CartService._internal();

  final ValueNotifier<List<Map<String, dynamic>>> selectedMCUs = ValueNotifier([]);
  final ValueNotifier<List<Map<String, dynamic>>> selectedSensors = ValueNotifier([]);

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
    }
  }

  void clearCart() {
    selectedMCUs.value = [];
    selectedSensors.value = [];
  }
}