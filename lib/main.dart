import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:limitim/features/expense/models/expense.dart';
import 'package:limitim/features/history/bloc/history_bloc.dart';
import 'package:limitim/features/expense/bloc/session_bloc.dart';
import 'package:limitim/features/history/models/month.dart';
import 'package:limitim/core/root_page.dart';
import 'package:limitim/core/theme/app_theme.dart';
import 'package:limitim/repository/hive_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(MonthAdapter());
  Hive.registerAdapter(ExpenseAdapter());

  await Hive.openBox<Month>("months");
  await Hive.openBox<Expense>("expenses");

  runApp(
    RepositoryProvider(
      create: (context) => HiveRepository(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                SessionBloc(repository: context.read<HiveRepository>()),
          ),
          BlocProvider(
            create: (context) =>
                HistoryBloc(repository: context.read<HiveRepository>()),
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
