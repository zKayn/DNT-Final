import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  Future addUserDetails(Map<String, dynamic> userInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("Users")
        .doc(id)
        .set(userInfoMap);
  }

  Future addAllProducts(Map<String, dynamic> productsInfoMap) async {
    return await FirebaseFirestore.instance
        .collection("Products")
        .add(productsInfoMap);
  }

  Future addProduct(
      Map<String, dynamic> productInfoMap, String categoryname) async {
    return await FirebaseFirestore.instance
        .collection(categoryname)
        .add(productInfoMap);
  }

  updateStatus(String id) async {
    return await FirebaseFirestore.instance
        .collection("Orders")
        .doc(id)
        .update({"Status": "Đã giao hàng"});
  }

  Future<void> updateProduct(String productId, Map<String, dynamic> updatedData) async {
    try {
      await FirebaseFirestore.instance.collection("Products").doc(productId).update(updatedData);
    } catch (e) {
      print("Error updating product: $e");
    }
  }

  Future<Stream<QuerySnapshot>> getProducts(String categoty) async {
    return await FirebaseFirestore.instance.collection(categoty).snapshots();
  }

  Future<Stream<QuerySnapshot>> getOrders(String email) async {
    return await FirebaseFirestore.instance
        .collection("Orders")
        .where("Email", isEqualTo: email)
        .snapshots();
  }

//   Future<Stream<QuerySnapshot>> allOrders() async {
//   return FirebaseFirestore.instance.collection("Orders").snapshots(); // Lấy tất cả đơn hàng
// }


  Future<Stream<QuerySnapshot>> allOrders() async {
    return await FirebaseFirestore.instance
        .collection("Orders")
        .where("Status", isEqualTo: "Chờ xác nhận")
        .snapshots();
  }

  Future orderDetails(Map<String, dynamic> orderInfoMap) async {
    return await FirebaseFirestore.instance
        .collection("Orders")
        .add(orderInfoMap);
  }

  Future<QuerySnapshot> search(String updatename) async {
    return await FirebaseFirestore.instance
        .collection("Products")
        .where("SearchKey",
            isEqualTo: updatename.substring(0, 1).toUpperCase())
        .get();
  }
}
