// features/settings/cubit/theme_cubit.dart
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

// hydrated bloc because we want to persist the theme selection across app restarts
// it saves the state to disk and retrieves it when the app is restarted
class ThemeCubit extends HydratedCubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system);

  void updateTheme(ThemeMode mode) => emit(mode);

  // 1. save cubit state to disk
  @override
  Map<String, dynamic>? toJson(ThemeMode state) => {'theme': state.index};

  // 2. convert data read from disk to Cubit state
  @override
  ThemeMode? fromJson(Map<String, dynamic> json) =>
      ThemeMode.values[json['theme'] as int];
}
