import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shoppingapp/pages/allProductsPage.dart';
import 'package:shoppingapp/pages/category_products.dart';
import 'package:shoppingapp/pages/product_detail.dart';
import 'package:shoppingapp/services/database.dart';
import 'package:shoppingapp/services/shared_pref.dart';
import 'package:shoppingapp/widget/support_widget.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool search = false;
  String selectedCategory = ''; // Store the selected category
  List categories = [
    "images/headphone_icon.png",
    "images/laptop.png",
    "images/watch.png",
    "images/TV.png"
  ];

  List Categoryname = [
    "Tai nghe",
    "Máy tính",
    "Đồng hồ",
    "Điện thoại",
  ];

  var queryResultSet = [];
  var tempSearchStore = [];
  TextEditingController searchcontroller = TextEditingController();

  initiateSearch(String value) {
    if (value.isEmpty) {
      setState(() {
        queryResultSet = [];
        tempSearchStore = [];
        search = false;
      });
      return;
    }

    setState(() => search = true);

    try {
      String capitalizedValue = value[0].toUpperCase() + value.substring(1);
      if (queryResultSet.isEmpty && value.length == 1) {
        DatabaseMethods().search(value).then((QuerySnapshot docs) {
          setState(() {
            queryResultSet = docs.docs.map((doc) => doc.data()).toList();
          });
        }).catchError((error) {
          print("Lỗi khi truy vấn Firestore: $error");
        });
      } else {
        tempSearchStore = queryResultSet
            .where((element) =>
            element['UpdateName'].toString().startsWith(capitalizedValue))
            .toList();
        setState(() {});
      }
    } catch (error) {
      print("Lỗi tìm kiếm: $error");
    }
  }

  String? name, image;

  getthesharedprefas() async {
    String? fetchedName = await SharedPreferenceHelper().getUserName();
    String? fetchedImage = await SharedPreferenceHelper().getUserImage();

    setState(() {
      name = fetchedName ?? "Người dùng";
      image = fetchedImage ?? ""; // Nếu không có ảnh, để giá trị rỗng.
    });
  }

  @override
  void initState() {
    super.initState();
    getthesharedprefas();
  }

  Future<List<Map<String, dynamic>>> fetchProducts() async {
    try {
      // Modify this to include filtering by category if a category is selected
      QuerySnapshot querySnapshot;
      if (selectedCategory.isEmpty) {
        querySnapshot = await FirebaseFirestore.instance.collection("Products").get();
      } else {
        querySnapshot = await FirebaseFirestore.instance
            .collection("Products")
            .where("Category", isEqualTo: selectedCategory)
            .get();
      }

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
      body: name == null
          ? Center(child: CircularProgressIndicator())
          : Container(
        margin: EdgeInsets.only(top: 30.0, left: 20.0, right: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "Xin chào, $name",
                    style: AppWidget.boldTextFeildStyle(),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: image != null && image!.isNotEmpty
                      ? Image.network(
                    image!,
                    height: 70,
                    width: 70,
                    fit: BoxFit.cover,
                  )
                      : Icon(Icons.account_circle, size: 70),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            // Search bar
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10)),
              child: TextField(
                controller: searchcontroller,
                onChanged: (value) {
                  initiateSearch(value.toUpperCase());
                },
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Tìm kiếm sản phẩm",
                  hintStyle: AppWidget.lightTextFeildStyle(),
                  prefixIcon: search
                      ? GestureDetector(
                      onTap: () {
                        setState(() {
                          search = false;
                          tempSearchStore = [];
                          queryResultSet = [];
                          searchcontroller.text = "";
                        });
                      },
                      child: Icon(Icons.close))
                      : Icon(Icons.search, color: Colors.black),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            search
                ? ListView(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              primary: false,
              shrinkWrap: true,
              children: tempSearchStore.map((element) {
                return buildResultCard(element);
              }).toList(),
            )
                : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Thể loại",
                          style:
                          AppWidget.semiboldTextFeildStyle()),
                    ],
                  ),
                ),
                SizedBox(height: 20.0),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 125,
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: categories.length,
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return CategoryTile(
                              image: categories[index],
                              name: Categoryname[index],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Tất cả sản phẩm", style: AppWidget.semiboldTextFeildStyle()),
                      GestureDetector(
                        onTap: () {
                          // Điều hướng đến màn hình tất cả sản phẩm
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Allproductspage()),
                          );
                        },
                        child: Text(
                          "Xem tất cả",
                          style: TextStyle(
                            color: Color(0xFFfd6f3e),
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 20.0),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: fetchProducts(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text("Không có sản phẩm nào."));
                    }
                    List<Map<String, dynamic>> products = snapshot.data!;
                    return Container(
                      height: 240,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return ProductCard(
                            name: product["Name"],
                            price: product["Price"],
                            image: product["Image"],
                            detail: product["Detail"],
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget buildResultCard(data) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetail(
              detail: data["Detail"] ?? "Không có mô tả",
              image: data["Image"],
              name: data["Name"],
              price: data["Price"] ?? "0",
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.only(left: 20.0),
        margin: EdgeInsets.only(bottom: 10.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        height: 100,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                data["Image"],
                height: 70,
                width: 70,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 20.0),
            Expanded(
              child: Text(
                data["Name"],
                style: AppWidget.semiboldTextFeildStyle(),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryTile extends StatelessWidget {
  String image, name;

  CategoryTile({required this.image, required this.name});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CategoryProducts(category: name)));
      },
      child: Container(
        margin: EdgeInsets.only(right: 10),
        child: Column(
          children: [
            Image.asset(
              image,
              height: 80,
              width: 80,
            ),
            SizedBox(height: 10),
            Text(name),
          ],
        ),
      ),
    );
  }
}


class ProductCard extends StatelessWidget {
  final String name;
  final dynamic price; // Giả sử price có thể là số hoặc chuỗi
  final String image;
  final String detail;

  ProductCard(
      {required this.name,
        required this.price,
        required this.image,
        required this.detail});

  @override
  Widget build(BuildContext context) {
    // Kiểm tra nếu price là chuỗi, chuyển thành số (int hoặc double)
    double parsedPrice = 0.0;

    if (price is String) {
      parsedPrice = double.tryParse(price) ?? 0.0; // Chuyển chuỗi thành số, mặc định là 0 nếu không thể
    } else if (price is num) {
      parsedPrice = price.toDouble(); // Chuyển từ kiểu num (int, double) sang double
    }

    final currencyFormatter = NumberFormat("#,##0", "vi_VN");

    return Container(
      margin: EdgeInsets.only(right: 20.0),
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Tự động điều chỉnh chiều cao
        children: [
          // Hình ảnh sản phẩm
          Image.network(
            image,
            height: 100,
            width: 100,
            fit: BoxFit.cover,
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
            "${currencyFormatter.format(parsedPrice)}₫", // Hiển thị giá sau khi chuyển thành số
            style: TextStyle(
                color: Color(0xff070000),
                fontSize: 20.0,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10.0),
          // Nút "Mua ngay"
          GestureDetector(
            onTap: () {
              // Thực hiện hành động khi nhấn vào "Mua ngay", ví dụ: điều hướng đến trang giỏ hàng hoặc thanh toán
              print("Mua ngay sản phẩm: $name");
              // Ví dụ: điều hướng đến trang chi tiết sản phẩm hoặc thêm vào giỏ hàng
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
              margin: EdgeInsets.only(top: 10.0),
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


