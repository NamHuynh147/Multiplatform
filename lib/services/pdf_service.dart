import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/student.dart';

/// SERVICE: xuất PDF danh sách sinh viên hiện tại
class PdfService {
  static Future<void> exportStudents(List<Student> students) async {
    // Dùng font hỗ trợ tiếng Việt
    final font = await PdfGoogleFonts.robotoRegular();
    final bold = await PdfGoogleFonts.robotoBold();

    final doc = pw.Document(theme: pw.ThemeData.withFont(base: font, bold: bold));
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (_) => [
          pw.Header(level: 0, child: pw.Text('DANH SÁCH SINH VIÊN',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold))),
          pw.TableHelper.fromTextArray(
            headers: ['STT', 'MSSV', 'Họ tên'],
            data: [
              for (var i = 0; i < students.length; i++)
                ['${i + 1}', students[i].maSV, students[i].hoTen],
            ],
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellAlignment: pw.Alignment.centerLeft,
          ),
        ],
      ),
    );

    // Mở màn hình xem trước / chia sẻ / lưu PDF
    await Printing.sharePdf(bytes: await doc.save(), filename: 'danh_sach_sinh_vien.pdf');
  }
}
