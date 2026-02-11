import 'package:flutter/material.dart';

class ExportSheet extends StatefulWidget {
  final double totalSpent;
  final double remainingLimit;
  final Function(String fileName) onExport;
  const ExportSheet({
    super.key,
    required this.totalSpent,
    required this.remainingLimit,
    required this.onExport,
  });

  @override
  State<ExportSheet> createState() => _ExportSheetState();
}

class _ExportSheetState extends State<ExportSheet> {
  TextEditingController _fileNameController = TextEditingController();

  final String _defaultFileName = "Harcama_Raporu";
  final String _title = "Raporu PDF Olarak Dışa Aktar";
  final String _fileNameHint = "Dosya Adı";
  final String _fileExtension = ".pdf";
  final String _exportButtonText = "Dışa Aktar";
  final String _cancelButtonText = "İptal";

  @override
  void initState() {
    super.initState();
    _fileNameController = TextEditingController(text: _defaultFileName);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // title
          _buildTitle(context),

          const SizedBox(height: 20),

          // file name input
          _buildFileNameInput(),

          const SizedBox(height: 20),

          // export button
          _exportButton(context),

          const SizedBox(height: 8),

          // cancel button
          _cancelButton(context),
        ],
      ),
    );
  }

  SizedBox _cancelButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(
          _cancelButtonText,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ),
    );
  }

  SizedBox _exportButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () => widget.onExport(_fileNameController.text),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          _exportButtonText,
          style: TextStyle(
            fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  TextField _buildFileNameInput() {
    return TextField(
      controller: _fileNameController,
      decoration: InputDecoration(
        labelText: _fileNameHint,
        suffixText: _fileExtension,
        border: OutlineInputBorder(),
      ),
      onTap: () {
        // select all text when the user taps the field if it still has the default name
        if (_fileNameController.text == _defaultFileName) {
          _fileNameController.selection = TextSelection(
            baseOffset: 0,
            extentOffset: _fileNameController.text.length,
          );
        }
      },
    );
  }

  Text _buildTitle(BuildContext context) =>
      Text(_title, style: Theme.of(context).textTheme.displayMedium);
}
