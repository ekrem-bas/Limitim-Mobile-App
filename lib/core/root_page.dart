import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:limitim/features/history/bloc/history_bloc.dart';
import 'package:limitim/features/expense/bloc/session_bloc.dart';
import 'package:limitim/features/history/screens/history_screen.dart';
import 'package:limitim/features/expense/screens/expense_screen.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int _currentIndex = 0;

  // list of pages
  final List<Widget> pages = [const ExpenseScreen(), const HistoryScreen()];

  void _onItemTapped(int index) {
    if (_currentIndex == index) return; // prevent reloading the same page

    setState(() => _currentIndex = index);

    if (index == 1) {
      final historyState = context.read<HistoryBloc>().state;
      // Only fetch data if in initial state or error state
      if (historyState is HistoryLoading || historyState is HistoryError) {
        context.read<HistoryBloc>().add(LoadHistoryEvent());
      }
    }
  }

  final String _titleExpense = "Harcamalar";
  final String _titleHistory = "Geçmiş";

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<SessionBloc, SessionState>(
          listener: (context, state) {
            // if there is no active session (user has ended the month)
            if (state is NoActiveSession) {
              // load history page data
              context.read<HistoryBloc>().add(LoadHistoryEvent());
            }
          },
        ),
      ],
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: pages),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor:
              Theme.of(context).navigationBarTheme.backgroundColor ??
              Theme.of(context).colorScheme.surface,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
          items: [
            _navBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: _titleExpense,
            ),
            _navBarItem(
              icon: const Icon(Icons.history_outlined),
              activeIcon: const Icon(Icons.history),
              label: _titleHistory,
            ),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _navBarItem({
    required Icon icon,
    required Icon activeIcon,
    required String label,
  }) {
    return BottomNavigationBarItem(
      icon: icon,
      activeIcon: activeIcon,
      label: label,
    );
  }
}
