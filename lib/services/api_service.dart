import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/student.dart';
import '../models/subject.dart';

/// SERVICE: gọi API ASP.NET Core (SQL Server)
/// 10.0.2.2 = máy tính của bạn nhìn từ Android emulator.
/// Máy thật: đổi thành IP LAN của máy chạy API, ví dụ http://192.168.1.10:5000
class ApiService {
  // static const String baseUrl = 'http://10.0.2.2:5000/api';
  static const String baseUrl = 'http://192.168.40.230:5000/api';
  static const _headers = {'Content-Type': 'application/json'};

  // ----- Sinh viên -----
  Future<List<Student>> getStudents() async {
    final r = await http.get(Uri.parse('$baseUrl/students'));
    if (r.statusCode != 200)
      throw Exception('Lỗi tải sinh viên: ${r.statusCode}');
    return (jsonDecode(r.body) as List)
        .map((e) => Student.fromJson(e))
        .toList();
  }

  Future<void> saveStudent(Student s) async {
    final r = await http.post(Uri.parse('$baseUrl/students'),
        headers: _headers, body: jsonEncode(s.toJson()));
    if (r.statusCode != 200)
      throw Exception('Lỗi lưu sinh viên: ${r.statusCode}');
  }

  Future<void> saveStudentsBulk(List<Student> list) async {
    final r = await http.post(Uri.parse('$baseUrl/students/bulk'),
        headers: _headers,
        body: jsonEncode(list.map((e) => e.toJson()).toList()));
    if (r.statusCode != 200)
      throw Exception('Lỗi nhập danh sách: ${r.statusCode}');
  }

  Future<void> deleteStudent(String id) async {
    await http.delete(Uri.parse('$baseUrl/students/$id'));
  }

  // ----- Môn học -----
  Future<List<Subject>> getSubjects() async {
    final r = await http.get(Uri.parse('$baseUrl/subjects'));
    if (r.statusCode != 200)
      throw Exception('Lỗi tải môn học: ${r.statusCode}');
    return (jsonDecode(r.body) as List)
        .map((e) => Subject.fromJson(e))
        .toList();
  }

  Future<void> saveSubject(Subject s) async {
    final r = await http.post(Uri.parse('$baseUrl/subjects'),
        headers: _headers, body: jsonEncode(s.toJson()));
    if (r.statusCode != 200)
      throw Exception('Lỗi lưu môn học: ${r.statusCode}');
  }

  Future<void> deleteSubject(String id) async {
    await http.delete(Uri.parse('$baseUrl/subjects/$id'));
  }
}
