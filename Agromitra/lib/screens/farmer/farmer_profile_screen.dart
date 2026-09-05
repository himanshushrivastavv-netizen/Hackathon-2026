import 'package:flutter/material.dart';
import '../../services/app_state.dart';
import '../../utils/app_theme.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';
import '../landing/landing_screen.dart';

class FarmerProfileScreen extends StatefulWidget {
  final AppState appState;

  const FarmerProfileScreen({super.key, required this.appState});

  @override
  State<FarmerProfileScreen> createState() => _FarmerProfileScreenState();
}

class _FarmerProfileScreenState extends State<FarmerProfileScreen> {
  void _showEditProfileDialog() {
    final user = widget.appState.currentUser;
    final nameCtrl = TextEditingController(text: user?.name ?? "");
    final phoneCtrl = TextEditingController(text: user?.phone ?? "");
    final villageCtrl = TextEditingController(text: user?.village ?? "");
    final talukaCtrl = TextEditingController(text: user?.taluka ?? "");
    final districtCtrl = TextEditingController(text: user?.district ?? "");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(widget.appState.tr('edit_profile')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(label: widget.appState.tr('full_name'), controller: nameCtrl),
                const SizedBox(height: 12),
                CustomTextField(label: widget.appState.tr('phone_number'), controller: phoneCtrl),
                const SizedBox(height: 12),
                CustomTextField(label: widget.appState.tr('village'), controller: villageCtrl),
                const SizedBox(height: 12),
                CustomTextField(label: widget.appState.tr('taluka'), controller: talukaCtrl),
                const SizedBox(height: 12),
                CustomTextField(label: widget.appState.tr('district'), controller: districtCtrl),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                widget.appState.updateProfile(
                  name: nameCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                  village: villageCtrl.text.trim(),
                  taluka: talukaCtrl.text.trim(),
                  district: districtCtrl.text.trim(),
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Profile details updated successfully")),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
              child: const Text("Save Changes", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to log out of AgroMitra?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.appState.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => LandingScreen(appState: widget.appState),
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

  void _handleDeleteAccount() {
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
              "This action is permanent and cannot be undone.",
              style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.errorRed, fontSize: 13),
            ),
            SizedBox(height: 8),
            Text(
              "All your produce listings, profile details, and account data will be permanently removed from Supabase and AgroMitra. You can use your phone number again immediately to create a fresh new account.",
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
              final nav = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              nav.pop();
              await widget.appState.deleteAccount();
              if (mounted) {
                nav.pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => LandingScreen(appState: widget.appState),
                  ),
                  (route) => false,
                );
                messenger.showSnackBar(
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
    final user = widget.appState.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: Text(widget.appState.tr('profile_title')),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Farmer Avatar Header
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
                      color: AppTheme.primaryLight,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primaryGreen, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: const Text("👨‍🌾", style: TextStyle(fontSize: 40)),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    user?.name ?? "Shweta Patil",
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
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "VERIFIED KISAN",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.phone ?? "+91 98765 43210",
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${user?.village}, ${user?.taluka} (${user?.district})",
                    style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Profile Settings Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Column(
                children: [
                  // Contact Toggle
                  SwitchListTile(
                    value: user?.contactEnabled ?? true,
                    activeThumbColor: AppTheme.primaryGreen,
                    title: Text(
                      widget.appState.tr('allow_calls'),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text(
                      "Buyers can tap to call your phone number",
                      style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                    onChanged: (val) {
                      widget.appState.updateProfile(contactEnabled: val);
                    },
                  ),
                  const Divider(height: 1, color: AppTheme.borderColor),

                  // Language Option
                  ListTile(
                    leading: const Icon(Icons.language, color: AppTheme.primaryGreen),
                    title: const Text("App Language / भाषा", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    trailing: DropdownButton<String>(
                      value: widget.appState.currentLanguage,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: 'en', child: Text("English 🇮🇳")),
                        DropdownMenuItem(value: 'hi', child: Text("हिन्दी")),
                        DropdownMenuItem(value: 'mr', child: Text("मराठी")),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          widget.appState.setLanguage(val);
                        }
                      },
                    ),
                  ),
                  const Divider(height: 1, color: AppTheme.borderColor),

                  // Edit Profile
                  ListTile(
                    leading: const Icon(Icons.edit_outlined, color: AppTheme.primaryGreen),
                    title: Text(widget.appState.tr('edit_profile'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textMuted),
                    onTap: _showEditProfileDialog,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logout Button
            SecondaryButton(
              label: widget.appState.tr('logout'),
              textColor: AppTheme.textPrimary,
              borderColor: AppTheme.borderColor,
              icon: Icons.logout,
              onPressed: _handleLogout,
            ),
            const SizedBox(height: 16),

            // Delete Account & Data Button
            OutlinedButton.icon(
              onPressed: _handleDeleteAccount,
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
