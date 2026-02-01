import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:limitim/features/expense/bloc/session_bloc.dart';

class SaveExpensesSheet extends StatefulWidget {
  const SaveExpensesSheet({super.key});

  @override
  State<SaveExpensesSheet> createState() => _SaveExpensesSheetState();
}

class _SaveExpensesSheetState extends State<SaveExpensesSheet> {
  final List<String> _months = [
    "Ocak",
    "Şubat",
    "Mart",
    "Nisan",
    "Mayıs",
    "Haziran",
    "Temmuz",
    "Ağustos",
    "Eylül",
    "Ekim",
    "Kasım",
    "Aralık",
  ];

  late String _selectedMonth;
  late int _selectedYear;
  late List<int> _years;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = _months[now.month - 1];
    _selectedYear = now.year;

    // generate a list of years from current year -2 to current year +2
    _years = List.generate(5, (index) => (now.year - 2) + index);
  }

  void _onConfirm() {
    final String customName = _customNameController.text.trim();
    context.read<SessionBloc>().add(
      FinalizeSessionEvent(
        monthName: _selectedMonth,
        year: _selectedYear,
        customName: customName.isEmpty ? null : customName,
      ),
    );

    Navigator.pop(context);
  }

  final String _finalizeSessionText = "Dönemi Arşivle";
  final String _finalizeSessionHintText =
      "Mevcut harcamalarınız geçmişe taşınacak ve yeni bir dönem başlayacaktır.";
  final String _selectMonthText = "Ay Seçin";
  final String _selectYearText = "Yıl Seçin";
  final String _confirmButtonText = "Arşivlemeyi Tamamla";
  final String _cancelButtonText = "Vazgeç";
  final String _customNameLabelText = "Harcama Dönemi Adı (Opsiyonel)";

  final TextEditingController _customNameController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _customNameController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    // if keyboard is open, scroll to bottom to show the focused input
    if (keyboardHeight > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: keyboardHeight + 20,
        left: 20,
        right: 20,
      ),
      child: ListView(
        controller: _scrollController,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const ClampingScrollPhysics(),
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context),
              const SizedBox(height: 12),

              // month selection
              _buildMonthSelection(),
              const SizedBox(height: 10),

              // year selection
              _buildYearSelection(),
              const SizedBox(height: 10),

              // for custom name input
              _buildCustomNameField(),
              const SizedBox(height: 12),

              // confirm button
              _confirmButton(context),
              const SizedBox(height: 6),

              // cancel button
              _cancelButton(context),
            ],
          ),
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

  SizedBox _confirmButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: _onConfirm,
        child: Text(
          _confirmButtonText,
          style: TextStyle(
            fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  TextField _buildCustomNameField() {
    return TextField(
      controller: _customNameController,
      decoration: InputDecoration(
        labelText: _customNameLabelText,
        border: const OutlineInputBorder(),
      ),
    );
  }

  DropdownButtonFormField<int> _buildYearSelection() {
    return DropdownButtonFormField<int>(
      initialValue: _selectedYear,
      decoration: InputDecoration(
        labelText: _selectYearText,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.event),
      ),
      items: _years
          .map((y) => DropdownMenuItem(value: y, child: Text(y.toString())))
          .toList(),
      onChanged: (val) => setState(() => _selectedYear = val!),
    );
  }

  DropdownButtonFormField<String> _buildMonthSelection() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedMonth,
      decoration: InputDecoration(
        labelText: _selectMonthText,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.calendar_month),
      ),
      items: _months
          .map((m) => DropdownMenuItem(value: m, child: Text(m)))
          .toList(),
      onChanged: (val) => setState(() => _selectedMonth = val!),
    );
  }

  Column _buildHeader(BuildContext context) {
    return Column(
      children: [
        Text(
          _finalizeSessionText,
          style: Theme.of(context).textTheme.displayMedium,
        ),
        const SizedBox(height: 6),
        Text(
          _finalizeSessionHintText,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
