import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../models/student.dart';
import '../services/api_service.dart';
import '../services/pdf_service.dart';

/// CONTROLLER: nghiệp vụ sinh viên
class StudentController extends ChangeNotifier {
  final _api = ApiService();
  final _picker = ImagePicker();

  List<Student> students = [];
  bool loading = false;
  String? error;

  /// Đường dẫn ảnh đã lưu cục bộ trên máy (chụp camera hoặc chọn thư viện)
  String? localImagePath;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      students = await _api.getStudents();
    } catch (e) {
      error = 'Không kết nối được API: $e';
    }
    loading = false;
    notifyListeners();
  }

  /// Chụp ảnh bằng Camera
  Future<void> takePhoto() => _pick(ImageSource.camera);

  /// Chọn ảnh từ thư viện (gallery)
  Future<void> pickFromGallery() => _pick(ImageSource.gallery);

  Future<void> _pick(ImageSource source) async {
    final x = await _picker.pickImage(
        source: source, imageQuality: 60, maxWidth: 800);
    if (x == null) return;
    final dir = await getApplicationDocumentsDirectory();
    final saved = await File(x.path).copy(
        p.join(dir.path, 'sv_${DateTime.now().millisecondsSinceEpoch}.jpg'));
    localImagePath = saved.path;
    notifyListeners();
  }

  Future<void> save(String maSV, String hoTen) async {
    String? b64;
    if (localImagePath != null) {
      b64 = base64Encode(await File(localImagePath!).readAsBytes());
    }
    await _api.saveStudent(
        Student(maSV: maSV.trim(), hoTen: hoTen.trim(), anhBase64: b64));
    localImagePath = null;
    await load();
  }

  /// Sửa ảnh cho một sinh viên đã có trong danh sách
  Future<void> updatePhoto(Student s, ImageSource source) async {
    final x = await _picker.pickImage(
        source: source, imageQuality: 60, maxWidth: 800);
    if (x == null) return;
    final b64 = base64Encode(await x.readAsBytes());
    await _api
        .saveStudent(Student(maSV: s.maSV, hoTen: s.hoTen, anhBase64: b64));
    await load();
  }

  Future<void> delete(String maSV) async {
    await _api.deleteStudent(maSV);
    await load();
  }

  /// Nhập danh sách: mỗi dòng "MSSV,Họ tên" -> lưu vào database
  Future<int> importFromText(String text) async {
    final list = <Student>[];
    for (final line in text.split('\n')) {
      final parts = line.split(RegExp(r'[,;\t]'));
      if (parts.length >= 2 && parts[0].trim().isNotEmpty) {
        list.add(Student(
            maSV: parts[0].trim(), hoTen: parts.sublist(1).join(' ').trim()));
      }
    }
    if (list.isEmpty) return 0;
    await _api.saveStudentsBulk(list);
    await load();
    return list.length;
  }

  Future<void> exportPdf() => PdfService.exportStudents(students);
}
