import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoppingapp/pages/cart_item.dart';
import 'package:shoppingapp/providers/cart_provider.dart';
import 'package:intl/intl.dart';

class CartItemCard extends StatelessWidget {
  final CartItem product;

  CartItemCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat("#,##0", "vi_VN");
    
    // Tính giá của sản phẩm sau khi thay đổi số lượng
    double totalPrice = product.price * product.quantity;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            Image.network(
              product.image,
              height: 60,
              width: 60,
              fit: BoxFit.cover,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name),
                  SizedBox(height: 5),
                  Text("${currencyFormatter.format(totalPrice)}₫"),
                  SizedBox(height: 5),
                  Text("Số lượng: ${product.quantity}"),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.remove),
              onPressed: () {
                context.read<CartProvider>().decreaseQuantity(product);
              },
            ),
            Text("${product.quantity}"),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                context.read<CartProvider>().increaseQuantity(product);
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                context.read<CartProvider>().removeFromCart(product.name);
              },
            ),
          ],
        ),
      ),
    );
  }
}
