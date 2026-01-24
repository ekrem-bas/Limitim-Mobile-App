import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:limitim/core/widgets/app_drawer.dart';
import 'package:limitim/features/calendar/cubit/calendar_cubit.dart';
import 'package:limitim/features/expense/widgets/expense_list_item.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  final String _appBarTitle = 'Takvim';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: Text(_appBarTitle)),
      body: BlocBuilder<CalendarCubit, CalendarState>(
        builder: (context, state) {
          if (state is CalendarInitial) {
            context.read<CalendarCubit>().loadMonth(DateTime.now());
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CalendarLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CalendarLoaded) {
            return Column(
              children: [
                // 1. calendar view
                _buildCalendar(context, state),
                const Divider(height: 1),
                // 2. list of expenses
                Expanded(child: _buildExpenseList(context, state)),
              ],
            );
          }

          if (state is CalendarError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildCalendar(BuildContext context, CalendarLoaded state) {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: state.focusedMonth,
      selectedDayPredicate: (day) => isSameDay(state.selectedDay, day),

      // dots for days with expenses
      eventLoader: (day) =>
          state.eventMarkers[DateTime(day.year, day.month, day.day)] ?? [],

      // on day selected
      onDaySelected: (selectedDay, focusedDay) {
        context.read<CalendarCubit>().toggleDaySelection(selectedDay);
      },

      // on month changed (fetch the data from repository)
      onPageChanged: (focusedDay) {
        context.read<CalendarCubit>().loadMonth(focusedDay);
      },
      locale: "tr_TR",
      startingDayOfWeek: StartingDayOfWeek.monday,

      // 1. style for days of week row (Pzt, Sal, Çar, etc.)
      daysOfWeekHeight: 25, // increased height slightly to prevent clipping
      daysOfWeekStyle: DaysOfWeekStyle(
        // weekday names (Mon-Fri)
        weekdayStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
        // Weekend names (Sat-Sun)
        weekendStyle: TextStyle(
          color: Theme.of(
            context,
          ).colorScheme.primary, // uses the primary color from the theme
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),

      // 2. style for calendar days
      calendarStyle: CalendarStyle(
        // weekday numbers color
        defaultTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        // weekend numbers color
        weekendTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
        // days outside current month color
        outsideTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
        ),
        // day of the month style
        todayDecoration: BoxDecoration(
          color: Color.fromRGBO(154, 185, 231, 1),
          shape: BoxShape.circle,
        ),
        // selected day style
        selectedDecoration: BoxDecoration(
          color: Color.fromRGBO(23, 90, 226, 1),
          shape: BoxShape.circle,
        ),
        // markers (dots) for days with expenses
        markersMaxCount: 1,
        markerSize: 8,
        markerDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error,
          shape: BoxShape.circle,
        ),
      ),
      // 3. header style (month and year)
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
    );
  }

  Widget _buildExpenseList(BuildContext context, CalendarLoaded state) {
    final expenses = state.visibleExpenses;
    final String noExpensesOnSelectedDay = "Bu günde harcama bulunmuyor";
    final String noExpensesInMonth = "Bu ayda harcama bulunmuyor";
    if (state.isEmptySelectedDay) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              noExpensesOnSelectedDay,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (state.allMonthExpenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              noExpensesInMonth,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        return ExpenseListItem(expense: expenses[index], isReadOnly: true);
      },
    );
  }
}
