import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/providers/mock_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../core/widgets/primary_button.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> with SingleTickerProviderStateMixin {
  bool _isInternalCamera = true;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceState = ref.watch(deviceStatusProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: Center(
            child: Text(
              'DoorBox',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
          ),
        ),
        leadingWidth: 100,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                const Icon(LucideIcons.user, color: AppColors.textPrimary),
                const SizedBox(width: 8),
                Text('Kumar', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(width: 16),
                const Icon(LucideIcons.bell, color: AppColors.textPrimary),
              ],
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Device Name & Status
            Text(
              deviceState.name,
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: deviceState.isOnline ? AppColors.success : AppColors.error,
                      boxShadow: [
                        BoxShadow(
                          color: (deviceState.isOnline ? AppColors.success : AppColors.error).withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  deviceState.isOnline ? 'Online' : 'Offline',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Large Circular Unlock Button
            GestureDetector(
              onTap: () {
                // Toggle lock state logic (mock)
                ref.read(deviceStatusProvider.notifier).state = deviceState.copyWith(
                  isLocked: !deviceState.isLocked,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: deviceState.isLocked ? AppColors.success : AppColors.error,
                  boxShadow: [
                    BoxShadow(
                      color: (deviceState.isLocked ? AppColors.success : AppColors.error).withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      deviceState.isLocked ? LucideIcons.lock : LucideIcons.unlock,
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      deviceState.isLocked ? 'Unlock' : 'Lock',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),

            // Stat Cards Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                StatCard(
                  icon: LucideIcons.wifi,
                  title: '${deviceState.wifiStrength}%',
                  subtitle: '',
                  customContent: Column(
                    children: [
                      const Spacer(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              '${deviceState.wifiStrength}%',
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                          ),
                          const Icon(LucideIcons.wifi, color: AppColors.primary, size: 28),
                        ],
                      ),
                    ],
                  ),
                ),
                StatCard(
                  icon: LucideIcons.battery,
                  title: '${deviceState.batteryLevel}%',
                  subtitle: '',
                  customContent: Column(
                    children: [
                      const Spacer(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              '${deviceState.batteryLevel}%',
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                          ),
                          const Icon(LucideIcons.batteryMedium, color: AppColors.success, size: 28),
                        ],
                      ),
                    ],
                  ),
                ),
                StatCard(
                  icon: LucideIcons.thermometer,
                  title: '${deviceState.temperature}°F',
                  valueColor: AppColors.error,
                  subtitle: '',
                ),
                StatCard(
                  icon: LucideIcons.activity,
                  title: deviceState.motionDetected ? 'Motion' : 'Clear',
                  valueColor: deviceState.motionDetected ? AppColors.warning : AppColors.success,
                  subtitle: '',
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Camera Section
            Container(
              decoration: AppTheme.softShadowDecoration,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Camera', style: Theme.of(context).textTheme.titleLarge),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => setState(() => _isInternalCamera = true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _isInternalCamera ? Colors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: _isInternalCamera
                                      ? [const BoxShadow(color: Colors.black12, blurRadius: 4)]
                                      : null,
                                ),
                                child: Text('Internal', style: TextStyle(fontWeight: _isInternalCamera ? FontWeight.bold : FontWeight.normal)),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _isInternalCamera = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: !_isInternalCamera ? Colors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: !_isInternalCamera
                                      ? [const BoxShadow(color: Colors.black12, blurRadius: 4)]
                                      : null,
                                ),
                                child: Text('External', style: TextStyle(fontWeight: !_isInternalCamera ? FontWeight.bold : FontWeight.normal)),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        Image.network(
                          _isInternalCamera ? deviceState.internalCameraUrl : deviceState.externalCameraUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 200,
                            color: Colors.grey.shade300,
                            child: const Center(child: Icon(LucideIcons.cameraOff, size: 48, color: Colors.grey)),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text('Jan 11, 2026 01:48:08 PM', style: TextStyle(color: Colors.white, fontSize: 10)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    text: 'View Full Screen',
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
