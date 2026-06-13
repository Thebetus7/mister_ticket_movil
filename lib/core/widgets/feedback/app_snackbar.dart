import 'package:flutter/material.dart';

/// SnackBar personalizado con variantes: success, error, info, warning.
/// Usar SIEMPRE en vez de ScaffoldMessenger directamente.
class AppSnackbar {
  static void success(BuildContext context, String message) {
    _show(context, message, Colors.green, Icons.check_circle);
  }

  static void error(BuildContext context, String message) {
    _show(context, message, Colors.red, Icons.error);
  }

  static void info(BuildContext context, String message) {
    _show(context, message, Colors.blue, Icons.info);
  }

  static void warning(BuildContext context, String message) {
    _show(context, message, Colors.orange, Icons.warning);
  }

  static void _show(
      BuildContext context, String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
