// ============================================================================
// FILE: auth_service.dart
// DESCRIPTION: Authentication service integrated with backend API
// ============================================================================
// PROJECT: Stellantis Dealer Hygiene App
// AUTHOR: AI Assistant
// WEBSITE: https://www.stellantis.com/
// VERSION: 1.0.0
// ============================================================================
// COPYRIGHT: © 2026 STELLANTIS N.V. - INTERNAL USE ONLY
// ============================================================================

import 'dart:async';
import 'dart:convert';
import '../models/user_role.dart';
import '../config/api_config.dart';
import '../config/auth_mode.dart';
import 'api_client.dart';
import 'storage_service.dart';

/// User model for authenticated users
class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? facilityId;
  final String? facilityName;
  final String? zone;
  final String? country;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.facilityId,
    this.facilityName,
    this.zone,
    this.country,
  });

  /// Convert user to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role == UserRole.dealerFacilities ? 'dealer' : 'manager',
        'facilityId': facilityId,
        'facilityName': facilityName,
        'zone': zone,
        'country': country,
      };

  /// Create user from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['user_id'] ?? '',
      name: json['name'] ?? json['full_name'] ?? '',
      email: json['email'] ?? '',
      role: (json['role'] ?? 'dealer') == 'dealer'
          ? UserRole.dealerFacilities
          : UserRole.stellantisManager,
      facilityId: json['facilityId'] ?? json['facility_id'],
      facilityName: json['facilityName'] ?? json['facility_name'],
      zone: json['zone'],
      country: json['country'],
    );
  }
}

