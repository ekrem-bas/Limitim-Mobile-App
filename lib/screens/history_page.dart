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
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          }
          if (state is HistoryLoaded) {
            if (state.archivedMonths.isEmpty) {
              return _buildEmptyHistoryState(context);
            }
            return HistoryListView(archivedMonths: state.archivedMonths);
          }
          if (state is HistoryError) {
            return Center(child: Text("Bir hata oluştu: ${state.message}"));
          }
          if (state is HistoryEmpty) {
            return _buildEmptyHistoryState(context);
          }
          return const SizedBox();
        },
      ),
    );
  }

  // Geçmiş boş olduğunda görünecek şık tasarım
  Widget _buildEmptyHistoryState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_toggle_off,
            size: 80,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
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
