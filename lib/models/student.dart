import 'dart:convert';
import 'dart:typed_data';

/// MODEL: Sinh viên
class Student {
  final String maSV;
  final String hoTen;
  final String? anhBase64;

  Student({required this.maSV, required this.hoTen, this.anhBase64});

  factory Student.fromJson(Map<String, dynamic> j) => Student(
        maSV: j['maSV'] ?? '',
        hoTen: j['hoTen'] ?? '',
        anhBase64: j['anhBase64'],
      );

  Map<String, dynamic> toJson() =>
      {'maSV': maSV, 'hoTen': hoTen, 'anhBase64': anhBase64};

  Uint8List? get anhBytes =>
      (anhBase64 == null || anhBase64!.isEmpty) ? null : base64Decode(anhBase64!);
}
