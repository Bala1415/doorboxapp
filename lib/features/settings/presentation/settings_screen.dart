import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/mock_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_toggle.dart';
import '../../../../core/widgets/primary_button.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final deviceState = ref.watch(deviceStatusProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => context.go('/home'),
        ),
        title: const Text('DoorBox Device Settings'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Security Controls', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildSettingRow(
              context,
              title: 'Alarm',
              description: 'Triggers a loud siren when unauthorized access is detected.',
              value: settings.alarmEnabled,
              onChanged: (val) {
                ref.read(settingsProvider.notifier).state = settings.copyWith(alarmEnabled: val);
              },
            ),
            const Divider(height: 32),
            _buildSettingRow(
              context,
              title: 'Motion Detection',
              description: 'Alerts you to movement near your DoorBox.',
              value: settings.motionDetectionEnabled,
              onChanged: (val) {
                ref.read(settingsProvider.notifier).state = settings.copyWith(motionDetectionEnabled: val);
              },
            ),
            
            const SizedBox(height: 32),
            Text('Box State', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildBoxStateCard(context, 'WiFi', '${deviceState.wifiStrength}%', 'Signal Strength', LucideIcons.wifi)),
                const SizedBox(width: 12),
                Expanded(child: _buildBoxStateCard(context, 'Battery', '${deviceState.batteryLevel}%', 'Remaining Charge', LucideIcons.batteryMedium)),
                const SizedBox(width: 12),
                Expanded(child: _buildBoxStateCard(context, 'Temperature', '${deviceState.temperature}°F', 'Internal Temp', LucideIcons.thermometer)),
              ],
            ),

            const SizedBox(height: 32),
            Text('Update Password', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildPasswordField(context, 'Current Password'),
            const SizedBox(height: 12),
            _buildPasswordField(context, 'New Password'),
            const SizedBox(height: 12),
            _buildPasswordField(context, 'Confirm Password'),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Save Changes',
              onPressed: () {},
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingRow(BuildContext context, {required String title, required String description, required bool value, required Function(bool) onChanged}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              CustomToggle(value: value, onChanged: onChanged),
            ],
          ),
          const SizedBox(height: 8),
          Text(description, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildBoxStateCard(BuildContext context, String title, String value, String subtitle, IconData icon) {
    return Container(
      decoration: AppTheme.softShadowDecoration,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Text(title, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Icon(icon, color: AppColors.primary, size: 28),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22, color: AppColors.primary)),
          const SizedBox(height: 4),
          Text(subtitle, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 10), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildPasswordField(BuildContext context, String hint) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        obscureText: true,
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: const Icon(LucideIcons.lock, color: AppColors.primary),
          hintText: hint,
          suffixIcon: const Icon(LucideIcons.eyeOff, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
