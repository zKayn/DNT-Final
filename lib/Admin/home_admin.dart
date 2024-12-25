import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shoppingapp/Admin/RevenuePage.dart';
import 'package:shoppingapp/Admin/add_product.dart';
import 'package:shoppingapp/Admin/admin_login.dart';
import 'package:shoppingapp/Admin/all_orders.dart';
import 'package:shoppingapp/Admin/edit_product.dart';
import 'package:shoppingapp/services/database.dart';
import 'package:shoppingapp/widget/support_widget.dart';

class HomeAdmin extends StatefulWidget {
  const HomeAdmin({super.key});

  @override
  State<HomeAdmin> createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  final DatabaseMethods _databaseMethods =
      DatabaseMethods(); // Khởi tạo DatabaseMethods

  int totalProductCount = 0;

  // Các chỉ số để hiển thị biểu đồ tròn cho sản phẩm
  int outOfStockCount = 2; 
  int limitedStockCount = 3; 
  int otherProductCount = 5;

  // Thêm các chỉ số cho biểu đồ thống kê đơn hàng
  int waitingPickupCount = 0;
  int waitingDeliveryCount = 0; 
  int deliveredCount = 0; 

  @override
  void initState() {
    super.initState();
    // Lấy tổng số sản phẩm 
    _getProductCount();
    // Lấy số liệu thống kê các đơn hàng 
    _getOrderStats();
  }

