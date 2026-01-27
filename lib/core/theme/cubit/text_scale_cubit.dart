import 'package:hydrated_bloc/hydrated_bloc.dart';

/// Manages the text scale factor for the app with persistence
/// Allows users to adjust text size for better accessibility
/// Scale range: 0.8x - 1.5x (default: 1.0x)
class TextScaleCubit extends HydratedCubit<double> {
  TextScaleCubit() : super(1.0);

  /// Updates the text scale factor
  /// [scale] must be between 0.8 and 1.5
  void updateScale(double scale) {
    if (scale >= 0.8 && scale <= 1.5) {
      emit(scale);
    }
  }

  @override
  Map<String, dynamic>? toJson(double state) => {'scale': state};

  @override
  double? fromJson(Map<String, dynamic> json) {
    final scale = json['scale'] as double?;
    // Ensure the loaded value is within valid range
    if (scale != null && scale >= 0.8 && scale <= 1.5) {
      return scale;
    }
    return 1.0; // Default fallback
  }
}
