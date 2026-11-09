import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../models/subject.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

/// CONTROLLER: nghiệp vụ môn học + bản đồ + thông báo
class SubjectController extends ChangeNotifier {
  final _api = ApiService();

  /// Toạ độ các cơ sở (xấp xỉ - đổi lại theo trường của bạn)
  static const Map<String, LatLng> campuses = {
    'Cơ sở Lê Văn Sỹ': LatLng(10.796432, 106.666797),
    'Cơ sở Nhà Bè': LatLng(10.67771, 106.69232),
  };

  List<Subject> subjects = [];
  String? error;
  String selectedCampus = campuses.keys.first;

  LatLng? myPosition;
  List<LatLng> route = [];

  Future<void> load() async {
    try {
      subjects = await _api.getSubjects();
      error = null;
    } catch (e) {
      error = 'Không kết nối được API: $e';
    }
    notifyListeners();
  }

  Future<void> save(String maMon, String tenMon) async {
    await _api.saveSubject(Subject(
        maMon: maMon.trim(), tenMon: tenMon.trim(), coSo: selectedCampus));
    await load();
  }

  Future<void> delete(String maMon) async {
    await _api.deleteSubject(maMon);
    await load();
  }

  Future<void> selectCampus(String c) async {
    selectedCampus = c;
    notifyListeners();
    await locateAndRoute();
  }

  /// Định vị vị trí hiện tại + vẽ đường (polyline) đến cơ sở đã chọn
  Future<void> locateAndRoute() async {
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied)
      perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      error = 'Chưa cấp quyền vị trí';
      notifyListeners();
      return;
    }
    final pos = await Geolocator.getCurrentPosition();
    myPosition = LatLng(pos.latitude, pos.longitude);
    final dest = campuses[selectedCampus]!;

    // Thử lấy đường đi thật từ OSRM; lỗi thì nối thẳng 2 điểm
    try {
      final url = 'https://router.project-osrm.org/route/v1/driving/'
          '${myPosition!.longitude},${myPosition!.latitude};${dest.longitude},${dest.latitude}'
          '?overview=full&geometries=geojson';
      final r =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 8));
      final coords =
          jsonDecode(r.body)['routes'][0]['geometry']['coordinates'] as List;
      route = coords
          .map(
              (c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
          .toList();
    } catch (_) {
      route = [myPosition!, dest];
    }
    notifyListeners();
  }

  /// Hẹn thông báo đến giờ học cho một môn
  Future<void> scheduleNotification(Subject s, DateTime time) async {
    await NotificationService.scheduleAt(
      id: s.maMon.hashCode & 0x7fffffff,
      title: 'Đến giờ học!',
      body: '${s.tenMon} (${s.maMon}) - ${s.coSo}',
      time: time,
    );
  }
}
