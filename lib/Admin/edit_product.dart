import 'package:flutter/material.dart';
import 'package:shoppingapp/Admin/add_product.dart';
import 'package:shoppingapp/Admin/home_admin.dart';
import 'package:shoppingapp/widget/support_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import thư viện intl

class EditProduct extends StatefulWidget {
  const EditProduct({super.key});

  @override
  State<EditProduct> createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  // Hàm định dạng tiền tệ
  String formatCurrency(dynamic value) {
    try {
      // Chuyển đổi giá trị về kiểu int (nếu cần)
      int price = value is int ? value : int.tryParse(value.toString()) ?? 0;
      return NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(price);
    } catch (e) {
      print("Lỗi định dạng tiền tệ: $e");
      return "0₫"; // Trả về giá trị mặc định nếu xảy ra lỗi
    }
  }

  // Hàm lấy danh sách sản phẩm từ Firebase
  Future<List<Map<String, dynamic>>> fetchAllProducts() async {
    try {
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection("Products").get();
      return querySnapshot.docs.map((doc) {
        return {
          "id": doc.id,
          "name": doc["Name"],
          "price": doc["Price"], // Có thể là String hoặc int
          "image": doc["Image"],
          "detail": doc["Detail"] ?? "",
        };
      }).toList();
    } catch (e) {
      print("Lỗi khi truy vấn Firestore: $e");
      return [];
    }
  }

  // Hàm xóa sản phẩm khỏi Firebase
  Future<void> deleteProduct(String productId) async {
    try {
      await FirebaseFirestore.instance
          .collection("Products")
          .doc(productId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Sản phẩm đã được xóa'),
      ));
      setState(() {}); // Cập nhật lại giao diện sau khi xóa
    } catch (e) {
      print("Lỗi khi xóa sản phẩm: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Lỗi khi xóa sản phẩm'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
            onTap: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => HomeAdmin()));
            },
            child: Icon(Icons.arrow_back_ios_new_outlined)),
        title: Center(
          child: Text(
            "Sửa sản phẩm",
            style: AppWidget.semiboldTextFeildStyle(),
          ),
        ),
      ),
      backgroundColor: Color(0xfff2f2f2),
      body: Container(
        margin: EdgeInsets.only(left: 20.0, right: 20.0),
        child: Column(
          children: [
            SizedBox(height: 30.0),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchAllProducts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError ||
                      !snapshot.hasData ||
                      snapshot.data!.isEmpty) {
                    return Center(child: Text("Không có sản phẩm"));
                  }
                  List<Map<String, dynamic>> products = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 10.0),
                        elevation: 3.0,
                        child: ListTile(
                          leading: Image.network(product["image"],
                              width: 50.0, height: 50.0, fit: BoxFit.cover),
                          title: Text(product["name"]),
                          subtitle: Text(formatCurrency(product["price"])),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: Color(0xff04a5e3),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AddProduct(
                                            productId: product["id"])),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color: Color(0xffd60f46),
                                ),
                                onPressed: () {
                                  deleteProduct(product["id"]);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
