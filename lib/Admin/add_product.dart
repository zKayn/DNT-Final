import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shoppingapp/Admin/home_admin.dart';
import 'package:shoppingapp/services/database.dart';
import 'package:shoppingapp/widget/support_widget.dart';
import 'package:http/http.dart' as http;

class AddProduct extends StatefulWidget {
  final String? productId;  // Tham số productId
  const AddProduct({super.key, this.productId});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {

  final ImagePicker _picker = ImagePicker();
  File? selectedImage;
  String? dowloadUrl;
  TextEditingController namecontroller = TextEditingController();
  TextEditingController pricecontroller = TextEditingController();
  TextEditingController detailcontroller = TextEditingController();

  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.productId != null) {
      isEditing = true;
      _loadProductData(widget.productId!); // Gọi hàm tải dữ liệu nếu đang chỉnh sửa
    }
  }

  // Hàm tải dữ liệu sản phẩm từ Firebase
  Future<void> _loadProductData(String productId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection("Products").doc(productId).get();
      if (doc.exists) {
        var data = doc.data() as Map<String, dynamic>;
        namecontroller.text = data["Name"];
        pricecontroller.text = data["Price"].toString();
        detailcontroller.text = data["Detail"] ?? '';
        categoryValue = data["Category"];
        dowloadUrl = data["Image"];

        setState(() {
          // Nếu đã có đường dẫn ảnh từ Firestore, hiển thị ảnh
          if (dowloadUrl != null) {
            selectedImage = null; // Xóa tệp cục bộ nếu có
          }
        });
      }
    } catch (e) {
      print("Lỗi khi tải dữ liệu sản phẩm: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi tải dữ liệu sản phẩm")),
      );
    }
  }

  // Hàm chọn ảnh từ thư viện
  Future getImage() async {
    var image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  Future<void> uploadItem() async {
    if ((selectedImage != null || dowloadUrl != null) && namecontroller.text.isNotEmpty) {
      try {
        // Nếu có ảnh mới, upload ảnh lên Cloudinary
        if (selectedImage != null) {
          final uri = Uri.parse("https://api.cloudinary.com/v1_1/dc3q6hrz6/image/upload");
          final request = http.MultipartRequest("POST", uri);
          request.fields['upload_preset'] = 'appPreset';
          request.files.add(await http.MultipartFile.fromPath('file', selectedImage!.path));
          final response = await request.send();
          final responseData = await http.Response.fromStream(response);

          if (response.statusCode == 200) {
            final data = json.decode(responseData.body);
            dowloadUrl = data['secure_url'];
          } else {
            print('Upload thất bại: ${responseData.body}');
            return;
          }
        }

        // Chuẩn bị dữ liệu sản phẩm
        String firstletter = namecontroller.text.substring(0, 1).toUpperCase();
        Map<String, dynamic> newProduct = {
          "Name": namecontroller.text,
          "Image": dowloadUrl!,
          "SearchKey": firstletter,
          "UpdateName": namecontroller.text.toUpperCase(),
          "Price": pricecontroller.text,
          "Detail": detailcontroller.text,
          "Category": categoryValue,
        };

        // Update hoặc thêm sản phẩm mới
        if (widget.productId != null) {
          await DatabaseMethods().updateProduct(widget.productId!, newProduct);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.green,
            content: Text("Sản phẩm đã được cập nhật thành công!"),
          ));
        } else {
          await DatabaseMethods().addProduct(newProduct, categoryValue!).then((_) async {
            await DatabaseMethods().addAllProducts(newProduct);
            setState(() {
              selectedImage = null;
              namecontroller.clear();
              pricecontroller.clear();
              detailcontroller.clear();
            });
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.green,
              content: Text("Sản phẩm đã được tải lên thành công!"),
            ));
          });
        }
      } catch (e) {
        print("Error: $e");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text("Đã xảy ra lỗi không mong muốn. Vui lòng thử lại."),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text("Vui lòng chọn một hình ảnh và nhập tên."),
      ));
    }
  }


  String? categoryValue; // Biến để lưu giá trị danh mục
  final List<String> categoryItems = [
    'Đồng hồ',
    'Máy tính',
    'Điện thoại',
    'Tai nghe'
  ]; // Các mục danh mục

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
            isEditing ? "Chỉnh sửa sản phẩm" : "Thêm sản phẩm",
            style: AppWidget.semiboldTextFeildStyle(),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Tải lên hình ảnh sản phẩm",
                style: AppWidget.lightTextFeildStyle(),
              ),
              SizedBox(height: 20.0),
              selectedImage == null && dowloadUrl != null
                  ? Center(
                child: Image.network(dowloadUrl!, height: 150, width: 150, fit: BoxFit.cover),
              )
                  : GestureDetector(
                onTap: () async {
                  await getImage(); // Chọn ảnh mới
                  setState(() {
                    if (selectedImage != null) {
                      dowloadUrl = null; // Xóa đường dẫn ảnh cũ
                    }
                  });
                },
                child: Center(
                  child: Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1.5),
                        borderRadius: BorderRadius.circular(20)),
                    child: selectedImage == null
                        ? (dowloadUrl != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(dowloadUrl!,
                          fit: BoxFit.cover, height: 150, width: 150),
                    )
                        : Icon(Icons.camera_alt_outlined))
                        : ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(selectedImage!, fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20.0),
              buildTextField("Tên sản phẩm", namecontroller),
              SizedBox(height: 20.0),
              buildTextField("Giá sản phẩm", pricecontroller),
              SizedBox(height: 20.0),
              buildTextField("Chi tiết sản phẩm", detailcontroller, maxLines: 6),
              SizedBox(height: 20.0),
              buildCategoryDropdown(),
              SizedBox(height: 30.0),
              Center(
                child: ElevatedButton(
                  onPressed: uploadItem,
                  child: Text(
                    isEditing ? "Cập nhật sản phẩm" : "Thêm sản phẩm",
                    style: TextStyle(fontSize: 22.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget để tạo trường nhập liệu cho tên, giá và chi tiết sản phẩm
  Widget buildTextField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppWidget.lightTextFeildStyle(),
        ),
        SizedBox(height: 20.0),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Color(0xFFececf8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(border: InputBorder.none),
          ),
        ),
      ],
    );
  }

  // Widget tạo dropdown chọn danh mục sản phẩm
  Widget buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Danh mục sản phẩm",
          style: AppWidget.lightTextFeildStyle(),
        ),
        SizedBox(height: 20.0),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Color(0xFFececf8),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              items: categoryItems
                  .map((item) => DropdownMenuItem(
                        value: item,
                        child: Text(item,
                            style: AppWidget.semiboldTextFeildStyle()),
                      ))
                  .toList(),
              onChanged: (value) => setState(() {
                categoryValue = value;
              }),
              dropdownColor: Colors.white,
              hint: Text("Chọn danh mục"),
              iconSize: 36,
              icon: Icon(Icons.arrow_drop_down, color: Colors.black),
              value: categoryValue,
            ),
          ),
        ),
      ],
    );
  }
}
