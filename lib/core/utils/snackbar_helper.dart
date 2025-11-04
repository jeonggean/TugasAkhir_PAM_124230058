import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum SnackBarType { success, error, info }

class SnackBarHelper {
  static void show(BuildContext context, String message,
      {SnackBarType type = SnackBarType.info, int duration = 3}) {
    final Color bgColor;
    final IconData icon;

    switch (type) {
      case SnackBarType.success:
        bgColor = Colors.green.shade600;
        icon = Icons.check_circle_outline;
        break;
      case SnackBarType.error:
        bgColor = Colors.redAccent.shade200;
        icon = Icons.error_outline;
        break;
      default:
        bgColor = Colors.blueAccent.shade400;
        icon = Icons.info_outline;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: Duration(seconds: duration),
      ),
    );
  }
}
