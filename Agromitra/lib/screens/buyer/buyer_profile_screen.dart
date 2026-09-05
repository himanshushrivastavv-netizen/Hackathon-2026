import 'package:flutter/material.dart';
import '../../services/app_state.dart';
import '../../utils/app_theme.dart';
import '../../widgets/primary_button.dart';
import '../landing/landing_screen.dart';

class BuyerProfileScreen extends StatelessWidget {
  final AppState appState;

  const BuyerProfileScreen({super.key, required this.appState});

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Confirm Logout"),
        content: const Text("Do you want to log out of AgroMitra Buyer Portal?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              appState.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => LandingScreen(appState: appState),
                ),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _handleDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.errorRed.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_amber_rounded, color: AppTheme.errorRed, size: 24),
            ),
            const SizedBox(width: 10),
            const Text("Delete Account?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "This action is permanent.",
              style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.errorRed, fontSize: 13),
            ),
            SizedBox(height: 8),
            Text(
              "Your buyer profile and data will be permanently deleted from Supabase. You can register again anytime with this phone number.",
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await appState.deleteAccount();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LandingScreen(appState: appState),
                  ),
                  (route) => false,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Account and data deleted. You can register again with this phone number."),
                    backgroundColor: AppTheme.primaryDark,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            child: const Text("Permanently Delete", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = appState.currentUser;
    const Color buyerColor = Color(0xFF1E88E5);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: Text(appState.tr('buyer_profile_title')),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: buyerColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(color: buyerColor, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: const Text("🏬", style: TextStyle(fontSize: 40)),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    user?.name ?? "Amit Gupta",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: buyerColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "PRODUCE BUYER / VYAPARI",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: buyerColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.phone ?? "+91 98200 98200",
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${user?.village}, ${user?.district}",
                    style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Settings Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.language, color: buyerColor),
                    title: const Text("Language / भाषा", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    trailing: DropdownButton<String>(
                      value: appState.currentLanguage,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: 'en', child: Text("English 🇮🇳")),
                        DropdownMenuItem(value: 'hi', child: Text("हिन्दी")),
                        DropdownMenuItem(value: 'mr', child: Text("मराठी")),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          appState.setLanguage(val);
                        }
                      },
                    ),
                  ),
                  const Divider(height: 1, color: AppTheme.borderColor),
                  ListTile(
                    leading: const Icon(Icons.verified_user_outlined, color: buyerColor),
                    title: const Text("Buyer Status", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    trailing: const Text(
                      "Verified Direct Buyer",
                      style: TextStyle(fontSize: 12, color: AppTheme.primaryGreen, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            SecondaryButton(
              label: appState.tr('logout'),
              textColor: AppTheme.textPrimary,
              borderColor: AppTheme.borderColor,
              icon: Icons.logout,
              onPressed: () => _handleLogout(context),
            ),
            const SizedBox(height: 16),

            // Delete Account Button
            OutlinedButton.icon(
              onPressed: () => _handleDeleteAccount(context),
              icon: const Icon(Icons.delete_forever, color: AppTheme.errorRed, size: 20),
              label: const Text(
                "Delete Account & Data",
                style: TextStyle(color: AppTheme.errorRed, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppTheme.errorRed.withValues(alpha: 0.5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
