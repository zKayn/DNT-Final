import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:shoppingapp/pages/cart_item.dart';
import 'package:shoppingapp/services/constant.dart';
import 'package:shoppingapp/services/database.dart';
import 'package:shoppingapp/services/shared_pref.dart';
import 'package:shoppingapp/widget/support_widget.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shoppingapp/providers/cart_provider.dart';
import 'package:provider/provider.dart';

class ProductDetail extends StatefulWidget {
  String image, name, detail, price;

  ProductDetail(
      {required this.detail,
      required this.image,
      required this.name,
      required this.price});

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  String? name, mail, image;

  getthesharedpref() async {
    name = await SharedPreferenceHelper().getUserName();
    mail = await SharedPreferenceHelper().getUserEmail();
    image = await SharedPreferenceHelper().getUserImage();
    setState(() {});
  }

  ontheload() async {
    await getthesharedpref();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    ontheload();
  }

  Map<String, dynamic>? paymentIntent;

  void confirmCashOnDelivery() async {
    Map<String, dynamic> orderInfoMap = {
      "Product": widget.name,
      "Price": widget.price,
      "Name": name,
      "Email": mail,
      "Image": image,
      "ProductImage": widget.image,
      "Status": "Chờ lấy hàng"
    };
    await DatabaseMethods().orderDetails(orderInfoMap);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text("Đặt hàng thành công"),
              ],
            ),
            SizedBox(height: 16),
            Text("Bạn đã chọn thanh toán khi nhận hàng."),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFfef5f1),
      appBar: AppBar(
        backgroundColor: Color(0xFFfef5f1),
        title: Center(
          child: Text(
            "Chi tiết sản phẩm",
            style: AppWidget.boldTextFeildStyle(),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Quay lại màn hình trước
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          // Bọc toàn bộ nội dung trong SingleChildScrollView
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ảnh sản phẩm
              Stack(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: AspectRatio(
                          aspectRatio: 1.3,
                          child: Image.network(
                            widget.image,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Chi tiết sản phẩm
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tên sản phẩm
                    Text(
                      widget.name,
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 10.0),

                    // Giá sản phẩm
                    Text(
                      "₫${formatPrice(int.parse(widget.price))}",
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff070000),
                      ),
                    ),
                    SizedBox(height: 20.0),

                    // Chi tiết
                    Text(
                      "Chi tiết",
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 10.0),

                    // Nội dung chi tiết
                    Text(
                      widget.detail,
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black54,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 20.0),

                    // Nút thêm vào giỏ hàng
                    GestureDetector(
                      onTap: () {
                        CartProvider cartProvider =
                            context.read<CartProvider>();

                        CartItem item = CartItem(
                          name: widget.name,
                          image: widget.image,
                          price: double.parse(widget.price),
                          quantity: 1,
                        );

                        cartProvider.addToCart(item);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                '${widget.name} đã được thêm vào giỏ hàng'),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 15.0),
                        decoration: BoxDecoration(
                          color: Color(0xff04a5e3),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8.0,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            "Thêm vào giỏ hàng",
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Định dạng giá tiền
  String formatPrice(int price) {
    final formatter = NumberFormat('#,###', 'vi_VN'); // Định dạng theo kiểu VND
    return formatter.format(price);
  }

  Future<void> makePayment(String amount) async {
    try {
      paymentIntent = await createPaymentIntent(amount, 'VND');
      if (paymentIntent != null) {
        await Stripe.instance
            .initPaymentSheet(
                paymentSheetParameters: SetupPaymentSheetParameters(
                    paymentIntentClientSecret: paymentIntent?['client_secret'],
                    style: ThemeMode.dark,
                    merchantDisplayName: 'Adnan'))
            .then((value) {
          displayPaymentSheet();
        });
      } else {
        throw Exception("Payment Intent is null");
      }
    } catch (e, s) {
      print('exception:$e$s');
    }
  }

  displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) async {
        Map<String, dynamic> orderInfoMap = {
          "Product": widget.name,
          "Price": widget.price,
          "Name": name,
          "Email": mail,
          "Image": image,
          "ProductImage": widget.image,
          "Status": "Chờ lấy hàng"
        };
        await DatabaseMethods().orderDetails(orderInfoMap);
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                    content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                        Text("Thanh toán thành công")
                      ],
                    )
                  ],
                )));
        paymentIntent = null;
      }).onError((error, stackTrace) {
        print("Error is :---> $error $stackTrace");
      });
    } on StripeException catch (e) {
      print("Error is :---> $e");
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                content: Text("Đã hủy"),
              ));
    } catch (e) {
      print('$e');
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card'
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization':
              'Bearer sk_test_51QL1oRBTMJPu3L7np5S6tn8Yp4qWa4PXPT6i8I8Ja0RzRZNDrB5dpsXBlmR0iF4ihi3EzL4C5jZGkq8DF06XTRKy00wtOD6opg',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Thanh toán không thành công. Phản hồi: ${response.body}");
        throw Exception("Thanh toán không thành công");
      }
    } catch (err) {
      print('Thanh toán không thành công: ${err.toString()}');
      return null;
    }
  }

  calculateAmount(String amount) {
    final calculateAmount = (int.parse(amount));
    return calculateAmount.toString();
  }
}
