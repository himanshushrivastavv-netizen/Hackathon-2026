import 'package:flutter/material.dart';
import '../../services/app_state.dart';
import '../../utils/app_theme.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';
import 'admin_dashboard_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  final AppState appState;

  const AdminLoginScreen({super.key, required this.appState});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _phoneController = TextEditingController(text: "9999999999");
  final _passController = TextEditingController(text: "admin123");
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final error = await widget.appState.loginAdmin(
      phone: _phoneController.text.trim(),
      password: _passController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(error, style: const TextStyle(fontWeight: FontWeight.w500))),
            ],
          ),
          backgroundColor: AppTheme.errorRed,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AdminDashboardScreen(appState: widget.appState),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: Text(widget.appState.tr('admin_login')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xFF37474F).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.admin_panel_settings, size: 40, color: Color(0xFF37474F)),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    widget.appState.tr('admin_login'),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 4),
                const Center(
                  child: Text(
                    "AgroMitra Administrator & Moderation Console",
                    style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                  ),
                ),
                const SizedBox(height: 32),

                CustomTextField(
                  label: "Admin Phone / ID",
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.admin_panel_settings_outlined,
                  validator: (val) => (val == null || val.trim().isEmpty) ? "Required" : null,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: "Admin Password / Secret Key",
                  hint: "Default: admin123",
                  controller: _passController,
                  isPassword: true,
                  prefixIcon: Icons.key_outlined,
                  validator: (val) => (val == null || val.trim().isEmpty) ? "Required" : null,
                ),
                const SizedBox(height: 24),

                PrimaryButton(
                  label: "Access Admin Console",
                  isLoading: _isLoading,
                  backgroundColor: const Color(0xFF37474F),
                  onPressed: _handleLogin,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
