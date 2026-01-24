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
  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_confirmationTitle),
        content: Text(_warningText),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surface,
              elevation: 0,
            ),
            onPressed: () async {
              // 1. clear all data from Hive storage
              await context.read<HiveRepository>().clearAllData();

              if (context.mounted) {
                // 2. send "refresh" command to all Blocs (clearing RAM data)
                context.read<HistoryBloc>().add(LoadHistoryEvent());
                context.read<SessionBloc>().add(ResetSessionEvent());

                // 3. refresh calendar data
                context.read<CalendarCubit>().loadMonth(DateTime.now());

                Navigator.pop(context);
              }
            },
            child: Text(
              "Vazgeç",
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await context.read<HiveRepository>().clearAllData(); // Veriyi sil
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(_snackbarText)));
              }
            },
            child: Text(
              _deleteAllText,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
