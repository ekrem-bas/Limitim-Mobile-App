import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:limitim/core/splash/splash_screen.dart';
import 'package:limitim/core/theme/cubit/text_scale_cubit.dart';
import 'package:limitim/core/theme/cubit/theme_cubit.dart';
import 'package:limitim/features/calendar/cubit/calendar_cubit.dart';
import 'package:limitim/features/history/bloc/history_bloc.dart';
import 'package:limitim/features/expense/bloc/session_bloc.dart';
import 'package:limitim/core/theme/app_theme.dart';
import 'package:limitim/features/onboarding/cubit/onboarding_cubit.dart';
import 'package:limitim/repository/hive_repository.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // prevent landscape mode
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // HydratedBloc storage'ını ayarla
  final storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(
      (await getApplicationDocumentsDirectory()).path,
    ),
  );

  HydratedBloc.storage = storage;

  // turkish date formatting
  await initializeDateFormatting("tr_TR", null);

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
          BlocProvider(create: (context) => TextScaleCubit()),
          BlocProvider(create: (context) => OnboardingCubit()),
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
    return BlocBuilder<TextScaleCubit, double>(
      builder: (context, textScale) {
        return BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, mode) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Limitim',
              theme: AppTheme.lightTheme(textScale),
              darkTheme: AppTheme.darkTheme(textScale),
              themeMode: mode,
              home: const SplashScreen(),
            );
          },
        );
      },
    );
  }
}
