import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/api_service.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(apiServiceProvider));
});

class AuthRepository {
  final ApiService _apiService;

  AuthRepository(this._apiService);

  static const String _devicesKey = 'user_devices';
  static const String _userEmailKey = 'user_email';

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _apiService.login(email, password);
    if (response['success'] == true) {
      final List<dynamic> devicesDynamic = response['devices'] ?? [];
      final List<String> devices = devicesDynamic.map((e) => e.toString()).toList();
      await saveCredentials(email, devices);
    }
    return response;
  }

  Future<Map<String, dynamic>> register(String email, String password) async {
    final response = await _apiService.register(email, password);
    if (response['success'] == true) {
      await saveCredentials(email, []);
    }
    return response;
  }
  
  Future<Map<String, dynamic>> addDevice(String email, String hardwareId) async {
    final response = await _apiService.addDevice(email, hardwareId);
    if (response['success'] == true) {
      // Fetch currently stored devices
      final prefs = await SharedPreferences.getInstance();
      final currentDevices = prefs.getStringList(_devicesKey) ?? [];
      if (!currentDevices.contains(hardwareId)) {
        currentDevices.add(hardwareId);
        await prefs.setStringList(_devicesKey, currentDevices);
      }
    }
    return response;
  }

  Future<void> saveCredentials(String email, List<String> devices) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userEmailKey, email);
    await prefs.setStringList(_devicesKey, devices);
  }

  Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userEmailKey);
    await prefs.remove(_devicesKey);
  }

  Future<Map<String, dynamic>> getCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'email': prefs.getString(_userEmailKey),
      'devices': prefs.getStringList(_devicesKey) ?? [],
    };
  }
}
