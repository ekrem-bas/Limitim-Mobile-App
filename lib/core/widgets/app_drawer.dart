import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:limitim/core/theme/cubit/theme_cubit.dart';
import 'package:limitim/features/calendar/cubit/calendar_cubit.dart';
import 'package:limitim/features/expense/bloc/session_bloc.dart';
import 'package:limitim/features/history/bloc/history_bloc.dart';
import 'package:limitim/repository/hive_repository.dart';

// DrawerView enum to manage different views in the drawer
enum DrawerView { main, theme }

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  // On start, show main view
  DrawerView _currentView = DrawerView.main;

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
      // AnimatedSwitcher to switch between main view and theme view
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _currentView == DrawerView.main
            ? _buildMainView(context)
            : _buildThemeView(context),
      ),
    );
  }

  // --- 1. MAIN VIEW ---
  Widget _buildMainView(BuildContext context) {
    return Column(
      key: const ValueKey("MainView"),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Drawer Header
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

        // Theme Selection ListTile
        ListTile(
          leading: const Icon(Icons.palette_outlined),
          title: Text(_themeSelectionTitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            setState(() => _currentView = DrawerView.theme);
          },
        ),

        const Spacer(),
        const Divider(),

        // Clear Data button
        ListTile(
          leading: const Icon(Icons.delete_forever, color: Colors.red),
          title: Text(
            _clearDataText,
            style: const TextStyle(color: Colors.red),
          ),
          onTap: () => _handleClearData(context),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // --- 2. THEME VIEW ---
  Widget _buildThemeView(BuildContext context) {
    return Column(
      key: const ValueKey("ThemeView"),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back Header
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 8, left: 8, bottom: 4),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () =>
                      setState(() => _currentView = DrawerView.main),
                ),
                Text(
                  _themeSelectionTitle,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(),

        // Theme Options
        BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, currentMode) {
            return RadioGroup(
              groupValue: currentMode,
              onChanged: (mode) {
                if (mode != null) {
                  context.read<ThemeCubit>().updateTheme(mode);
                }
              },
              child: Column(
                children: [
                  _buildThemeOption(_lightModeText, ThemeMode.light),
                  _buildThemeOption(_darkModeText, ThemeMode.dark),
                  _buildThemeOption(_systemModeText, ThemeMode.system),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // Common widget for theme options
  Widget _buildThemeOption(String title, ThemeMode value) {
    return RadioListTile<ThemeMode>(title: Text(title), value: value);
  }

  Future<void> _handleClearData(BuildContext context) async {
    // 1. show confirmation dialog and wait for user response
    final bool? shouldDelete = await showDialog<bool>(
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
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              _cancelText,
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              _deleteAllText,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    // 2. if user confirmed, proceed to clear data
    if (shouldDelete == true && context.mounted) {
      // close the drawer
      Navigator.pop(context);

      // clear the database
      await context.read<HiveRepository>().clearAllData();

      // notify blocs about data clearance
      if (context.mounted) {
        context.read<HistoryBloc>().add(LoadHistoryEvent());
        context.read<SessionBloc>().add(ResetSessionEvent());
        context.read<CalendarCubit>().loadMonth(DateTime.now());

        // show information message
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
