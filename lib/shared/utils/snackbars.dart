import 'package:flutter/material.dart';

void showSnackBar(
  BuildContext context, {
  required Widget content,
  Duration duration = const Duration(seconds: 4),
  SnackBarAction? action,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      content: content,
      duration: duration,
      action: action,
    ),
  );
}
