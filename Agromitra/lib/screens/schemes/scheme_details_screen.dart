import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/scheme.dart';
import '../../services/app_state.dart';
import '../../utils/app_theme.dart';
import '../../widgets/primary_button.dart';

class SchemeDetailsScreen extends StatelessWidget {
  final GovernmentScheme scheme;
  final AppState appState;

  const SchemeDetailsScreen({
    super.key,
    required this.scheme,
    required this.appState,
  });

  Future<void> _openOfficialWebsite(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(appState.tr('redirecting_notice')),
        backgroundColor: AppTheme.primaryGreen,
        duration: const Duration(seconds: 2),
      ),
    );

    final Uri uri = Uri.parse(scheme.officialUrl);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Could not open ${scheme.officialUrl}"),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Redirecting to: ${scheme.officialUrl}"),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: Text(scheme.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22.0),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryGreen, Color(0xFF1B5E20)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          scheme.category.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Text("🇮🇳", style: TextStyle(fontSize: 22)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    scheme.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    scheme.ministry,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Overview Section
            _buildSectionCard(
              title: "Overview",
              icon: Icons.info_outline,
              child: Text(
                scheme.overview,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Benefits Section
            _buildSectionCard(
              title: appState.tr('scheme_benefits'),
              icon: Icons.star_outline_rounded,
              iconColor: AppTheme.accentYellow,
              child: Column(
                children: scheme.benefits
                    .map((b) => _buildCheckItem(b, Icons.check_circle_outline, AppTheme.primaryGreen))
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Eligibility Section
            _buildSectionCard(
              title: appState.tr('scheme_eligibility'),
              icon: Icons.verified_user_outlined,
              child: Column(
                children: scheme.eligibility
                    .map((e) => _buildCheckItem(e, Icons.arrow_right_alt, AppTheme.textSecondary))
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Required Documents
            _buildSectionCard(
              title: appState.tr('scheme_documents'),
              icon: Icons.description_outlined,
              child: Column(
                children: scheme.requiredDocuments
                    .map((doc) => _buildCheckItem(doc, Icons.article_outlined, AppTheme.primaryGreen))
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Application Process
            _buildSectionCard(
              title: appState.tr('scheme_process'),
              icon: Icons.how_to_reg_outlined,
              child: Text(
                scheme.applicationProcess,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textPrimary,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Important Dates & Timelines
            _buildSectionCard(
              title: "Timeline & Important Dates",
              icon: Icons.calendar_month_outlined,
              child: Text(
                scheme.importantDates,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Official Website Link Button
            PrimaryButton(
              label: appState.tr('apply_official_website'),
              icon: Icons.open_in_browser,
              onPressed: () => _openOfficialWebsite(context),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                scheme.officialUrl,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textMuted,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
    Color iconColor = AppTheme.primaryGreen,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: AppTheme.borderColor),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textPrimary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
