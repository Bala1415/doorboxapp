import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? valueColor;
  final Widget? customContent;

  const StatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.valueColor,
    this.customContent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.softShadowDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.textPrimary, size: 24),
          const Spacer(),
          if (customContent != null) customContent!,
          if (customContent == null) ...[
            Text(
              title,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: valueColor ?? AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}
