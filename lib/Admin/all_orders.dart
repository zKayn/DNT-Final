import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shoppingapp/Admin/home_admin.dart';
import 'package:shoppingapp/services/database.dart';
import 'package:shoppingapp/widget/support_widget.dart';
import 'package:intl/intl.dart';

class AllOrders extends StatefulWidget {
  const AllOrders({super.key});

  @override
  State<AllOrders> createState() => _AllOrdersState();
}

class _AllOrdersState extends State<AllOrders> {
  Stream<QuerySnapshot>? orderStream;

  // Hàm tải danh sách đơn hàng
  getontheload() async {
    orderStream = DatabaseMethods().allOrders();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getontheload();
  }

  // Hàm định dạng giá tiền
  String formatPrice(dynamic price) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    if (price is double) {
      return formatter.format(price);
    } else if (price is int) {
      return formatter.format(price);
    } else {
      return '0';
    }
  }

  // Hàm cập nhật trạng thái đơn hàng
  void updateOrderStatus(String orderId, String status) async {
    try {
      await DatabaseMethods().updateStatus(orderId, status);
      setState(() {});
    } catch (e) {
      print("Lỗi khi cập nhật trạng thái: $e");
    }
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
            "Tất cả đơn hàng",
            style: AppWidget.boldTextFeildStyle(),
          ),
        ),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.0),
        child: StreamBuilder(
          stream: orderStream,
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            // Lấy số lượng đơn hàng
            int orderCount = snapshot.data!.docs.length;

            return Column(
              children: [
                // Hiển thị số lượng đơn hàng
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Text(
                    "Số lượng đơn hàng: $orderCount",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                // Hiển thị danh sách các đơn hàng
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: orderCount,
                    itemBuilder: (context, index) {
                      DocumentSnapshot ds = snapshot.data!.docs[index];

                      return Container(
                        margin: EdgeInsets.only(bottom: 20.0),
                        child: Material(
                          elevation: 5.0,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 12.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Hình ảnh sản phẩm
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    ds["ProductImage"],
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(width: 20),
                                // Thông tin sản phẩm
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 10.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Tên: " + ds["Name"],
                                          style: AppWidget.semiboldTextFeildStyle(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 3.0),
                                        Text(
                                          "Email: " + ds["Email"],
                                          style: AppWidget.lightTextFeildStyle(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 3.0),
                                        Text(
                                          ds["Product"],
                                          style: AppWidget.semiboldTextFeildStyle(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 6.0),
                                        Text(
                                          "₫" + formatPrice(ds["Price"]),
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 22.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 15.0),
                                        // Trạng thái
                                        Text(
                                          "Trạng thái: " + ds["Status"],
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 8.0),
                                        // Nút cuộn thay đổi trạng thái
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            children: [
                                              // Nút thay đổi trạng thái
                                              Padding(
                                                padding:
                                                    const EdgeInsets.only(
                                                        right: 8.0),
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    updateOrderStatus(
                                                        ds.id, "Chờ Lấy Hàng");
                                                  },
                                                  child: Text("Chờ Lấy Hàng"),
                                                  style: ElevatedButton.styleFrom(
                                                    padding: EdgeInsets.symmetric(horizontal: 12),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.only(
                                                        right: 8.0),
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    updateOrderStatus(
                                                        ds.id, "Chờ Giao Hàng");
                                                  },
                                                  child: Text("Chờ Giao Hàng"),
                                                  style: ElevatedButton.styleFrom(
                                                    padding: EdgeInsets.symmetric(horizontal: 12),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.only(
                                                        right: 8.0),
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    updateOrderStatus(
                                                        ds.id, "Đã Giao Hàng");
                                                  },
                                                  child: Text("Đã Giao Hàng"),
                                                  style: ElevatedButton.styleFrom(
                                                    padding: EdgeInsets.symmetric(horizontal: 12),
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
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
