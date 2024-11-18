import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shoppingapp/pages/onboarding.dart';
import 'package:shoppingapp/services/auth.dart';
import 'package:shoppingapp/services/shared_pref.dart';
import 'package:shoppingapp/widget/support_widget.dart';
import 'package:http/http.dart' as http;


class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? image, name, email;
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;
  String? dowloadUrl;



  getthesharedpref() async {
    image = await SharedPreferenceHelper().getUserImage();
    name = await SharedPreferenceHelper().getUserName();
    email = await SharedPreferenceHelper().getUserEmail();
    setState(() {});
  }

  @override
  void initState() {
    getthesharedpref();
    super.initState();
  }

  Future getImage() async {
    var image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  Future<void> uploadItem() async {
    try {
      if (selectedImage == null) return;

      final uri =
      Uri.parse("https://api.cloudinary.com/v1_1/dc3q6hrz6/image/upload");
      final request = http.MultipartRequest("POST", uri);

      request.fields['upload_preset'] = 'appPreset';
      request.files
          .add(await http.MultipartFile.fromPath('file', selectedImage!.path));
      final response = await request.send();
      final responseData = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        final data = json.decode(responseData.body);
        dowloadUrl = data['secure_url'];
        print('Upload thành công: ${data['secure_url']}');
        print(dowloadUrl);

        await SharedPreferenceHelper().saveUserImage(dowloadUrl!);
        setState(() {
          selectedImage = null;
          image = dowloadUrl;
        });

        // Hiển thị SnackBar thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              "Thêm ảnh thành công!",
              style: TextStyle(fontSize: 20.0),
            ),
          ),
        );
      } else {
        print('Upload thất bại: ${responseData.body}');
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          "Đã xảy ra lỗi không mong muốn. Vui lòng thử lại.",
          style: TextStyle(fontSize: 20.0),
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xfff2f2f2),
        title: Center(
            child: Text(
              "Thông tin",
              style: AppWidget.boldTextFeildStyle(),
            )),
      ),
      backgroundColor: Color(0xfff2f2f2),
      body: name == null
          ? Center(child: CircularProgressIndicator())
          : Container(
        child: Column(
          children: [
            selectedImage != null
                ? GestureDetector(
              onTap: () {
                getImage();
              },
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: Image.file(
                    selectedImage!,
                    height: 150.0,
                    width: 150.0,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )
                : GestureDetector(
              onTap: () {
                getImage();
              },
              child: Center(
                child: image != null && image!.isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: Image.network(
                    image!,
                    height: 150.0,
                    width: 150.0,
                    fit: BoxFit.cover,
                  ),
                )
                    : Icon(Icons.account_circle, size: 70),
              ),
            ),
            SizedBox(
              height: 20.0,
            ),

            // Nút lưu ảnh làm avatar chỉ hiển thị khi đã chọn ảnh
            if (selectedImage != null)
              ElevatedButton(
                onPressed: uploadItem,
                child: Text("Lưu ảnh làm avatar"),
              ),

            SizedBox(
              height: 20.0,
            ),
            Container(
              margin: EdgeInsets.only(left: 20.0, right: 20.0),
              child: Material(
                elevation: 3.0,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: EdgeInsets.only(
                      left: 10.0, right: 10.0, top: 10.0, bottom: 10.0),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_outlined,
                        size: 35.0,
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Tên",
                            style: AppWidget.lightTextFeildStyle(),
                          ),
                          Text(
                            name!,
                            style: AppWidget.semiboldTextFeildStyle(),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Container(
              margin: EdgeInsets.only(left: 20.0, right: 20.0),
              child: Material(
                elevation: 3.0,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: EdgeInsets.only(
                      left: 10.0, right: 10.0, top: 10.0, bottom: 10.0),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      Icon(
                        Icons.email_outlined,
                        size: 35.0,
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Email",
                            style: AppWidget.lightTextFeildStyle(),
                          ),
                          Text(
                            email!,
                            style: AppWidget.semiboldTextFeildStyle(),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            GestureDetector(
              onTap: () async {

                // Đăng xuất khỏi Firebase
                await AuthMethods().signOut();

                // Điều hướng về màn hình Onboarding
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Onboarding(),
                  ),
                );

                // Cập nhật trạng thái để làm mới giao diện
                setState(() {
                  image = null;
                  name = null;
                  email = null;
                });
              },
              child: Container(
                margin: EdgeInsets.only(left: 20.0, right: 20.0),
                child: Material(
                  elevation: 3.0,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: EdgeInsets.only(
                        left: 10.0, right: 10.0, top: 10.0, bottom: 10.0),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      children: [
                        Icon(
                          Icons.logout,
                          size: 35.0,
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        Text(
                          "Đăng xuất",
                          style: AppWidget.semiboldTextFeildStyle(),
                        ),
                        Spacer(),
                        Icon(Icons.arrow_forward_ios_outlined)
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(
              height: 20.0,
            ),
            GestureDetector(
              onTap: () async {
                await AuthMethods().deleteUser().then((value) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Onboarding()));
                });
              },
              child: Container(
                margin: EdgeInsets.only(left: 20.0, right: 20.0),
                child: Material(
                  elevation: 3.0,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: EdgeInsets.only(
                        left: 10.0, right: 10.0, top: 10.0, bottom: 10.0),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          size: 35.0,
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        Text(
                          "Xóa tài khoản",
                          style: AppWidget.semiboldTextFeildStyle(),
                        ),
                        Spacer(),
                        Icon(Icons.arrow_forward_ios_outlined)
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