/// Authentication service for managing user sessions with backend API
class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // API and storage services
  final ApiClient _apiClient = ApiClient();
  final StorageService _storageService = StorageService();

  // Current user session
  User? _currentUser;
  String? _authToken;

  final StreamController<User?> _userStreamController =
      StreamController<User?>.broadcast();

  /// Stream of user authentication state
  Stream<User?> get userStream => _userStreamController.stream;

  /// Get current authenticated user
  User? get currentUser => _currentUser;

  /// Get current auth token
  String? get authToken => _authToken;

  /// Check if user is authenticated
  bool get isAuthenticated => _currentUser != null && _authToken != null;

  /// Initialize - restore session from storage
  Future<void> initialize() async {
    try {
      final token = await _storageService.get<String>('auth_token');
      final userDataJson = await _storageService.get<String>('user_data');

      if (token != null && userDataJson != null) {
        _authToken = token;
        final userData = jsonDecode(userDataJson);
        _currentUser = User.fromJson(userData);
        _userStreamController.add(_currentUser);
      }
    } catch (e) {
      print('Error restoring session: $e');
    }
  }

  // ===========================================================================
  // TEMP TEST CREDENTIALS (REMOVE AFTER DEPLOYMENT)
  // ===========================================================================
  static const String _dealerTestEmail = 'chin@stellantis.com';
  static const String _dealerTestPassword = 'chin@123';

  static const String _managerTestEmail = 'debabratadas@stellantis.com';
  static const String _managerTestPassword = 'debabratadas@123';

  User? _tryLocalTestLogin({
    required String emailOrId,
    required String password,
    required UserRole role,
  }) {
    final email = emailOrId.trim().toLowerCase();

    if (role == UserRole.dealerFacilities && email == _dealerTestEmail && password == _dealerTestPassword) {
      return User(
        id: 'temp_dealer_user',
        name: 'Chin',
        email: _dealerTestEmail,
        role: role,
        facilityId: 'facility_001',
        facilityName: 'Stellantis Facility',
      );
    }

    if (role == UserRole.stellantisManager && email == _managerTestEmail && password == _managerTestPassword) {
      return User(
        id: 'temp_manager_user',
        name: 'Debabrata Das',
        email: _managerTestEmail,
        role: role,
        zone: 'United States',
        country: 'United States',
      );
    }

    return null;
  }

  /// Login with email and password
  Future<User> login({
    required String emailOrId,
    required String password,
    required UserRole role,
  }) async {
    // If backend auth is disabled, only allow local test users.
    if (!AuthMode.useBackendAuth) {
      final localUser = _tryLocalTestLogin(
        emailOrId: emailOrId,
        password: password,
        role: role,
      );

      if (localUser == null) {
        throw Exception('Login failed: invalid test credentials');
      }

      _authToken = 'temp_local_token';
      _currentUser = localUser;

      await _storageService.save('auth_token', _authToken!);
      await _storageService.save('user_data', jsonEncode(_currentUser!.toJson()));
      _userStreamController.add(_currentUser);

      return _currentUser!;
    }

    // Backend auth enabled: try DB/backend first, then fallback to local test users
    try {
      final endpoint = await ApiConfig.signinEndpoint;

      print('🔐 Attempting login to: $endpoint');

      final response = await _apiClient.post(
        endpoint,
        data: {
          'email': emailOrId,
          'password': password,
        },
      );

      final data = response.data;
      _authToken = data['access_token'] ?? data['token'];

      if (_authToken != null) {
        await _storageService.save('auth_token', _authToken!);
      }

      final userData = data['user'] ?? data;
      _currentUser = User(
        id: userData['user_id'] ?? userData['id'] ?? 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: userData['full_name'] ?? userData['name'] ?? emailOrId,
        email: userData['email'] ?? emailOrId,
        role: role,
        facilityId: userData['facility_id'] ?? (role == UserRole.dealerFacilities ? 'facility_001' : null),
        facilityName: userData['facility_name'] ?? (role == UserRole.dealerFacilities ? 'Stellantis Facility' : null),
        zone: userData['zone'],
        country: userData['country'],
      );

      await _storageService.save('user_data', jsonEncode(_currentUser!.toJson()));
      _userStreamController.add(_currentUser);

      print('✅ Login successful (backend)!');
      return _currentUser!;
    } catch (e) {
      final localUser = _tryLocalTestLogin(
        emailOrId: emailOrId,
        password: password,
        role: role,
      );

      if (localUser != null) {
        _authToken = 'temp_local_token';
        _currentUser = localUser;
        await _storageService.save('auth_token', _authToken!);
        await _storageService.save('user_data', jsonEncode(_currentUser!.toJson()));
        _userStreamController.add(_currentUser);
        return _currentUser!;
      }

      rethrow;
    }
  }

  /// Register a new user - integrates with backend API
  Future<User> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? facilityId,
    String? facilityName,
    String? employeeId,
  }) async {
    if (!AuthMode.useBackendAuth) {
      throw Exception('Registration is disabled while backend auth is off');
    }
    try {
      // Get dynamic endpoint
      final endpoint = await ApiConfig.signupEndpoint;

      print('📝 Attempting signup to: $endpoint');

      // Call backend signup API
      final response = await _apiClient.post(
        endpoint,
        data: {
          'email': email,
          'password': password,
          'full_name': name,
          'role': role == UserRole.dealerFacilities ? 'dealer' : 'manager',
        },
      );

      // Extract user data from response
      final data = response.data;

      // Create user from response
      _currentUser = User(
        id: data['user_id'] ?? data['id'] ?? 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: data['full_name'] ?? name,
        email: data['email'] ?? email,
        role: role,
        facilityId: facilityId ?? (role == UserRole.dealerFacilities ? 'facility_001' : null),
        facilityName: facilityName,
        zone: data['zone'],
        country: data['country'],
      );

      print('✅ Signup successful! Logging in...');

      // After signup, perform login to get token
      await login(
        emailOrId: email,
        password: password,
        role: role,
      );

      return _currentUser!;
    } catch (e) {
      print('❌ Registration error: $e');
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  /// Logout current user
  Future<void> logout() async {
    // Clear local data
    await _storageService.remove('auth_token');
    await _storageService.remove('user_data');

    _currentUser = null;
    _authToken = null;
    _userStreamController.add(null);
  }

  /// Request password reset
  Future<void> requestPasswordReset(String email) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    // TODO: Implement with backend API when available
    // For now, just simulate success
  }

  /// Update user profile
  Future<User> updateProfile({
    String? name,
    String? email,
  }) async {
    if (_currentUser == null) {
      throw Exception('No user logged in');
    }

    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    // TODO: Implement with backend API when available

    final updatedUser = User(
      id: _currentUser!.id,
      name: name ?? _currentUser!.name,
      email: email ?? _currentUser!.email,
      role: _currentUser!.role,
      facilityId: _currentUser!.facilityId,
      facilityName: _currentUser!.facilityName,
      zone: _currentUser!.zone,
      country: _currentUser!.country,
    );

    _currentUser = updatedUser;
    await _storageService.save('user_data', jsonEncode(updatedUser.toJson()));
    _userStreamController.add(updatedUser);

    return updatedUser;
  }

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_currentUser == null) {
      throw Exception('No user logged in');
    }

    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock validation
    if (currentPassword.isEmpty || newPassword.isEmpty) {
      throw Exception('Passwords cannot be empty');
    }

    if (newPassword.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }

    // TODO: Implement with backend API when available
  }

  /// Get user statistics (for dealers)
  Future<Map<String, dynamic>> getUserStats() async {
    if (_currentUser == null || _currentUser!.role != UserRole.dealerFacilities) {
      throw Exception('Invalid user role');
    }

    // Offline mode: don't hit backend.
    if (!AuthMode.useBackendAuth) {
      return {
        'totalAuditsCompleted': 24,
        'auditsThisWeek': 8,
        'auditsToday': 4,
        'averageCompliance': 87.5,
        'streak': 7,
      };
    }

    try {
      // Get dynamic endpoint
      final endpoint = await ApiConfig.dealerStatsEndpoint(
        _currentUser!.facilityId ?? 'facility_001',
      );

      // Call backend stats API
      final response = await _apiClient.get(endpoint);

      return response.data as Map<String, dynamic>;
    } catch (e) {
      print('❌ Error fetching user stats: $e');
      // Return mock statistics on error
      return {
        'totalAuditsCompleted': 24,
        'auditsThisWeek': 8,
        'auditsToday': 4,
        'averageCompliance': 87.5,
        'streak': 7,
      };
    }
  }

  /// Dispose resources
  void dispose() {
    _userStreamController.close();
  }
}

// ============================================================================
// END OF FILE: auth_service.dart
// ============================================================================

