import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/student_controller.dart';
import '../models/student.dart';

/// VIEW - Trang 1: Sinh viên
class StudentPage extends StatefulWidget {
  const StudentPage({super.key});
  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  final c = StudentController();
  final maCtl = TextEditingController();
  final tenCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    c.load();
  }

  void _msg(String s) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));

  Future<void> _save() async {
    if (maCtl.text.trim().isEmpty || tenCtl.text.trim().isEmpty)
      return _msg('Nhập MSSV và Họ tên');
    try {
      await c.save(maCtl.text, tenCtl.text);
      maCtl.clear();
      tenCtl.clear();
      _msg('Đã lưu vào database');
    } catch (e) {
      _msg('$e');
    }
  }

  Future<void> _import() async {
    final ctl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nhập danh sách sinh viên'),
        content: TextField(
          controller: ctl,
          maxLines: 8,
          decoration: const InputDecoration(
              hintText:
                  'Mỗi dòng: MSSV,Họ tên\n1250080083, Phạm Long Khoa \n 1250080109, Huỳnh Đại Lục'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Huỷ')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Nhập')),
        ],
      ),
    );
    if (ok == true) {
      try {
        final n = await c.importFromText(ctl.text);
        _msg('Đã nhập $n sinh viên');
      } catch (e) {
        _msg('$e');
      }
    }
  }

  /// Sửa ảnh một sinh viên trong danh sách
  Future<void> _editPhoto(Student s) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Chọn từ thư viện'),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Chụp ảnh mới'),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
        ]),
      ),
    );
    if (source == null) return;
    try {
      await c.updatePhoto(s, source);
      _msg('Đã cập nhật ảnh');
    } catch (e) {
      _msg('$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: c,
      builder: (_, __) => Scaffold(
        appBar: AppBar(
          title: const Text('Khoa CNTT - Flutter'),
          actions: [
            IconButton(
                tooltip: 'Nhập danh sách',
                icon: const Icon(Icons.upload_file),
                onPressed: _import),
            IconButton(
              tooltip: 'Xuất PDF',
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: () => c.exportPdf().catchError((e) => _msg('$e')),
            ),
            IconButton(
                tooltip: 'Tải lại',
                icon: const Icon(Icons.refresh),
                onPressed: c.load),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
                controller: maCtl,
                decoration: const InputDecoration(
                    labelText: 'MSSV', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(
                controller: tenCtl,
                decoration: const InputDecoration(
                    labelText: 'Họ tên', border: OutlineInputBorder())),
            const SizedBox(height: 12),

            // Khung ảnh: bấm vào để chọn ảnh từ thư viện
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => c.pickFromGallery().catchError((e) => _msg('$e')),
              child: Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: c.localImagePath == null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            Opacity(
                              opacity: 0.35,
                              child: Image.asset(
                                'assets/images/sinhvien.jpg',
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                    Icons.person,
                                    size: 64,
                                    color: Colors.grey),
                              ),
                            ),
                            Center(
                              child: Text(
                                'Click để chọn ảnh từ thư viện',
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontSize: 16,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Image.file(File(c.localImagePath!),
                          fit: BoxFit.contain),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => c.takePhoto().catchError((e) => _msg('$e')),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Chụp ảnh (Camera)'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                  child: FilledButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.save),
                      label: const Text('Lưu'))),
            ]),
            const Divider(height: 32),
            if (c.loading) const Center(child: CircularProgressIndicator()),
            if (c.error != null)
              Text(c.error!, style: const TextStyle(color: Colors.red)),
            for (final s in c.students)
              ListTile(
                leading: GestureDetector(
                  onTap: () => _editPhoto(s),
                  child: s.anhBytes != null
                      ? CircleAvatar(backgroundImage: MemoryImage(s.anhBytes!))
                      : const CircleAvatar(child: Icon(Icons.person)),
                ),
                title: Text(s.hoTen),
                subtitle: Text(s.maSV),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  IconButton(
                    tooltip: 'Sửa ảnh',
                    icon: const Icon(Icons.add_a_photo_outlined),
                    onPressed: () => _editPhoto(s),
                  ),
                  IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => c.delete(s.maSV)),
                ]),
              ),
          ],
        ),
      ),
    );
  }
}
