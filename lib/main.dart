import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:limitim/bloc/history_bloc/history_bloc.dart';
import 'package:limitim/bloc/session_bloc/active_session_bloc.dart';
import 'package:limitim/models/expense.dart';
import 'package:limitim/models/month.dart';
import 'package:limitim/repository/expense_repository.dart';
import 'package:limitim/screens/root_page.dart';
import 'package:limitim/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(MonthAdapter());
  Hive.registerAdapter(ExpenseAdapter());

  await Hive.openBox<Month>("months");
  await Hive.openBox<Expense>("expenses");

  runApp(
    RepositoryProvider(
      create: (context) => ExpenseRepository(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => ActiveSessionBloc(
              repository: context.read<ExpenseRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) =>
                HistoryBloc(repository: context.read<ExpenseRepository>()),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Limitim',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const RootPage(),
    );
  }
}
