import 'package:flutter/material.dart';
import '../../services/app_state.dart';
import '../../utils/app_theme.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/custom_text_field.dart';
import '../buyer/buyer_main_nav.dart';
import 'buyer_signup_screen.dart';
import 'forgot_password_dialog.dart';

class BuyerLoginScreen extends StatefulWidget {
  final AppState appState;

  const BuyerLoginScreen({super.key, required this.appState});

  @override
  State<BuyerLoginScreen> createState() => _BuyerLoginScreenState();
}

class _BuyerLoginScreenState extends State<BuyerLoginScreen> {
  final _phoneController = TextEditingController(text: "9820098200");
  final _passwordController = TextEditingController(text: "buyer123");
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final error = await widget.appState.loginBuyer(
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
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
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => BuyerMainNav(appState: widget.appState),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color buyerColor = Color(0xFF1E88E5);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: Text(widget.appState.tr('buyer_login')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Center(
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: buyerColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: const Text("🏬", style: TextStyle(fontSize: 36)),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    widget.appState.tr('buyer_login'),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    widget.appState.tr('buyer_hero_subtitle'),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Phone Input
                CustomTextField(
                  label: widget.appState.tr('phone_number'),
                  hint: "Enter 10-digit mobile number",
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_android,
                  prefixText: "+91 ",
                  validator: (val) {
                    if (val == null || val.trim().length < 10) {
                      return "Please enter a valid 10-digit mobile number";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // Password Input
                CustomTextField(
                  label: widget.appState.tr('password'),
                  hint: "Enter password",
                  controller: _passwordController,
                  isPassword: true,
                  prefixIcon: Icons.lock_outline,
                  validator: (val) {
                    if (val == null || val.length < 6) {
                      return "Password must be at least 6 characters";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 8),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => ForgotPasswordDialog(appState: widget.appState),
                      );
                    },
                    child: Text(
                      widget.appState.tr('forgot_password'),
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Login Button
                PrimaryButton(
                  label: widget.appState.tr('login_btn'),
                  isLoading: _isLoading,
                  backgroundColor: buyerColor,
                  icon: Icons.login,
                  onPressed: _handleLogin,
                ),

                const SizedBox(height: 24),

                // Create Account Option
                Center(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BuyerSignupScreen(appState: widget.appState),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: buyerColor,
                      side: const BorderSide(color: buyerColor, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                    child: Text(
                      widget.appState.tr('new_buyer'),
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
