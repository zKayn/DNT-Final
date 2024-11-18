import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shoppingapp/pages/product_detail.dart';
import 'package:shoppingapp/services/database.dart';
import 'package:shoppingapp/widget/support_widget.dart';
import 'package:intl/intl.dart'; // Import thư viện intl

class CategoryProducts extends StatefulWidget {
  String category;

  CategoryProducts({required this.category});

  @override
  State<CategoryProducts> createState() => _CategoryProductsState();
}

class _CategoryProductsState extends State<CategoryProducts> {
  Stream? CategoryStream;

  getontheload() async {
    CategoryStream = await DatabaseMethods().getProducts(widget.category);
    setState(() {});
  }

  @override
  void initState() {
    getontheload();
    super.initState();
  }

  Widget allProducts() {
    return StreamBuilder(
        stream: CategoryStream,
        builder: (context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? GridView.builder(
                  padding: EdgeInsets.zero,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.6,
                      mainAxisSpacing: 10.0,
                      crossAxisSpacing: 10.0),
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data.docs[index];

                    // Định dạng giá với NumberFormat
                    var price = double.parse(ds["Price"]);
                    var formattedPrice = NumberFormat.currency(
                      locale: 'vi_VN', // Định dạng theo chuẩn Việt Nam
                      symbol: '₫', // Biểu tượng tiền tệ
                    ).format(price);

                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                      decoration: BoxDecoration(
                          color: Colors.white, borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, // Căn trái các thành phần
                        children: [
                          SizedBox(height: 10.0),
                          Center(
                            child: Image.network(
                              ds["Image"],
                              height: 120,
                              width: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            ds["Name"],
                            style: AppWidget.semiboldTextFeildStyle(),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2, // Giới hạn tên sản phẩm hiển thị 2 dòng
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            formattedPrice, // Giá đã được định dạng
                            style: TextStyle(
                              color: Color(0xff070000),
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.visible, // Cho phép giá xuống dòng
                            softWrap: true,
                          ),
                          Spacer(), // Đẩy nút "Thêm sản phẩm" xuống cuối
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetail(
                                      detail: ds["Detail"],
                                      image: ds["Image"],
                                      name: ds["Name"],
                                      price: ds["Price"],
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                width: double.infinity, // Nút chiếm toàn bộ chiều ngang
                                padding: EdgeInsets.all(4), // Khoảng cách trong nút
                                decoration: BoxDecoration(
                                  color: Color(0xff04a5e3),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    "Mua ngay",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  })
              : Container();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff2f2f2),
      appBar: AppBar(
        backgroundColor: Color(0xfff2f2f2),
      ),
      body: Container(
        margin: EdgeInsets.only(left: 20.0, right: 20.0),
        child: Column(
          children: [
            Expanded(child: allProducts()),
          ],
        ),
      ),
    );
  }
}
