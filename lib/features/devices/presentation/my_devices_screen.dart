import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../auth/domain/auth_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/primary_button.dart';

class MyDevicesScreen extends ConsumerStatefulWidget {
  const MyDevicesScreen({super.key});

  @override
  ConsumerState<MyDevicesScreen> createState() => _MyDevicesScreenState();
}

class _MyDevicesScreenState extends ConsumerState<MyDevicesScreen> {
  final _newDeviceController = TextEditingController();

  @override
  void dispose() {
    _newDeviceController.dispose();
    super.dispose();
  }

  void _showAddDeviceModal() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Add DoorBox'),
          content: TextField(
            controller: _newDeviceController,
            decoration: InputDecoration(
              hintText: 'Enter Hardware ID',
              prefixIcon: const Icon(LucideIcons.cpu),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final hwId = _newDeviceController.text.trim();
                if (hwId.isNotEmpty) {
                  final authNotifier = ref.read(authControllerProvider.notifier);
                  final success = await authNotifier.addDevice(hwId);
                  if (success && context.mounted) {
                    Navigator.pop(context);
                    _newDeviceController.clear();
                  } else if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to add device. It may be invalid.')),
                    );
                  }
                }
              },
              child: const Text('Add Device'),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final devices = authState.devices;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'My Devices',
          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: devices.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.packageOpen, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No devices found.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 24),
                  PrimaryButton(text: 'Add your first DoorBox', onPressed: _showAddDeviceModal),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(24.0),
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final deviceId = devices[index];
                return GestureDetector(
                  onTap: () => context.go('/home/$deviceId'),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: AppTheme.softShadowDecoration,
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(LucideIcons.box, color: AppColors.primary),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'DoorBox $deviceId',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              const Text('Click to view dashboard', style: TextStyle(color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        const Icon(LucideIcons.chevronRight, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: devices.isNotEmpty
          ? FloatingActionButton(
              backgroundColor: AppColors.primary,
              onPressed: _showAddDeviceModal,
              child: const Icon(LucideIcons.plus, color: Colors.white),
            )
          : null,
    );
  }
}
