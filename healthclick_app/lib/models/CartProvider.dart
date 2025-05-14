// File: lib/models/CartProvider.dart
import 'package:flutter/foundation.dart';

class CartItem {
  final String id;
  final String name;
  final double price;
  final String image;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    this.quantity = 1,
  });
  
  // Debug method to help diagnose issues
  @override
  String toString() {
    return 'CartItem(id: $id, name: $name, price: $price, image: $image, quantity: $quantity)';
  }
}

class CartProvider with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    // Debug print to help diagnose
    print('Total amount calculated: $total');
    return total;
  }

  void addItem(String productId, String name, double price, String image) {
    // Debug log to verify the values being passed
    print('Adding item to cart: ID=$productId, Name=$name, Price=$price, Image=$image');
    
    // Make sure price is a valid double
    if (price <= 0) {
      print('Warning: Product price is $price, which may be incorrect');
    }

    if (_items.containsKey(productId)) {
      // Aumenta a quantidade se o produto já está no carrinho
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          name: existingCartItem.name,
          price: existingCartItem.price,
          image: existingCartItem.image,
          quantity: existingCartItem.quantity + 1,
        ),
      );
      print('Updated quantity for ${_items[productId]?.name}, new quantity: ${_items[productId]?.quantity}');
    } else {
      // Adiciona novo item
      _items.putIfAbsent(
        productId,
        () => CartItem(
          id: productId,
          name: name,
          price: price,
          image: image,
        ),
      );
      print('Added new item to cart: ${_items[productId]}');
    }
    
    // Print current cart contents for debugging
    print('Cart contents after update:');
    _items.forEach((key, value) {
      print('- $key: ${value.name}, price: ${value.price}, quantity: ${value.quantity}');
    });
    
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) {
      return;
    }
    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          name: existingCartItem.name,
          price: existingCartItem.price,
          image: existingCartItem.image,
          quantity: existingCartItem.quantity - 1,
        ),
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }
}