import 'package:flutter/material.dart';
import '../../services/app_state.dart';
import '../../utils/app_theme.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/custom_text_field.dart';
import '../farmer/farmer_main_nav.dart';

class FarmerSignupScreen extends StatefulWidget {
  final AppState appState;

  const FarmerSignupScreen({super.key, required this.appState});

  @override
  State<FarmerSignupScreen> createState() => _FarmerSignupScreenState();
}

class _FarmerSignupScreenState extends State<FarmerSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: "Shweta Patil");
  final _phoneController = TextEditingController(text: "9876543210");
  final _passwordController = TextEditingController(text: "kisan123");
  final _confirmPasswordController = TextEditingController(text: "kisan123");
  final _villageController = TextEditingController(text: "Bhiwandi");
  final _talukaController = TextEditingController(text: "Bhiwandi");
  final _districtController = TextEditingController(text: "Thane");
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _villageController.dispose();
    _talukaController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match / पासवर्ड जुळत नाही"),
          backgroundColor: AppTheme.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final error = await widget.appState.signupFarmer(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
      village: _villageController.text.trim(),
      taluka: _talukaController.text.trim(),
      district: _districtController.text.trim(),
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
          builder: (context) => FarmerMainNav(appState: widget.appState),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: Text(widget.appState.tr('kisan_signup')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.appState.tr('kisan_signup'),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Join the transparent farmer marketplace / शेतकरी नोंदणी",
                  style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 24),

                // Full Name
                CustomTextField(
                  label: widget.appState.tr('full_name'),
                  hint: "e.g. Ramesh Patil",
                  controller: _nameController,
                  prefixIcon: Icons.person_outline,
                  validator: (val) => (val == null || val.trim().isEmpty) ? "Please enter full name" : null,
                ),
                const SizedBox(height: 16),

                // Phone
                CustomTextField(
                  label: widget.appState.tr('phone_number'),
                  hint: "10-digit mobile number",
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_android,
                  prefixText: "+91 ",
                  validator: (val) => (val == null || val.trim().length < 10) ? "Enter valid 10-digit mobile" : null,
                ),
                const SizedBox(height: 16),

                // Password
                CustomTextField(
                  label: widget.appState.tr('password'),
                  hint: "Create password (min 6 chars)",
                  controller: _passwordController,
                  isPassword: true,
                  prefixIcon: Icons.lock_outline,
                  validator: (val) => (val == null || val.length < 6) ? "Minimum 6 characters required" : null,
                ),
                const SizedBox(height: 16),

                // Confirm Password
                CustomTextField(
                  label: widget.appState.tr('confirm_password'),
                  hint: "Re-enter password",
                  controller: _confirmPasswordController,
                  isPassword: true,
                  prefixIcon: Icons.lock_reset_outlined,
                  validator: (val) => (val == null || val.isEmpty) ? "Confirm your password" : null,
                ),
                const SizedBox(height: 16),

                // Village
                CustomTextField(
                  label: widget.appState.tr('village'),
                  hint: "e.g. Bhiwandi / Manchar",
                  controller: _villageController,
                  prefixIcon: Icons.home_work_outlined,
                  validator: (val) => (val == null || val.trim().isEmpty) ? "Enter village name" : null,
                ),
                const SizedBox(height: 16),

                // Taluka & District Row
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: widget.appState.tr('taluka'),
                        hint: "e.g. Niphad",
                        controller: _talukaController,
                        prefixIcon: Icons.domain,
                        validator: (val) => (val == null || val.trim().isEmpty) ? "Required" : null,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: CustomTextField(
                        label: widget.appState.tr('district'),
                        hint: "e.g. Nashik / Thane",
                        controller: _districtController,
                        prefixIcon: Icons.location_city,
                        validator: (val) => (val == null || val.trim().isEmpty) ? "Required" : null,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Create Account Button
                PrimaryButton(
                  label: widget.appState.tr('create_account'),
                  isLoading: _isLoading,
                  icon: Icons.check_circle_outline,
                  onPressed: _handleSignup,
                ),

                const SizedBox(height: 18),

                // Already have account
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      widget.appState.tr('already_account'),
                      style: const TextStyle(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
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
