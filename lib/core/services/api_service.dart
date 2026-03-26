import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

class ApiService {
  final Dio _dio;
  
  // Updated with actual backend IP
  static const String baseUrl = 'http://34.47.214.219:3000';

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
}
