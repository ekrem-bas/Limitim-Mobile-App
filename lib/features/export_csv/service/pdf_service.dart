import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:limitim/features/expense/models/expense.dart';

class PdfService {
  // cache fonts to avoid reloading them multiple times
  static pw.Font? _regularFont;
  static pw.Font? _boldFont;

  // load fonts from assets if they haven't been loaded yet
  Future<void> _initFonts() async {
    _regularFont ??= pw.Font.ttf(
      await rootBundle.load("assets/fonts/Roboto-Regular.ttf"),
    );
    _boldFont ??= pw.Font.ttf(
      await rootBundle.load("assets/fonts/Roboto-Bold.ttf"),
    );
  }

  Future<void> exportToPdf({
    required List<Expense> expenses,
    required double totalSpent,
    required double remainingLimit,
    required String fileName,
  }) async {
    // ensure fonts are loaded before generating the PDF
    await _initFonts();
    final font = _regularFont!;
    final boldFont = _boldFont!;

    try {
      final pdf = pw.Document();

      // sort expenses by date in ascending order (oldest first)
      expenses.sort((a, b) => a.date.compareTo(b.date));

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          theme: pw.ThemeData.withFont(base: font, bold: boldFont),
          build: (pw.Context context) {
            return [
              // header
              pw.Text(
                "Harcama Raporu",
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Container(height: 1, color: PdfColors.black),
              pw.SizedBox(height: 15),

              // expenses table
              pw.Table(
                border: pw.TableBorder.all(
                  color: PdfColors.grey300,
                  width: 0.5,
                ),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(2),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey700,
                    ),
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

              // summary table (2-cell view with 2 columns)
              pw.Table(
                border: pw.TableBorder.all(
                  color: PdfColors.grey300,
                  width: 0.5,
                ),
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

      // clean the file name by removing any existing .pdf extension (case-insensitive)
      final String baseName = fileName.split('.').first;
      final String fullFileName = '$baseName.pdf';

      // convert the PDF document to bytes
      final Uint8List bytes = await pdf.save();

      // trigger the print dialog to save or share the PDF
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => bytes,
        name: fullFileName,
      );
    } catch (e) {
      // handle any errors that occur during PDF generation or printing
      throw Exception("PDF oluşturulurken bir teknik hata oluştu: $e");
    }
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
