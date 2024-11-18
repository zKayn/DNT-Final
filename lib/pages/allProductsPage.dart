import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shoppingapp/pages/product_detail.dart';
import '../widget/support_widget.dart';


class Allproductspage extends StatefulWidget {
  const Allproductspage({super.key});

  @override
  State<Allproductspage> createState() => _AllproductspageState();
}

class _AllproductspageState extends State<Allproductspage> {
  Future<List<Map<String, dynamic>>> fetchAllProducts() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection("Products").get();

      return querySnapshot.docs.map((doc) {
        return {
          "Name": doc["Name"],
          "Price": doc["Price"],
          "Image": doc["Image"],
          "Detail": doc["Detail"] ?? "",
        };
      }).toList();
    } catch (e) {
      print("Lỗi khi truy vấn Firestore: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff2f2f2),
      appBar: AppBar(
        backgroundColor: Color(0xfff2f2f2),
        title: Center(
            child: Text(
              "Tất cả sản phẩm",
              style: AppWidget.boldTextFeildStyle(),
            )),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchAllProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Không có sản phẩm nào."));
          }

          List<Map<String, dynamic>> products = snapshot.data!;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Column(
                children: [
                  ProductCard(
                    name: product["Name"],
                    price: product["Price"],
                    image: product["Image"],
                    detail: product["Detail"],
                  ),
                  SizedBox(height: 15.0),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final String name;
  final dynamic price;
  final String image;
  final String detail;

  ProductCard(
      {required this.name,
        required this.price,
        required this.image,
        required this.detail});

  @override
  Widget build(BuildContext context) {
    double parsedPrice = 0.0;

    if (price is String) {
      parsedPrice = double.tryParse(price) ?? 0.0;
    } else if (price is num) {
      parsedPrice = price.toDouble();
    }

    final currencyFormatter = NumberFormat("#,##0", "vi_VN");

    return Container(
      margin: EdgeInsets.only(right: 20.0),
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 10.0),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.network(
                image,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Tên sản phẩm
          SizedBox(height: 10.0),
          Text(
            name,
            style: AppWidget.semiboldTextFeildStyle(),
          ),
          SizedBox(height: 10.0),
          // Giá sản phẩm
          Text(
            "${currencyFormatter.format(parsedPrice)}₫",
            style: TextStyle(
                color: Color(0xff070000),
                fontSize: 20.0,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10.0),
          // Nút "Mua ngay"
          GestureDetector(
            onTap: () {
              print("Mua ngay sản phẩm: $name");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetail(
                    detail: detail,
                    image: image,
                    name: name,
                    price: price.toString(),
                  ),
                ),
              );
            },
            child: Container(
              margin: EdgeInsets.only(top: 10.0, bottom: 8.0),  // Giảm khoảng cách dưới của nút
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Color(0xff04a5e3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "Mua ngay",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
