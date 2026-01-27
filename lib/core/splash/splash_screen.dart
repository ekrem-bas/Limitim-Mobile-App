import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../features/expense/models/expense.dart';
import '../../features/history/models/month.dart';
import '../../features/onboarding/cubit/onboarding_cubit.dart';
import '../../features/onboarding/screens/onboarding_wrapper.dart';

/// When the app starts, this splash screen is shown first.
///
/// It performs the following tasks:
/// - Initializes the Hive database
/// - Sets up HydratedBloc storage
/// - Waits at least 2 seconds on the first launch
/// - Shows during initialization on subsequent launches
/// - Responsive to Dark/Light mode
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// Initializes the app and then navigates to the main screen.
  Future<void> _initializeApp() async {
    // Access OnboardingCubit to check if it's the first launch
    final onboardingCubit = context.read<OnboardingCubit>();
    final isFirstLaunch = !onboardingCubit.state;

    // Record the start time
    final startTime = DateTime.now();

    try {
      // Hive initialization
      await Hive.initFlutter();

      // Hive adapters
      Hive.registerAdapter(MonthAdapter());
      Hive.registerAdapter(ExpenseAdapter());

      // Hive boxes
      await Hive.openBox<Month>('months');
      await Hive.openBox<Expense>('expenses');

      // set minimum display time for splash screen
      final elapsed = DateTime.now().difference(startTime);
      final minimumDuration = isFirstLaunch
          ? const Duration(seconds: 2) // first launch: 2 seconds
          : const Duration(seconds: 1); // Normal launch: 1 second

      final remainingTime = minimumDuration - elapsed;

      if (remainingTime.isNegative == false) {
        await Future.delayed(remainingTime);
      }

      // Navigation
      if (mounted) {
        // OnboardingWrapper already checks OnboardingCubit
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OnboardingWrapper()),
        );
      }
    } catch (e) {
      // Continue even if there's an error, but show it to the user
      debugPrint('Initialization error: $e');

      if (mounted) {
        // Continue even if there's an error
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OnboardingWrapper()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine if dark mode is enabled
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Icon/Logo
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'assets/icon.png',
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 16),

            // App Name
            Text(
              'Limitim',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),

            const SizedBox(height: 8),

            // Subtitle
            Text(
              'Bütçenizi Yönetin',
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),

            const SizedBox(height: 48),

            // Loading Indicator
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDarkMode
                      ? const Color(0xFF66BB6A)
                      : const Color(0xFF2E7D32),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
