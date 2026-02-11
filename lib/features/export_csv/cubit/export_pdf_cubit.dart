import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:limitim/features/expense/models/expense.dart';
import 'package:limitim/features/export_csv/service/pdf_service.dart';

part 'export_pdf_state.dart';

class ExportPdfCubit extends Cubit<ExportPdfState> {
  final PdfService _pdfService = PdfService();

  ExportPdfCubit() : super(ExportPdfInitial());

  // start the process of exporting to PDF
  Future<void> exportToPdf({
    required List<Expense> expenses,
    required double totalSpent,
    required double remainingLimit,
    required String fileName,
  }) async {
    emit(ExportingPdf());
    try {
      await _pdfService.exportToPdf(
        expenses: expenses,
        totalSpent: totalSpent,
        remainingLimit: remainingLimit,
        fileName: fileName,
      );

      emit(ExportPdfSuccess());
    } catch (e) {
      emit(ExportPdfFailure(message: e.toString()));
    }
  }
}
