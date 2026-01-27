import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:limitim/core/theme/cubit/theme_cubit.dart';
import 'package:limitim/features/calendar/cubit/calendar_cubit.dart';
import 'package:limitim/features/expense/bloc/session_bloc.dart';
import 'package:limitim/features/history/bloc/history_bloc.dart';
import 'package:limitim/repository/hive_repository.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  final String _drawerTitle = "Limitim Ayarlar";
  final String _themeSelectionTitle = "Görünüm Ayarları";
  final String _lightModeText = "Açık Mod";
  final String _darkModeText = "Koyu Mod";
  final String _systemModeText = "Sistem Ayarı";
  final String _clearDataText = "Tüm Verileri Temizle";
  final String _confirmationTitle = "Emin misiniz?";
  final String _warningText =
      "Bu işlem tüm verilerinizi kalıcı olarak silecektir. Bu işlemi geri alamazsınız.";
  final String _snackbarText = "Tüm veriler temizlendi";
  final String _deleteAllText = "Hepsini Sil";
  final String _cancelText = "Vazgeç";

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. drawer header
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            child: Center(
              child: Text(
                _drawerTitle,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // 2. theme selection section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _themeSelectionTitle,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          // 3. radio buttons for theme selection
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, currentMode) {
              return RadioGroup<ThemeMode>(
                groupValue: currentMode,
                onChanged: (mode) {
                  if (mode != null) {
                    context.read<ThemeCubit>().updateTheme(mode);
                  }
                },
                child: Column(
                  children: [
                    // radio buttons
                    RadioListTile<ThemeMode>(
                      title: Text(_lightModeText),
                      value: ThemeMode.light,
                    ),
                    RadioListTile<ThemeMode>(
                      title: Text(_darkModeText),
                      value: ThemeMode.dark,
                    ),
                    RadioListTile<ThemeMode>(
                      title: Text(_systemModeText),
                      value: ThemeMode.system,
                    ),
                  ],
                ),
              );
            },
          ),

          const Spacer(),
          // 4. clear data button
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: Text(
              _clearDataText,
              style: const TextStyle(color: Colors.red),
            ),
            onTap: () => _showClearDataDialog(context),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // dialog for confirming data deletion
  Future<void> _showClearDataDialog(BuildContext context) async {
    // 1. show confirmation dialog
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_confirmationTitle),
        content: Text(_warningText),
        actions: [
          // cancel button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surface,
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(context, false), // returns false
            child: Text(
              _cancelText,
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          // confirm button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(context, true), // returns true
            child: Text(
              _deleteAllText,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    // 2. if confirmed, proceed to delete data
    if (shouldDelete == true && context.mounted) {
      // close the drawer
      Navigator.pop(context);

      // clear all data from repository
      await context.read<HiveRepository>().clearAllData();

      // reset blocs and cubits to initial states
      if (context.mounted) {
        context.read<HistoryBloc>().add(LoadHistoryEvent());
        context.read<SessionBloc>().add(ResetSessionEvent());
        context.read<CalendarCubit>().loadMonth(DateTime.now());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_snackbarText),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
