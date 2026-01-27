import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:limitim/core/theme/cubit/text_scale_cubit.dart';
import 'package:limitim/features/calendar/cubit/calendar_cubit.dart';
import 'package:limitim/features/calendar/screens/calendar_screen.dart';
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
  final List<Widget> pages = [
    const ExpenseScreen(),
    const CalendarScreen(),
    const HistoryScreen(),
  ];

  void _onItemTapped(int index) {
    // close drawer if open
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    if (_currentIndex == index) return; // prevent reloading the same page

    setState(() => _currentIndex = index);

    // refresh calendar data when navigating to calendar page
    if (index == 1) {
      _refreshCalendar(context);
    }

    // load history data when navigating to history page
    if (index == 2) {
      final historyState = context.read<HistoryBloc>().state;
      // Only fetch data if in initial state or error state
      if (historyState is HistoryLoading || historyState is HistoryError) {
        context.read<HistoryBloc>().add(LoadHistoryEvent());
      }
    }
  }

  final String _titleExpense = "Harcamalar";
  final String _titleHistory = "Geçmiş";
  final String _titleCalendar = "Takvim";
  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<SessionBloc, SessionState>(
          listener: (context, state) {
            _refreshCalendar(context);
            // if there is no active session (user has ended the month)
            if (state is NoActiveSession) {
              // load history page data
              context.read<HistoryBloc>().add(LoadHistoryEvent());
            }
          },
        ),

        BlocListener<HistoryBloc, HistoryState>(
          listener: (context, state) {
            _refreshCalendar(context);
          },
        ),
      ],
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: pages),
        bottomNavigationBar: BlocBuilder<TextScaleCubit, double>(
          builder: (context, textScale) {
            final iconSize = 24.0 * textScale;
            final labelFontSize = 12.0 * textScale;

            return BottomNavigationBar(
              backgroundColor:
                  Theme.of(context).navigationBarTheme.backgroundColor ??
                  Theme.of(context).colorScheme.surface,
              selectedItemColor: Theme.of(context).colorScheme.primary,
              selectedFontSize: labelFontSize,
              unselectedFontSize: labelFontSize,
              selectedIconTheme: IconThemeData(size: iconSize),
              unselectedIconTheme: IconThemeData(size: iconSize),
              currentIndex: _currentIndex,
              onTap: _onItemTapped,
              items: [
                _navBarItem(
                  icon: const Icon(Icons.home_outlined),
                  activeIcon: const Icon(Icons.home),
                  label: _titleExpense,
                ),
                _navBarItem(
                  icon: const Icon(Icons.calendar_month_outlined),
                  activeIcon: const Icon(Icons.calendar_month),
                  label: _titleCalendar,
                ),
                _navBarItem(
                  icon: const Icon(Icons.history_outlined),
                  activeIcon: const Icon(Icons.history),
                  label: _titleHistory,
                ),
              ],
            );
          },
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

  void _refreshCalendar(BuildContext context) {
    final calendarCubit = context.read<CalendarCubit>();
    final currentState = calendarCubit.state;

    if (currentState is CalendarLoaded) {
      // if already loaded, refresh the current month
      calendarCubit.loadMonth(currentState.focusedMonth);
    } else {
      // otherwise, load the current month
      calendarCubit.loadMonth(DateTime.now());
    }
  }
}
