import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shoppingapp/Admin/home_admin.dart';
import 'package:shoppingapp/services/database.dart';
import 'package:shoppingapp/widget/support_widget.dart';
import 'package:intl/intl.dart';

class RevenuePage extends StatefulWidget {
  const RevenuePage({super.key});

  @override
  State<RevenuePage> createState() => _RevenuePageState();
}

class _RevenuePageState extends State<RevenuePage> {
  double totalRevenue = 0;
  Map<String, double> categoryRevenue = {};
  bool isCategoryView = false;

  // Hàm lấy dữ liệu doanh thu tổng và doanh thu theo danh mục
  getRevenueData() async {
    try {
      if (isCategoryView) {
        categoryRevenue = await DatabaseMethods().getRevenueByCategory();
      } else {
        // Truy vấn các đơn hàng có trạng thái 'Đã Giao Hàng' để tính doanh thu tổng
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('Orders')
            .where('Status', isEqualTo: 'Đã Giao Hàng')
            .get();

        double revenue = 0;

        // Tính tổng doanh thu
        snapshot.docs.forEach((doc) {
          revenue += (doc['Price'] ?? 0).toDouble();
        });

        setState(() {
          totalRevenue = revenue; // Cập nhật lại tổng doanh thu
        });
      }
    } catch (e) {
      print("Lỗi khi lấy dữ liệu doanh thu: $e");
    }
  }

  // Hàm định dạng giá tiền
  String formatPrice(double price) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '₫' + formatter.format(price);
  }

  @override
  void initState() {
    super.initState();
    getRevenueData(); // Lấy doanh thu khi trang được load
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => HomeAdmin()));
          },
          child: Icon(Icons.arrow_back_ios_new_outlined),
        ),
        title: Center(
          child: Text(
            "Doanh Thu",
            style: AppWidget.boldTextFeildStyle(),
          ),
        ),
      ),
      body: Container(
        margin: EdgeInsets.all(20),
        child: Column(
          children: [
            // Tiêu đề doanh thu
            Text(
              "Tổng Doanh Thu",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Hiển thị tổng doanh thu hoặc doanh thu theo từng danh mục
            isCategoryView
                ? Expanded(
                    child: ListView.builder(
                      itemCount: categoryRevenue.length,
                      itemBuilder: (context, index) {
                        String category = categoryRevenue.keys.elementAt(index);
                        double revenue = categoryRevenue[category] ?? 0;

                        return ListTile(
                          title: Text(category),
                          trailing: Text(formatPrice(revenue)),
                        );
                      },
                    ),
                  )
                : Text(
                    formatPrice(totalRevenue),
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
            SizedBox(height: 30),

            // Nút chuyển giữa các chế độ: xem tổng doanh thu và doanh thu theo danh mục
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isCategoryView = false;
                    });
                    getRevenueData();
                  },
                  child: Text("Tổng Doanh Thu"),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isCategoryView = true;
                    });
                    getRevenueData();
                  },
                  child: Text("Doanh Thu Theo Danh Mục"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
