import 'dart:io';
import 'package:flutter/material.dart';
import '../controllers/student_controller.dart';

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

  void _msg(String s) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));

  Future<void> _save() async {
    if (maCtl.text.trim().isEmpty || tenCtl.text.trim().isEmpty) return _msg('Nhập MSSV và Họ tên');
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
              hintText: 'Mỗi dòng: MSSV,Họ tên\n2100001,Nguyễn Văn A\n2100002,Trần Thị B'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Huỷ')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Nhập')),
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

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: c,
      builder: (_, __) => Scaffold(
        appBar: AppBar(
          title: const Text('Khoa CNTT - Flutter'),
          actions: [
            IconButton(tooltip: 'Nhập danh sách', icon: const Icon(Icons.upload_file), onPressed: _import),
            IconButton(
              tooltip: 'Xuất PDF',
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: () => c.exportPdf().catchError((e) => _msg('$e')),
            ),
            IconButton(tooltip: 'Tải lại', icon: const Icon(Icons.refresh), onPressed: c.load),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(controller: maCtl, decoration: const InputDecoration(labelText: 'MSSV', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: tenCtl, decoration: const InputDecoration(labelText: 'Họ tên', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            Container(
              height: 160,
              decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
              child: c.localImagePath == null
                  ? const Center(child: Text('Ảnh chụp'))
                  : ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(c.localImagePath!), fit: BoxFit.contain)),
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
              Expanded(child: FilledButton.icon(onPressed: _save, icon: const Icon(Icons.save), label: const Text('Lưu'))),
            ]),
            const Divider(height: 32),
            if (c.loading) const Center(child: CircularProgressIndicator()),
            if (c.error != null) Text(c.error!, style: const TextStyle(color: Colors.red)),
            for (final s in c.students)
              ListTile(
                leading: s.anhBytes != null
                    ? CircleAvatar(backgroundImage: MemoryImage(s.anhBytes!))
                    : const CircleAvatar(child: Icon(Icons.person)),
                title: Text(s.hoTen),
                subtitle: Text(s.maSV),
                trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => c.delete(s.maSV)),
              ),
          ],
        ),
      ),
    );
  }
}
