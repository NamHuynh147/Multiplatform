import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/student.dart';

/// SERVICE: xuất PDF danh sách sinh viên (có ảnh)
class PdfService {
  static Future<void> exportStudents(List<Student> students) async {
    final font = await PdfGoogleFonts.robotoRegular();
    final bold = await PdfGoogleFonts.robotoBold();

    pw.Widget cell(String t, {bool header = false}) => pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(t,
              style: pw.TextStyle(
                  fontWeight:
                      header ? pw.FontWeight.bold : pw.FontWeight.normal)),
        );

    // Icon avatar (hình người trên nền tròn) cho sinh viên chưa có ảnh
    pw.Widget avatar() => pw.ClipOval(
          child: pw.Container(
            width: 50,
            height: 50,
            color: PdfColors.grey300,
            child: pw.Stack(children: [
              pw.Positioned(
                top: 9,
                left: 17,
                child: pw.Container(
                  width: 16,
                  height: 16,
                  decoration: const pw.BoxDecoration(
                      color: PdfColors.grey600, shape: pw.BoxShape.circle),
                ),
              ),
              pw.Positioned(
                top: 30,
                left: 9,
                child: pw.Container(
                  width: 32,
                  height: 30,
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey600,
                    borderRadius: pw.BorderRadius.circular(16),
                  ),
                ),
              ),
            ]),
          ),
        );

    pw.Widget photo(Student s) => pw.Container(
          height: 70,
          alignment: pw.Alignment.center,
          padding: const pw.EdgeInsets.all(3),
          child: s.anhBytes != null
              ? pw.Image(pw.MemoryImage(s.anhBytes!), fit: pw.BoxFit.contain)
              : avatar(),
        );

    final doc =
        pw.Document(theme: pw.ThemeData.withFont(base: font, bold: bold));
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (_) => [
          pw.Header(
              level: 0,
              child: pw.Text('DANH SÁCH SINH VIÊN',
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold))),
          pw.Table(
            border: pw.TableBorder.all(),
            columnWidths: {
              0: const pw.FixedColumnWidth(35),
              1: const pw.FixedColumnWidth(80),
              2: const pw.FlexColumnWidth(),
              3: const pw.FixedColumnWidth(80),
            },
            defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  cell('STT', header: true),
                  cell('MSSV', header: true),
                  cell('Họ tên', header: true),
                  cell('Ảnh', header: true),
                ],
              ),
              for (var i = 0; i < students.length; i++)
                pw.TableRow(children: [
                  cell('${i + 1}'),
                  cell(students[i].maSV),
                  cell(students[i].hoTen),
                  photo(students[i]),
                ]),
            ],
          ),
        ],
      ),
    );

    await Printing.sharePdf(
        bytes: await doc.save(), filename: 'danh_sach_sinh_vien.pdf');
  }
}
