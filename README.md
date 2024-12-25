# Shoppingapp

**Ứng dụng kinh doanh đồ dùng công nghệ**

Shoppingapp là một ứng dụng di động được xây dựng bằng Flutter, cung cấp nền tảng mua sắm trực tuyến các sản phẩm công nghệ hiện đại như tai nghe, máy tính, đồng hồ, điện thoại và nhiều sản phẩm khác. Ứng dụng được thiết kế để mang lại trải nghiệm mượt mà và tiện lợi cho người dùng với nhiều tính năng nổi bật.

---

## **Tính năng chính**

### 1. Dành cho người dùng
- **Tìm kiếm sản phẩm:** Hỗ trợ tìm kiếm sản phẩm theo tên.
- **Danh mục sản phẩm:** Duyệt qua nhiều danh mục như tai nghe, máy tính, đồng hồ, điện thoại.
- **Xem thông tin sản phẩm:** Hiển thị chi tiết sản phẩm, bao gồm giá, mô tả và hình ảnh.
- **Thêm vào giỏ hàng:** Dễ dàng thêm sản phẩm vào giỏ hàng để mua sắm.
- **Thanh toán:** Hỗ trợ hiển thị giá cả sản phẩm rõ ràng và nút "Mua ngay".

### 2. Quản lý
- **Phân loại sản phẩm:** Danh mục rõ ràng giúp người dùng tìm kiếm và lựa chọn sản phẩm dễ dàng.
- **Hỗ trợ Firebase:** Lấy dữ liệu từ Firestore để hiển thị sản phẩm.

---

## **Công nghệ sử dụng**

- **Frontend:** Flutter, Dart.
- **Backend:** Firebase Firestore.
- **Thư viện hỗ trợ:**
   - `intl`: Định dạng tiền tệ.
   - `shared_preferences`: Lưu trữ thông tin người dùng.
   - `cloud_firestore`: Tích hợp cơ sở dữ liệu Firebase Firestore.

---

## **Cài đặt và chạy ứng dụng**

### 1. Cài đặt môi trường
- **Flutter SDK:** Cài đặt Flutter trên máy theo hướng dẫn tại [Flutter.dev](https://docs.flutter.dev/get-started/install).
- **Firebase:**
   - Tạo một dự án Firebase.
   - Cấu hình Firestore Database.
   - Tải file cấu hình Firebase (`google-services.json` cho Android, `GoogleService-Info.plist` cho iOS) và thêm vào dự án Flutter.

### 2. Cài đặt các gói
Trong thư mục dự án, chạy lệnh sau:

```pash
flutter pub get
```
### 3. Khởi chạy ứng dụng
a. **Khởi chạy Frontend**
   - Truy cập vào thư mục dự án `shoppingapp`.
   - Cài đặt tất cả các gói cần thiết:
   ```bash
   flutter pub get
   ```
   - Chạy ứng dụng trên thiết bị mô phỏng hoặc thiết bị thật:
   ```bash
   flutter run
   ```
   - Lưu ý:
      - Đảm bảo thiết bị được kết nối với máy tính và chế độ **USB Debugging** được bật.
      - Nếu dùng thiết bị mô phỏng, hãy khởi chạy trình giả lập trước khi chạy lệnh.

b. **Cấu hình Backend**
- Đảm bảo đã cài đặt Firebase trên dự án Flutter.
- Thêm tệp cấu hình Firebase vào thư mục phù hợp:
   - Android: android/app/google-services.json.
   - iOS: ios/Runner/GoogleService-Info.plist.

- Truy cập Firebase Console, bật Firestore Database, và cấu hình các bộ sưu tập cần thiết:
   - Products: Lưu trữ thông tin sản phẩm.
   - Users: Lưu trữ thông tin người dùng.

- Chạy ứng dụng để kiểm tra kết nối Backend hoạt động.

c. **Kiểm tra ứng dụng**
- Mở ứng dụng trên thiết bị hoặc giả lập.
- Đảm bảo các chức năng chính hoạt động:

   - Tìm kiếm sản phẩm.
   - Duyệt danh mục sản phẩm.
   - Xem chi tiết sản phẩm.
   - Thêm sản phẩm vào giỏ hàng hoặc danh sách yêu thích.