  // Hàm lấy tổng số sản phẩm
  Future<void> _getProductCount() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection("Products").get();
      setState(() {
        totalProductCount = snapshot.docs.length;
      });
    } catch (e) {
      print("Lỗi khi lấy số lượng sản phẩm: $e");
    }
  }

  // Hàm lấy số liệu thống kê đơn hàng
  Future<void> _getOrderStats() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('Orders').get();

      int waitPickup = 0;
      int waitDelivery = 0;
      int delivered = 0;

      for (var doc in snapshot.docs) {
        var order = doc.data() as Map<String, dynamic>;
        // Kiểm tra trạng thái đơn hàng
        if (order['Status'] == 'Chờ Lấy Hàng') {
          waitPickup++;
        } else if (order['Status'] == 'Chờ Giao Hàng') {
          waitDelivery++;
        } else if (order['Status'] == 'Đã Giao Hàng') {
          delivered++;
        }
      }

      setState(() {
        waitingPickupCount = waitPickup;
        waitingDeliveryCount = waitDelivery;
        deliveredCount = delivered;
      });
    } catch (e) {
      print("Lỗi khi lấy thống kê đơn hàng: $e");
    }
  }

  // Hàm tạo các phần của biểu đồ tròn cho trạng thái đơn hàng
  List<PieChartSectionData> _buildOrderChartSections() {
    int totalOrders =
        waitingPickupCount + waitingDeliveryCount + deliveredCount;

    double waitingPickupPercent =
        (totalOrders > 0) ? (waitingPickupCount / totalOrders) * 100 : 0;
    double waitingDeliveryPercent =
        (totalOrders > 0) ? (waitingDeliveryCount / totalOrders) * 100 : 0;
    double deliveredPercent =
        (totalOrders > 0) ? (deliveredCount / totalOrders) * 100 : 0;

    return [
      PieChartSectionData(
        color: Colors.orange,
        value: waitingPickupCount.toDouble(),
        title:
            '${waitingPickupPercent.toStringAsFixed(1)}%', 
        radius: 40,
        titleStyle: TextStyle(
            fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        color: Colors.blue,
        value: waitingDeliveryCount.toDouble(),
        title:
            '${waitingDeliveryPercent.toStringAsFixed(1)}%', 
        radius: 40,
        titleStyle: TextStyle(
            fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        color: Colors.green,
        value: deliveredCount.toDouble(),
        title:
            '${deliveredPercent.toStringAsFixed(1)}%',
        radius: 40,
        titleStyle: TextStyle(
            fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ];
  }

  // Hàm tạo các phần của biểu đồ tròn cho sản phẩm
  List<PieChartSectionData> _buildProductChartSections() {
    return [
      PieChartSectionData(
        color: Colors.red,
        value: outOfStockCount.toDouble(),
        title: '$outOfStockCount sản phẩm',
        radius: 40,
        titleStyle: TextStyle(
            fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        color: Colors.orange,
        value: limitedStockCount.toDouble(),
        title: '$limitedStockCount sản phẩm',
        radius: 40,
        titleStyle: TextStyle(
            fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        color: Colors.green,
        value: otherProductCount.toDouble(),
        title: '$otherProductCount sản phẩm',
        radius: 40,
        titleStyle: TextStyle(
            fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A2D3E),
      drawer: Drawer(
        child: Container(
          color: const Color(0xFF1E1F28),
          child: ListView(
            children: [
              DrawerHeader(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey,
                      child: Text('Phi'),
                    ),
                    const SizedBox(height: 10),
                    const Text('Quản trị viên',
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                  ],
                ),
                decoration: const BoxDecoration(color: Color(0xFF2A2D3E)),
              ),
              ListTile(
                leading: const Icon(Icons.dashboard, color: Colors.white),
                title: const Text('Bảng điều khiển',
                    style: TextStyle(color: Colors.white)),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.shopping_bag, color: Colors.white),
                title: const Text('Tất cả đơn hàng',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AllOrders()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.add, color: Colors.white),
                title: const Text('Thêm sản phẩm',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddProduct()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.white),
                title: const Text('Sửa sản phẩm',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const EditProduct()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.bar_chart, color: Colors.white),
                title: const Text('Doanh thu',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RevenuePage()));
                },
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2D3E),
        title: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Tìm kiếm',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            const CircleAvatar(
              backgroundColor: Colors.grey,
              child: Text('Phi'),
            ),
          ],
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard('Tổng sản phẩm', '$totalProductCount sản phẩm',
                    Icons.inventory),
                _buildStatCard(
                    'Hết hàng', '$outOfStockCount sản phẩm', Icons.warning),
                _buildStatCard(
                    'Có hạn', '$limitedStockCount sản phẩm', Icons.error),
                _buildStatCard('Sản phẩm khác', '$otherProductCount sản phẩm',
                    Icons.category),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                children: [
                  // Danh sách sản phẩm từ Firestore
                  Expanded(
                    flex: 2,
                    child: Card(
                      color: const Color(0xFF323644),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Danh sách sản phẩm',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            const SizedBox(height: 10),
                            // Thêm các tiêu đề cột
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                _buildHeaderText('Ảnh', 1),
                                _buildHeaderText('Tên Sản Phẩm', 3),
                                _buildHeaderText('Danh Mục', 2),
                                _buildHeaderText('Giá', 2),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: StreamBuilder<QuerySnapshot>(
                                stream:
                                    _databaseMethods.getProducts('Products'),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }

                                  if (snapshot.hasError) {
                                    return const Center(
                                        child: Text('Đã xảy ra lỗi!'));
                                  }

                                  if (!snapshot.hasData ||
                                      snapshot.data!.docs.isEmpty) {
                                    return const Center(
                                        child: Text('Không có sản phẩm nào.'));
                                  }

                                  final productList = snapshot.data!.docs;

                                  return ListView.builder(
                                    itemCount: productList.length,
                                    itemBuilder: (context, index) {
                                      var productData = productList[index]
                                          .data() as Map<String, dynamic>;
                                      return _buildProductRow(
                                        productData['Name'] ?? 'Không có tên',
                                        productData['Category'] ??
                                            'Không có danh mục',
                                        productData['Price']?.toString() ??
                                            'Không có giá',
                                        productData['Image'] ?? '',
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: Card(
                      color: const Color(0xFF323644),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Biểu đồ trạng thái đơn hàng',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              height: 200,
                              child: PieChart(
                                PieChartData(
                                  sections:
                                      _buildOrderChartSections(), // Biểu đồ trạng thái đơn hàng
                                  borderData: FlBorderData(show: false),
                                  sectionsSpace: 0,
                                  centerSpaceRadius: 40,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Thêm phần ghi chú cho trạng thái đơn hàng
                            _buildOrderStatusLegend(),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderText(String title, int flex) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // Ghi chú dưới biểu đồ
  Widget _buildOrderStatusLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 20,
              height: 20,
              color: Colors.orange,
            ),
            const SizedBox(width: 10),
            const Text('Chờ Lấy Hàng',
                style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Container(
              width: 20,
              height: 20,
              color: Colors.blue,
            ),
            const SizedBox(width: 10),
            const Text('Chờ Giao Hàng',
                style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Container(
              width: 20,
              height: 20,
              color: Colors.green,
            ),
            const SizedBox(width: 10),
            const Text('Đã Giao Hàng',
                style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon) {
    return Expanded(
      child: Card(
        color: const Color(0xFF323644),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                count,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String formatCurrency(double price) {
    final formatCurrency = NumberFormat.simpleCurrency(locale: 'vi_VN');
    return formatCurrency.format(price);
  }

  Widget _buildProductRow(
      String name, String category, String price, String imageUrl) {
    double productPrice = 0.0;
    try {
      productPrice = double.parse(price); 
    } catch (e) {
    }

    String formattedPrice = formatCurrency(productPrice);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.center,
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.image_not_supported, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(name,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(category,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(formattedPrice,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center), 
            ),
          ),
        ],
      ),
    );
  }
}
