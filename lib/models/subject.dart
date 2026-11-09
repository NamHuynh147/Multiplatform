/// MODEL: Môn học
class Subject {
  final String maMon;
  final String tenMon;
  final String coSo;

  Subject({required this.maMon, required this.tenMon, required this.coSo});

  factory Subject.fromJson(Map<String, dynamic> j) => Subject(
        maMon: j['maMon'] ?? '',
        tenMon: j['tenMon'] ?? '',
        coSo: j['coSo'] ?? '',
      );

  Map<String, dynamic> toJson() =>
      {'maMon': maMon, 'tenMon': tenMon, 'coSo': coSo};
}
