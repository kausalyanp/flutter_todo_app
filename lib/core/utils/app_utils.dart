import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppUtils {
  AppUtils._();

  static String formatDate(int? milliseconds) {
    if (milliseconds == null) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(milliseconds);
    return DateFormat('MMM d, yyyy • h:mm a').format(date);
  }

  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? const Color(0xFFE53935)
            : const Color(0xFF4CAF50),
        duration: duration,
      ),
    );
  }

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1024;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  static double contentMaxWidth(BuildContext context) {
    if (isDesktop(context)) return 720;
    if (isTablet(context)) return 560;
    return double.infinity;
  }
}