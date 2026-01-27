import 'package:hydrated_bloc/hydrated_bloc.dart';

/// Manages onboarding completion state with persistence
/// Tracks whether the user has completed the onboarding screens
class OnboardingCubit extends HydratedCubit<bool> {
  OnboardingCubit() : super(false);

  /// Marks onboarding as completed
  void completeOnboarding() => emit(true);

  /// Resets onboarding state (useful for testing or user preference)
  void resetOnboarding() => emit(false);

  @override
  Map<String, dynamic>? toJson(bool state) => {'completed': state};

  @override
  bool? fromJson(Map<String, dynamic> json) => json['completed'] as bool?;
}
