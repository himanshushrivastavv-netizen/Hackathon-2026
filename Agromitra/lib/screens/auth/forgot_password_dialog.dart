import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../services/app_state.dart';

class ForgotPasswordDialog extends StatelessWidget {
  final AppState appState;

  const ForgotPasswordDialog({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.accentLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.info_outline, color: AppTheme.accentYellow, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              appState.tr('forgot_password'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: Text(
        appState.tr('forgot_password_demo'),
        style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.4),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: const Text("Understood / ठीक आहे"),
        ),
      ],
    );
  }
}
