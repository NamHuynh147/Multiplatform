# Ứng dụng Quản lý Sinh viên – Môn học (Flutter MVC + ASP.NET Core + SQL Server)

## Cấu trúc

```
student_project/
├── database.sql              # tạo DB StudentDb + bảng Students, Subjects
├── StudentApi/               # API ASP.NET Core (.NET 8) nối SQL Server
└── student_app/              # App Flutter (MVC)
    └── lib/
        ├── models/           # M: student.dart, subject.dart
        ├── views/            # V: student_page.dart (Trang 1), subject_page.dart (Trang 2 + Map)
        ├── controllers/      # C: student_controller.dart, subject_controller.dart
        ├── services/         # api_service, notification_service, pdf_service
        └── main.dart
```

## Đối chiếu yêu cầu

| #   | Yêu cầu                               | Nằm ở đâu                                                 |
| --- | ------------------------------------- | --------------------------------------------------------- |
| 1   | MVC                                   | models / views / controllers                              |
| 2   | Camera + lưu ảnh cục bộ               | `StudentController.takePhoto()`                           |
| 3   | SQL Server + API (SV có ảnh, môn học) | `StudentApi/Program.cs`, `api_service.dart`               |
| 4   | Map: định vị + polyline               | `SubjectController.locateAndRoute()`, `subject_page.dart` |
| 5   | Thông báo đến giờ học                 | `notification_service.dart`, nút chuông ở danh sách môn   |
| 6   | Nhập danh sách SV vào DB              | nút upload ở Trang 1 → `/api/students/bulk`               |
| +   | Xuất PDF danh sách SV                 | nút PDF ở Trang 1 → `pdf_service.dart`                    |

## Cách chạy

### 1. Database

Mở `database.sql` trong SSMS và chạy.

### 2. API

```bash
cd StudentApi
dotnet restore
dotnet run        # chạy ở http://0.0.0.0:5000
```

Sửa chuỗi kết nối trong `appsettings.json` nếu SQL Server của bạn dùng tài khoản/mật khẩu, ví dụ:
`Server=localhost;Database=StudentDb;User Id=sa;Password=...;TrustServerCertificate=True;`

### 3. App Flutter

```bash
flutter create student_app_tmp
# copy thư mục android/ ios/ từ student_app_tmp vào student_app/ (hoặc copy lib/ + pubspec.yaml vào project mới)
cd student_app
flutter pub get
flutter run
```

Emulator gọi API bằng `http://10.0.2.2:5000`. Máy thật thì sửa `baseUrl` trong `api_service.dart` thành IP LAN của máy chạy API.

### 4. Cấu hình Android (BẮT BUỘC)

`android/app/src/main/AndroidManifest.xml`, trong thẻ `<manifest>` thêm:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
```

Trong thẻ `<application>` thêm `android:usesCleartextTraffic="true"` (để gọi http), và trong `<application>` thêm 2 receiver cho thông báo hẹn giờ:

```xml
<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver"/>
<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
  <intent-filter>
    <action android:name="android.intent.action.BOOT_COMPLETED"/>
    <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
  </intent-filter>
</receiver>
```

Trong `android/app/build.gradle` (hoặc `.kts`): `minSdk = 21` trở lên, và bật `coreLibraryDesugaring` nếu `flutter_local_notifications` yêu cầu
(xem hướng dẫn của package).

### 5. Emulator

- Camera: Extended controls (…) → Camera → chọn _Virtual scene_ hoặc _Webcam0_.
- Vị trí: Extended controls → Location → đặt điểm bất kỳ rồi _Send_.

## Lưu ý

- Toạ độ 2 cơ sở trong `subject_controller.dart` là xấp xỉ, sửa lại cho đúng trường của bạn.
- Đường đi (polyline) lấy từ OSRM công khai, cần Internet; nếu lỗi sẽ nối thẳng 2 điểm.
- Code chưa được build thử trong môi trường này (không có Flutter SDK/SQL Server), nên nếu gặp lỗi phiên bản package thì chạy `flutter pub upgrade` hoặc báo lỗi mình sửa.
