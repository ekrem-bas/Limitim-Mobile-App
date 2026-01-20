import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:limitim/bloc/history_bloc/history_bloc.dart';
import 'package:limitim/bloc/session_bloc/active_session_bloc.dart';
import 'package:limitim/screens/history_page.dart';
import 'package:limitim/screens/expense_page.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int _currentIndex = 0;

  // list of pages
  final List<Widget> pages = [const ExpensePage(), const HistoryPage()];

  void _onItemTapped(int index) {
    if (_currentIndex == index) return; // Zaten o sekmedeyse hiçbir şey yapma

    setState(() => _currentIndex = index);

    if (index == 1) {
      final historyState = context.read<HistoryBloc>().state;
      // Sadece başlangıç durumunda veya hata almışsa veriyi çek
      if (historyState is HistoryLoading || historyState is HistoryError) {
        context.read<HistoryBloc>().add(LoadHistoryEvent());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ActiveSessionBloc, ActiveSessionState>(
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
              label: 'Harcamalar',
            ),
            _navBarItem(
              icon: const Icon(Icons.history_outlined),
              activeIcon: const Icon(Icons.history),
              label: 'Geçmiş',
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
