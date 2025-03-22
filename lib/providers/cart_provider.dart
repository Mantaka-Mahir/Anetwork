import 'package:event_management_app/widget/cart_item.dart';
import 'package:event_management_app/widget/food_item.dart';
import 'package:flutter/foundation.dart';


class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => [..._items];

  double get total => _items.fold(0, (sum, item) => sum + item.total);

  void addItem(FoodItem food) {
    final existingIndex = _items.indexWhere((item) => item.food.id == food.id);
    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(food: food));
    }
    notifyListeners();
  }

  void addToCart(FoodItem food) {
    addItem(food); // This is an alias for addItem for backward compatibility
  }

  void removeItem(String foodId) {
    _items.removeWhere((item) => item.food.id == foodId);
    notifyListeners();
  }

  void updateQuantity(String foodId, int quantity) {
    final item = _items.firstWhere((item) => item.food.id == foodId);
    item.quantity = quantity;
    if (item.quantity <= 0) {
      removeItem(foodId);
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}