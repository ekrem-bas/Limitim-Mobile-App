import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:limitim/core/root_page.dart';
import 'package:limitim/features/onboarding/cubit/onboarding_cubit.dart';
import 'package:limitim/features/onboarding/screens/onboarding_screen.dart';

/// Wrapper widget that decides whether to show onboarding or main app
class OnboardingWrapper extends StatelessWidget {
  const OnboardingWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingCubit, bool>(
      builder: (context, hasCompletedOnboarding) {
        if (hasCompletedOnboarding) {
          return const RootPage();
        } else {
          return const OnboardingScreen();
        }
      },
    );
  }
}
