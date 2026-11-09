import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../controllers/subject_controller.dart';
import '../models/subject.dart';

/// VIEW - Trang 2: Môn học + Map
class SubjectPage extends StatefulWidget {
  const SubjectPage({super.key});
  @override
  State<SubjectPage> createState() => _SubjectPageState();
}

class _SubjectPageState extends State<SubjectPage> {
  final c = SubjectController();
  final maCtl = TextEditingController();
  final tenCtl = TextEditingController();
  final mapCtl = MapController();

  @override
  void initState() {
    super.initState();
    c.load();
    c.locateAndRoute().catchError((_) {});
  }

  void _msg(String s) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));

  Future<void> _save() async {
    if (maCtl.text.trim().isEmpty || tenCtl.text.trim().isEmpty) return _msg('Nhập Mã môn và Tên môn');
    try {
      await c.save(maCtl.text, tenCtl.text);
      maCtl.clear();
      tenCtl.clear();
      _msg('Đã lưu vào database');
    } catch (e) {
      _msg('$e');
    }
  }

  Future<void> _notify(Subject s) async {
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (t == null) return;
    final now = DateTime.now();
    await c.scheduleNotification(s, DateTime(now.year, now.month, now.day, t.hour, t.minute));
    _msg('Sẽ thông báo lúc ${t.format(context)}');
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: c,
      builder: (_, __) {
        final dest = SubjectController.campuses[c.selectedCampus]!;
        return Scaffold(
          appBar: AppBar(title: const Text('Môn học'), actions: [
            IconButton(icon: const Icon(Icons.refresh), onPressed: c.load),
          ]),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(controller: maCtl, decoration: const InputDecoration(labelText: 'Mã môn', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: tenCtl, decoration: const InputDecoration(labelText: 'Tên môn', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: c.selectedCampus,
                decoration: const InputDecoration(labelText: 'Cơ sở', border: OutlineInputBorder()),
                items: [for (final k in SubjectController.campuses.keys) DropdownMenuItem(value: k, child: Text(k))],
                onChanged: (v) {
                  if (v != null) c.selectCampus(v).catchError((_) {});
                },
              ),
              const SizedBox(height: 12),
              FilledButton.icon(onPressed: _save, icon: const Icon(Icons.save), label: const Text('Lưu môn học')),
              const SizedBox(height: 16),
              SizedBox(
                height: 280,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: FlutterMap(
                    mapController: mapCtl,
                    options: MapOptions(initialCenter: dest, initialZoom: 13),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.student_app',
                      ),
                      if (c.route.isNotEmpty)
                        PolylineLayer(polylines: [Polyline(points: c.route, strokeWidth: 4, color: Colors.blue)]),
                      MarkerLayer(markers: [
                        Marker(point: dest, width: 40, height: 40, child: const Icon(Icons.school, color: Colors.red, size: 36)),
                        if (c.myPosition != null)
                          Marker(point: c.myPosition!, width: 40, height: 40, child: const Icon(Icons.my_location, color: Colors.green, size: 32)),
                      ]),
                    ],
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => c.locateAndRoute().catchError((e) => _msg('$e')),
                icon: const Icon(Icons.directions),
                label: const Text('Định vị & vẽ đường đến cơ sở'),
              ),
              const Divider(),
              if (c.error != null) Text(c.error!, style: const TextStyle(color: Colors.red)),
              for (final s in c.subjects)
                ListTile(
                  title: Text('${s.tenMon} (${s.maMon})'),
                  subtitle: Text(s.coSo),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(icon: const Icon(Icons.alarm), tooltip: 'Thông báo giờ học', onPressed: () => _notify(s)),
                    IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => c.delete(s.maMon)),
                  ]),
                ),
            ],
          ),
        );
      },
    );
  }
}
