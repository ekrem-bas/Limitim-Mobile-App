part of 'export_pdf_cubit.dart';

sealed class ExportPdfState extends Equatable {
  const ExportPdfState();

  @override
  List<Object> get props => [];
}

final class ExportPdfInitial extends ExportPdfState {}

final class ExportingPdf extends ExportPdfState {}

final class ExportPdfSuccess extends ExportPdfState {}

final class ExportPdfFailure extends ExportPdfState {
  final String message;

  const ExportPdfFailure({required this.message});

  @override
  List<Object> get props => [message];
}
