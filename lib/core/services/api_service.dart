import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

class ApiService {
  final Dio _dio;
  
  // Updated with actual backend IP
  static const String baseUrl = 'http://34.14.171.122:3000';

  ApiService() : _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Future<bool> unlockBox(String hardwareId) async {
    try {
      final response = await _dio.post(
        '/unlock-box',
        data: {'hardwareid': hardwareId},
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error unlocking box: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> register(String email, String password) async {
    try {
      final response = await _dio.post(
        '/register',
        data: {'email': email, 'password': password},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
      return {'error': 'Failed to register'};
    } catch (e) {
      debugPrint('Error registering user: $e');
      if (e is DioException && e.response != null) {
         return e.response?.data ?? {'error': 'Unknown error occurred'};
      }
      return {'error': 'Registration failed due to network error'};
    }
  }

  Future<Map<String, dynamic>> addDevice(String email, String hardwareId) async {
    try {
      final response = await _dio.post(
        '/add-device',
        data: {'email': email, 'hardwareid': hardwareId},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
      return {'error': 'Failed to add device'};
    } catch (e) {
      debugPrint('Error adding device: $e');
      if (e is DioException && e.response != null) {
         return e.response?.data ?? {'error': 'Unknown error occurred'};
      }
      return {'error': 'Failed to add device due to network error'};
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
      return {'error': 'Invalid email or password'};
    } catch (e) {
      debugPrint('Error logging in: $e');
      if (e is DioException && e.response != null) {
         return e.response?.data ?? {'error': 'Invalid email or password'};
      }
      return {'error': 'Login failed due to network error'};
    }
  }
}
