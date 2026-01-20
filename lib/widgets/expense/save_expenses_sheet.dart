import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:limitim/bloc/session_bloc/active_session_bloc.dart';

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

    // Mevcut yıldan 2 yıl öncesi ve 2 yıl sonrasını içeren bir liste
    _years = List.generate(5, (index) => (now.year - 2) + index);
  }

  void _onConfirm() {
    context.read<ActiveSessionBloc>().add(
      FinalizeSessionEvent(monthName: _selectedMonth, year: _selectedYear),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Dönemi Arşivle",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Mevcut harcamalarınız geçmişe taşınacak ve yeni bir dönem başlayacaktır.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),

          // Ay Seçimi
          DropdownButtonFormField<String>(
            initialValue: _selectedMonth,
            decoration: const InputDecoration(
              labelText: "Ay Seçin",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.calendar_month),
            ),
            items: _months
                .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                .toList(),
            onChanged: (val) => setState(() => _selectedMonth = val!),
          ),

          const SizedBox(height: 16),

          // Yıl Seçimi
          DropdownButtonFormField<int>(
            initialValue: _selectedYear,
            decoration: const InputDecoration(
              labelText: "Yıl Seçin",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.event),
            ),
            items: _years
                .map(
                  (y) => DropdownMenuItem(value: y, child: Text(y.toString())),
                )
                .toList(),
            onChanged: (val) => setState(() => _selectedYear = val!),
          ),

          const SizedBox(height: 32),

          // Onay Butonu
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _onConfirm,
              child: const Text("Arşivlemeyi Tamamla"),
            ),
          ),
          const SizedBox(height: 8),

          // VAZGEÇ BUTONU
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Vazgeç",
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
