import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:limitim/features/expense/models/expense.dart';

class PdfService {
  Future<void> exportToPdf({
    required List<Expense> expenses,
    required double totalSpent,
    required double remainingLimit,
    required String fileName,
  }) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.robotoRegular();
    final boldFont = await PdfGoogleFonts.robotoBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        // header for all pages
        header: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "Harcama Raporu",
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now()),
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Container(height: 1, color: PdfColors.black),
              pw.SizedBox(height: 10),
            ],
          );
        },
        // footer for all pages (shows page number)
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 10),
            child: pw.Text(
              'Sayfa ${context.pageNumber} / ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
            ),
          );
        },
        build: (pw.Context context) {
          return [
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(2),
              },
              children: [
                // header row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey700),
                  children: [
                    _buildCell("Harcama İsmi", isHeader: true),
                    _buildCell(
                      "Miktar",
                      isHeader: true,
                      align: pw.Alignment.centerRight,
                    ),
                    _buildCell(
                      "Tarih",
                      isHeader: true,
                      align: pw.Alignment.centerRight,
                    ),
                  ],
                ),
                // data rows
                ...expenses.map(
                  (e) => pw.TableRow(
                    children: [
                      _buildCell(e.title),
                      _buildCell(
                        "${e.amount.toStringAsFixed(2)} TL",
                        align: pw.Alignment.centerRight,
                      ),
                      _buildCell(
                        DateFormat('dd.MM.yyyy HH:mm').format(e.date),
                        align: pw.Alignment.centerRight,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // summary table (remaining limit and total spent)
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(5),
                1: const pw.FlexColumnWidth(2),
              },
              children: [
                pw.TableRow(
                  children: [
                    _buildCell(
                      "TOPLAM HARCAMA",
                      color: PdfColors.red,
                      isBold: true,
                    ),
                    _buildCell(
                      "${totalSpent.toStringAsFixed(2)} TL",
                      color: PdfColors.red,
                      isBold: true,
                      align: pw.Alignment.centerRight,
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    _buildCell(
                      "KALAN LİMİT",
                      color: PdfColors.green,
                      isBold: true,
                    ),
                    _buildCell(
                      "${remainingLimit.toStringAsFixed(2)} TL",
                      color: PdfColors.green,
                      isBold: true,
                      align: pw.Alignment.centerRight,
                    ),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: fileName.toLowerCase().endsWith('.pdf')
          ? fileName
          : '$fileName.pdf',
    );
  }

  pw.Widget _buildCell(
    String text, {
    bool isHeader = false,
    bool isBold = false,
    PdfColor color = PdfColors.black,
    pw.Alignment align = pw.Alignment.centerLeft,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: pw.Container(
        alignment: align,
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: isHeader ? 10 : 9,
            fontWeight: (isHeader || isBold)
                ? pw.FontWeight.bold
                : pw.FontWeight.normal,
            color: isHeader ? PdfColors.white : color,
          ),
        ),
      ),
    );
  }
}
