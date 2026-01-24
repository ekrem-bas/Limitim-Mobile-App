import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:limitim/core/theme/cubit/theme_cubit.dart';
import 'package:limitim/features/calendar/cubit/calendar_cubit.dart';
import 'package:limitim/features/expense/models/expense.dart';
import 'package:limitim/features/history/bloc/history_bloc.dart';
import 'package:limitim/features/expense/bloc/session_bloc.dart';
import 'package:limitim/features/history/models/month.dart';
import 'package:limitim/core/root_page.dart';
import 'package:limitim/core/theme/app_theme.dart';
import 'package:limitim/repository/hive_repository.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // for hydrated_bloc set the storage directory
  final storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(
      (await getApplicationDocumentsDirectory()).path,
    ),
  );

  HydratedBloc.storage = storage;

  await initializeDateFormatting("tr_TR", null);

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
          BlocProvider(
            create: (context) => CalendarCubit(context.read<HiveRepository>()),
          ),

          BlocProvider(create: (context) => ThemeCubit()),
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
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, mode) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Limitim',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: mode,
          home: const RootPage(),
        );
      },
    );
  }
}
