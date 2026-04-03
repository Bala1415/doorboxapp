import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.read(authRepositoryProvider));
});

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final List<String> devices;
  final String? email;
  final String? error;

  AuthState({
    this.isLoading = true,
    this.isAuthenticated = false,
    this.devices = const [],
    this.email,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    List<String>? devices,
    String? email,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      devices: devices ?? this.devices,
      email: email ?? this.email,
      error: error,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthController(this._authRepository) : super(AuthState(isLoading: true)) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    final credentials = await _authRepository.getCredentials();
    
    if (credentials['email'] != null) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        devices: credentials['devices'] as List<String>? ?? [],
        email: credentials['email'],
        error: null,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        devices: [],
        email: null,
        error: null,
      );
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    final response = await _authRepository.login(email, password);
    
    if (response['success'] == true) {
      final List<dynamic> devicesDynamic = response['devices'] ?? [];
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        devices: devicesDynamic.map((e) => e.toString()).toList(),
        email: email,
        error: null,
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        error: response['error'] ?? 'Login failed',
      );
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    final response = await _authRepository.register(email, password);
    
    if (response['success'] == true) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        devices: [],
        email: email,
        error: null,
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        error: response['error'] ?? 'Registration failed',
      );
      return false;
    }
  }

  Future<bool> addDevice(String hardwareId) async {
    if (state.email == null) return false;
    state = state.copyWith(isLoading: true, error: null);
    
    final response = await _authRepository.addDevice(state.email!, hardwareId);
    
    if (response['success'] == true) {
      final updatedDevices = List<String>.from(state.devices);
      if (!updatedDevices.contains(hardwareId)) {
        updatedDevices.add(hardwareId);
      }
      state = state.copyWith(
        isLoading: false,
        devices: updatedDevices,
        error: null,
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        error: response['error'] ?? 'Failed to add device',
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await _authRepository.clearCredentials();
    state = state.copyWith(
      isLoading: false,
      isAuthenticated: false,
      devices: [],
      email: null,
      error: null,
    );
  }
}
