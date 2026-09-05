import 'package:flutter/material.dart';
import '../../services/app_state.dart';
import '../../utils/app_theme.dart';
import '../../widgets/primary_button.dart';
import '../landing/landing_screen.dart';

class LanguageScreen extends StatefulWidget {
  final AppState appState;

  const LanguageScreen({super.key, required this.appState});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  late String _selectedLang;

  @override
  void initState() {
    super.initState();
    _selectedLang = widget.appState.currentLanguage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Top Illustration Container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryGreen.withValues(alpha: 0.15),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text("🌾", style: TextStyle(fontSize: 44)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.appState.tr('app_name'),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        widget.appState.tr('tagline'),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Center: Choose Language
              Text(
                widget.appState.tr('choose_language'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Select your preferred language / भाषा निवडा",
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 18),
              // Language Option Buttons
              _buildLanguageTile(
                langCode: 'en',
                title: 'English',
                subtitle: 'India',
                flag: '🇮🇳',
              ),
              const SizedBox(height: 12),
              _buildLanguageTile(
                langCode: 'hi',
                title: 'हिन्दी',
                subtitle: 'Hindi',
                flag: '🇮🇳',
              ),
              const SizedBox(height: 12),
              _buildLanguageTile(
                langCode: 'mr',
                title: 'मराठी',
                subtitle: 'Marathi (महाराष्ट्र)',
                flag: '🚩',
              ),
              const SizedBox(height: 28),
              // Bottom: Continue Button
              PrimaryButton(
                label: widget.appState.tr('continue_btn'),
                onPressed: () {
                  widget.appState.setLanguage(_selectedLang);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LandingScreen(appState: widget.appState),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageTile({
    required String langCode,
    required String title,
    required String subtitle,
    required String flag,
  }) {
    final bool isSelected = _selectedLang == langCode;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedLang = langCode;
        });
        widget.appState.setLanguage(langCode);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryLight : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryGreen : AppTheme.borderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? AppTheme.primaryGreen : AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppTheme.primaryGreen, size: 24)
            else
              const Icon(Icons.radio_button_unchecked, color: AppTheme.borderColor, size: 24),
          ],
        ),
      ),
    );
  }
}
