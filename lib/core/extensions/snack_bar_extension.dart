import 'package:flutter/material.dart';

extension SnackBarExtension on BuildContext {
  void showImmediateSnackBar(SnackBar snackBar) {
    ScaffoldMessenger.of(this).removeCurrentSnackBar();
    ScaffoldMessenger.of(this).showSnackBar(snackBar);
  }
}
