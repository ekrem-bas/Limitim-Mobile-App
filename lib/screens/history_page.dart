import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:limitim/bloc/history_bloc/history_bloc.dart';
import 'package:limitim/widgets/history/history_list_view.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Geçmiş Bütçeler',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, state) {
          if (state is HistoryLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.black),
            );
          }
          if (state is HistoryLoaded) {
            if (state.archivedMonths.isEmpty) {
              return _buildEmptyHistoryState();
            }
            return HistoryListView(archivedMonths: state.archivedMonths);
          }
          if (state is HistoryError) {
            return Center(child: Text("Bir hata oluştu: ${state.message}"));
          }
          if (state is HistoryEmpty) {
            return _buildEmptyHistoryState();
          }
          return const SizedBox();
        },
      ),
    );
  }

  // Geçmiş boş olduğunda görünecek şık tasarım
  Widget _buildEmptyHistoryState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            "Henüz arşivlenmiş bir dönem yok.",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
