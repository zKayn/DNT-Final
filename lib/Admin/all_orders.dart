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
  Stream? orderStream;

  getontheload() async {
  orderStream = await DatabaseMethods().allOrders();
  // Debug: Kiểm tra xem `orderStream` có dữ liệu không
  orderStream!.listen((event) {
    print("Số lượng đơn hàng: ${event.docs.length}");
  });
  setState(() {});
}


  @override
  void initState() {
    getontheload();
    super.initState();
  }

  // Hàm định dạng giá tiền
  String formatPrice(int price) {
    final formatter = NumberFormat('#,###', 'vi_VN');  // Định dạng tiền tệ theo VND
    return formatter.format(price);
  }

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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.network(
                            ds["ProductImage"],
                            height: 120,
                            width: 120,
                            fit: BoxFit.cover,
                          ),
                          Spacer(),
                          Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Tên: " + ds["Name"],
                                  style: AppWidget.semiboldTextFeildStyle(),
                                ),
                                SizedBox(
                                  height: 3.0,
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width / 2,
                                  child: Text(
                                    "Email: " + ds["Email"],
                                    style: AppWidget.lightTextFeildStyle(),
                                  ),
                                ),
                                SizedBox(
                                  height: 3.0,
                                ),
                                Text(
                                  ds["Product"],
                                  style: AppWidget.semiboldTextFeildStyle(),
                                ),
                                // Định dạng giá hiển thị theo VND
                                Text(
                                  "₫" + formatPrice(int.parse(ds["Price"])),
                                  style: TextStyle(
                                      color: Color(0xff070000),
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: 20.0,
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    await DatabaseMethods()
                                        .updateStatus(ds.id);
                                    setState(() {});
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 5.0),
                                    width: 150,
                                    decoration: BoxDecoration(
                                        color: Color(0xff04a5e3),
                                        borderRadius: BorderRadius.circular(10)),
                                    child: Center(
                                        child: Text(
                                          "Xác nhận",
                                          style: AppWidget.semiboldTextFeildStyle(),
                                        )),
                                  ),
                                )
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
        });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
            onTap: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomeAdmin()));
            },
            child: Icon(Icons.arrow_back_ios_new_outlined)),
        title: Center(
          child: Text(
            "Tất cả đơn hàng",
            style: AppWidget.boldTextFeildStyle(),
          ),
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(right: 20.0, left: 20.0),
        child: Column(
          children: [Expanded(child: allOrders())],
        ),
      ),
    );
  }
}
