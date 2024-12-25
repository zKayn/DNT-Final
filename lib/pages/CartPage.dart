import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:shoppingapp/pages/CartItemCard.dart';
import 'package:shoppingapp/providers/cart_provider.dart';
import 'package:shoppingapp/pages/cart_item.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shoppingapp/services/database.dart';
import 'package:shoppingapp/services/shared_pref.dart';
import 'package:shoppingapp/widget/support_widget.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  Map<String, dynamic>? paymentIntent;
  late double totalPrice; // Lưu totalPrice vào biến ngoài context

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Sử dụng context.read() sau khi widget được xây dựng xong
    final cartProvider = context.read<CartProvider>();
    totalPrice = cartProvider.totalPrice; // Đảm bảo lấy giá trị đúng
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xfff2f2f2),
        title: Center(
            child: Text("Giỏ hàng", style: AppWidget.boldTextFeildStyle())),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<CartProvider>(
              builder: (context, cartProvider, child) {
                final cartItems = cartProvider.cartItems;
                return cartItems.isEmpty
                    ? Center(child: Text("Giỏ hàng trống"))
                    : ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final product = cartItems[index];
                          return CartItemCard(product: product);
                        },
                      );
              },
            ),
          ),
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              final currencyFormatter = NumberFormat("#,##0", "vi_VN");
              return Container(
                padding: EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 5.0),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Tổng cộng:", style: TextStyle(fontSize: 18)),
                        Text(
                          "${currencyFormatter.format(cartProvider.totalPrice)}₫", // Sử dụng trực tiếp từ CartProvider
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        _showPaymentMethodDialog(context,
                            cartProvider.totalPrice); // Truyền đúng giá trị
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff04a5e3),
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 8.0),
                      ),
                      child: Text(
                        "Chọn phương thức thanh toán",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> makePayment(BuildContext context, double totalPrice) async {
    try {
      String amount = totalPrice
          .toStringAsFixed(0); // Chuyển đổi giá trị float sang chuỗi số nguyên
      paymentIntent = await createPaymentIntent(
          amount, 'vnd'); // Chuyển tham số đúng định dạng

      if (paymentIntent != null) {
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: paymentIntent!['client_secret'],
            style: ThemeMode.light,
            merchantDisplayName: 'Shopping App',
          ),
        );
        await displayPaymentSheet(context);
      } else {
        throw Exception("Không thể tạo PaymentIntent.");
      }
    } catch (e) {
      print("Lỗi thanh toán: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi thanh toán")),
      );
    }
  }

  Future<void> displayPaymentSheet(BuildContext context) async {
    try {
      // Hiển thị PaymentSheet của Stripe
      await Stripe.instance.presentPaymentSheet().then((value) async {
        if (!mounted) return; // Đảm bảo widget còn hoạt động

        // Sau khi thanh toán thành công
        final cartProvider = context.read<CartProvider>();
        final cartItems = cartProvider.cartItems;

        String? name = await SharedPreferenceHelper().getUserName();
        String? email = await SharedPreferenceHelper().getUserEmail();
        String? image = await SharedPreferenceHelper().getUserImage();

        for (var product in cartItems) {
          // Tạo thông tin đơn hàng
          Map<String, dynamic> orderInfoMap = {
            "Product": product.name,
            "Price": product.price,
            "Name": name,
            "Email": email,
            "Image": image,
            "ProductImage": product.image,
            "Status": "Chờ Lấy Hàng", // Trạng thái đơn hàng
          };

          // Gửi thông tin tới cơ sở dữ liệu
          await DatabaseMethods().orderDetails(orderInfoMap);
        }

        // Xóa giỏ hàng
        cartProvider.clearCart();

        // Hiển thị thông báo thành công
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 10),
                Text("Thanh toán thành công!"),
              ],
            ),
          ),
        );
      }).onError((error, stackTrace) {
        print("Lỗi trong khi thanh toán: $error");
      });
    } catch (e) {
      print("Lỗi thanh toán: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi không xác định khi thanh toán")),
      );
    }
  }

  Future<Map<String, dynamic>?> createPaymentIntent(
      String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount), // Sửa lỗi tại đây
        'currency': currency,
        'payment_method_types[]': 'card',
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization':
              'Bearer sk_test_51QL1oRBTMJPu3L7np5S6tn8Yp4qWa4PXPT6i8I8Ja0RzRZNDrB5dpsXBlmR0iF4ihi3EzL4C5jZGkq8DF06XTRKy00wtOD6opg', // Thay token hợp lệ
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Lỗi Stripe: ${response.body}");
      }
    } catch (e) {
      print('Lỗi khi tạo PaymentIntent: $e');
      return null;
    }
  }

  String calculateAmount(String amount) {
    final parsedAmount = double.parse(amount);
    final totalAmount = parsedAmount.toInt();
    return totalAmount.toString();
  }

  void handleCODPayment(BuildContext context) async {
    // Lưu thông tin đơn hàng vào Firestore
    final cartProvider = context.read<CartProvider>();
    final cartItems = cartProvider.cartItems;

    String? name = await SharedPreferenceHelper().getUserName();
    String? email = await SharedPreferenceHelper().getUserEmail();
    String? image = await SharedPreferenceHelper().getUserImage();

    for (var product in cartItems) {
      Map<String, dynamic> orderInfoMap = {
        "Product": product.name,
        "Price": product.price,
        "Name": name,
        "Email": email,
        "Image": image,
        "ProductImage": product.image,
        "Status": "Chờ Lấy Hàng",
      };
      await DatabaseMethods().orderDetails(orderInfoMap);
    }

    // Xóa giỏ hàng
    cartProvider.clearCart();

    if (!mounted) return;

    // Hiển thị thông báo thành công
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                Text("Vui lòng thanh toán khi nhận hàng.")
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Function để hiển thị các phương thức thanh toán
  void _showPaymentMethodDialog(BuildContext parentContext, double totalPrice) {
    showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Phương thức thanh toán"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.credit_card, color: Colors.blue),
                title: Text("Thanh toán bằng thẻ"),
                onTap: () {
                  Navigator.pop(context); // Đóng hộp thoại
                  makePayment(parentContext,
                      totalPrice); // Truyền context của widget cha
                },
              ),
              ListTile(
                leading: Icon(Icons.money, color: Colors.green),
                title: Text("Thanh toán khi nhận hàng"),
                onTap: () {
                  Navigator.pop(context);
                  handleCODPayment(parentContext);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
