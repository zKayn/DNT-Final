import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shoppingapp/services/database.dart';
import 'package:shoppingapp/widget/support_widget.dart';
import 'package:intl/intl.dart';
import '../services/shared_pref.dart';

class Order extends StatefulWidget {
  const Order({super.key});

  @override
  State<Order> createState() => _OrderState();
}

class _OrderState extends State<Order> {
  String? email;

  getthesharedprefas() async {
    email = await SharedPreferenceHelper().getUserEmail();
    setState(() {});
  }

  Stream? orderStream;

  getontheload() async {
    await getthesharedprefas();
    orderStream = await DatabaseMethods().getOrders(email!);
    setState(() {});
  }

  @override
  void initState() {
    getontheload();
    super.initState();
  }

  // Hàm định dạng giá tiền
  String formatPrice(int price) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return formatter.format(price);
  }

  // Hàm để lấy màu sắc của trạng thái
  Color getStatusColor(String status) {
    switch (status) {
      case "Chờ Lấy Hàng":
        return Colors.amber;  // Màu vàng cho "Chờ Lấy Hàng"
      case "Chờ Giao Hàng":
        return Colors.blue;  // Màu xanh dương cho "Chờ Giao Hàng"
      case "Đã Giao Hàng":
        return Colors.green; // Màu xanh lá cho "Đã Giao Hàng"
      default:
        return Colors.grey;  // Màu xám cho các trạng thái khác
    }
  }

  // Widget hiển thị tất cả đơn hàng
  Widget allOrders() {
    return StreamBuilder(
      stream: orderStream,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];

                  // Kiểm tra kiểu dữ liệu của Price
                  var price = ds["Price"];
                  double priceValue = 0.0;

                  // Kiểm tra kiểu dữ liệu của price (có thể là double hoặc String)
                  if (price is double) {
                    priceValue = price; // Nếu Price là double, gán trực tiếp
                  } else if (price is String) {
                    // Nếu Price là String, cố gắng chuyển đổi
                    priceValue = double.tryParse(price) ?? 0.0; // Dùng tryParse để tránh lỗi
                  }

                  return Container(
                    margin: EdgeInsets.only(bottom: 20.0),
                    child: Material(
                      elevation: 3.0,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: EdgeInsets.only(
                            left: 20.0, top: 10.0, bottom: 10.0),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Image.network(
                              ds["ProductImage"],
                              height: 120,
                              width: 120,
                              fit: BoxFit.cover,
                            ),
                            SizedBox(width: 10), 
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ds["Product"],
                                    style: AppWidget.semiboldTextFeildStyle(),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  Text(
                                    "₫" +
                                        formatPrice(priceValue
                                            .toInt()), // Giá trị Price được định dạng và chuyển thành String
                                    style: TextStyle(
                                        color: Color(0xff070000),
                                        fontSize: 22.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  // Hiển thị trạng thái với màu sắc
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 5.0, horizontal: 12.0),
                                    decoration: BoxDecoration(
                                      color: getStatusColor(ds["Status"]),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      ds["Status"], // Trạng thái đơn hàng
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
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
                })
            : Container();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff2f2f2),
      appBar: AppBar(
        backgroundColor: Color(0xfff2f2f2),
        title: Center(
            child: Text(
          "Đơn hàng",
          style: AppWidget.boldTextFeildStyle(),
        )),
      ),
      body: Container(
        margin: EdgeInsets.only(left: 20.0, right: 20.0),
        child: Column(
          children: [Expanded(child: allOrders())],
        ),
      ),
    );
  }
}
