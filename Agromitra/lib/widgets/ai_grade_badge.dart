import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../models/listing.dart';

class AIGradeBadge extends StatelessWidget {
  final String grade;
  final bool showIcon;
  final double fontSize;

  const AIGradeBadge({
    super.key,
    required this.grade,
    this.showIcon = true,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label = grade.toUpperCase();

    if (label.contains('A')) {
      bg = const Color(0xFFE8F5E9);
      fg = AppTheme.gradeA;
    } else if (label.contains('B')) {
      bg = const Color(0xFFFFF3E0);
      fg = AppTheme.gradeB;
    } else {
      bg = const Color(0xFFFFEBEE);
      fg = AppTheme.gradeC;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(Icons.auto_awesome, size: fontSize + 2, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            grade,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final ListingStatus status;

  const StatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = status == ListingStatus.active;
    final Color bg = isActive ? const Color(0xFFE8F5E9) : const Color(0xFFEEEEEE);
    final Color fg = isActive ? AppTheme.primaryGreen : AppTheme.textMuted;
    final String label = isActive ? "ACTIVE" : "SOLD";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: fg,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.bold,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
