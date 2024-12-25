import 'package:flutter/material.dart';
import 'package:shoppingapp/pages/cart_item.dart'; // Đảm bảo bạn import đúng class CartItem

class CartProvider with ChangeNotifier {
  List<CartItem> _cartItems = [];

  // Lấy giỏ hàng
  List<CartItem> get cartItems => _cartItems;

  // Thêm sản phẩm vào giỏ hàng
  void addToCart(CartItem item) {
    final existingItem = _cartItems.firstWhere(
      (cartItem) => cartItem.name == item.name && cartItem.image == item.image,
      orElse: () => CartItem(name: '', price: 0, quantity: 0, image: ''),
    );

    if (existingItem.name.isNotEmpty) {
      // Nếu đã có sản phẩm, tăng số lượng
      existingItem.quantity += item.quantity;
    } else {
      // Nếu không có sản phẩm trong giỏ, thêm mới
      _cartItems.add(item);
    }
    notifyListeners(); // Thông báo UI cập nhật
  }

  // Xóa sản phẩm khỏi giỏ hàng
  void removeFromCart(String productName) {
    _cartItems.removeWhere((item) => item.name == productName);
    notifyListeners();
  }

  // Tăng số lượng sản phẩm trong giỏ hàng
  void increaseQuantity(CartItem item) {
    final index = _cartItems.indexOf(item);
    if (index != -1) {
      _cartItems[index].quantity++;
      notifyListeners();
    }
  }

  // Giảm số lượng sản phẩm trong giỏ hàng
  void decreaseQuantity(CartItem item) {
    final index = _cartItems.indexOf(item);
    if (index != -1 && _cartItems[index].quantity > 1) {
      _cartItems[index].quantity--;
      notifyListeners();
    }
  }

  // Xóa hết sản phẩm trong giỏ hàng
  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  // Tổng giá của tất cả sản phẩm trong giỏ hàng
  double get totalPrice {
    double total = 0.0;
    for (var item in _cartItems) {
      total += item.price * item.quantity;
    }
    return total;
  }
}
