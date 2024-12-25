import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  // Thêm thông tin người dùng
  Future<void> addUserDetails(Map<String, dynamic> userInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("Users")
        .doc(id)
        .set(userInfoMap);
  }

  // Thêm sản phẩm vào collection "Products"
  Future<DocumentReference<Map<String, dynamic>>> addAllProducts(Map<String, dynamic> productsInfoMap) async {
    return await FirebaseFirestore.instance.collection("Products").add(productsInfoMap);
  }

  // Thêm sản phẩm vào danh mục cụ thể
  Future<DocumentReference<Map<String, dynamic>>> addProduct(Map<String, dynamic> productInfoMap, String categoryName) async {
    return await FirebaseFirestore.instance.collection(categoryName).add(productInfoMap);
  }

  // Cập nhật thông tin sản phẩm
  Future<void> updateProduct(String productId, Map<String, dynamic> updatedData) async {
    try {
      await FirebaseFirestore.instance
          .collection("Products")
          .doc(productId)
          .update(updatedData);
    } catch (e) {
      print("Error updating product: $e");
    }
  }

  // Lấy danh sách sản phẩm từ một danh mục
  Stream<QuerySnapshot> getProducts(String category) {
    return FirebaseFirestore.instance.collection(category).snapshots();
  }

  // Lấy đơn hàng của người dùng theo email
  Stream<QuerySnapshot> getOrders(String email) {
    return FirebaseFirestore.instance
        .collection("Orders")
        .where("Email", isEqualTo: email)
        .snapshots();
  }

  // Chi tiết đơn hàng
  Future<DocumentReference<Map<String, dynamic>>> orderDetails(Map<String, dynamic> orderInfoMap) async {
    return await FirebaseFirestore.instance.collection("Orders").add(orderInfoMap);
  }

  // Tìm kiếm sản phẩm
  Future<QuerySnapshot> search(String updateName) async {
    return await FirebaseFirestore.instance
        .collection("Products")
        .where("SearchKey", isEqualTo: updateName.substring(0, 1).toUpperCase())
        .get();
  }

  // Cập nhật trạng thái đơn hàng
  Future<void> updateStatus(String orderId, String status) async {
    try {
      await FirebaseFirestore.instance.collection('Orders').doc(orderId).update({
        'Status': status,
      });
    } catch (e) {
      print("Lỗi khi cập nhật trạng thái: $e");
    }
  }

  // Lấy tất cả các đơn hàng
  Stream<QuerySnapshot> allOrders() {
    return FirebaseFirestore.instance.collection('Orders').snapshots();
  }

  // Tính doanh thu theo danh mục
  Future<Map<String, double>> getRevenueByCategory() async {
    Map<String, double> categoryRevenue = {};

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("Orders")
          .where("Status", isEqualTo: "Đã Giao Hàng")
          .get();

      for (var doc in snapshot.docs) {
        double price = (doc['Price'] ?? 0).toDouble();
        String categoryId = doc['Product'] ?? 'Không có danh mục';

        if (categoryRevenue.containsKey(categoryId)) {
          categoryRevenue[categoryId] = categoryRevenue[categoryId]! + price;
        } else {
          categoryRevenue[categoryId] = price;
        }
      }
    } catch (e) {
      print("Lỗi khi tính doanh thu theo danh mục: $e");
    }

    return categoryRevenue;
  }
}
