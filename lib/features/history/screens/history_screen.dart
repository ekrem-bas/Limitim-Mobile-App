import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:limitim/core/widgets/app_drawer.dart';
import 'package:limitim/features/history/bloc/history_bloc.dart';
import 'package:limitim/features/history/widgets/history_list_view.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  final String _appBarTitleText = "Geçmiş Bütçeler";
  final String _errorTextPrefix = "Bir hata oluştu: ";
  final String _emptyHistoryText = "Henüz arşivlenmiş bir dönem yok.";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(
          _appBarTitleText,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, state) {
          // state 1: loading histories
          if (state is HistoryLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          }

          // state 2: loaded histories
          // show list of histories
          if (state is HistoryLoaded) {
            return HistoryListView(archivedMonths: state.archivedMonths);
          }

          // state 3: error occurred
          // show error message
          if (state is HistoryError) {
            return Center(child: Text("$_errorTextPrefix${state.message}"));
          }

          // state 4: empty history
          // show empty state message
          if (state is HistoryEmpty) {
            return _buildEmptyHistoryState(context);
          }
          return const SizedBox();
        },
      ),
    );
  }

  // empty history state widget
  Widget _buildEmptyHistoryState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_toggle_off,
            size: 80,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          Text(
            _emptyHistoryText,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}
