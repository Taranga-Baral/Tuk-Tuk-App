// import 'dart:async';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// class ApiService {
//   static const String _baseUrl = 'http://192.168.100.44:8000/api';
//   static const String _loginEndpoint = '/login';
//   static const String _apiKeyEndpoint = '/maps/key';

//   // Hardcoded credentials
//   static const String _email = 'test@example.com';
//   static const String _password = 'password123';

//   final _storage = const FlutterSecureStorage();
//   Timer? _tokenRefreshTimer;

//   // Current session data
//   String? _authToken;
//   String? _encryptedKey;
//   DateTime? _tokenExpiry;
//   DateTime? _keyExpiry;

//   // Singleton instance
//   static final ApiService _instance = ApiService._internal();
//   factory ApiService() => _instance;
//   ApiService._internal();

//   // Public getters
//   String? get authToken => _authToken;
//   String? get encryptedKey => _encryptedKey;
//   bool get isTokenValid =>
//       _tokenExpiry != null && DateTime.now().isBefore(_tokenExpiry!);
//   bool get isKeyValid =>
//       _keyExpiry != null && DateTime.now().isBefore(_keyExpiry!);

//   Future<void> initialize() async {
//     await _loadFromStorage();
//     if (!isTokenValid) {
//       await _loginAndFetchKey();
//     } else if (!isKeyValid) {
//       await _fetchEncryptedKey();
//     }
//     _startAutoRefresh();
//   }

//   Future<void> _loadFromStorage() async {
//     _authToken = await _storage.read(key: 'auth_token');
//     _encryptedKey = await _storage.read(key: 'encrypted_key');

//     final tokenExpiryString = await _storage.read(key: 'token_expiry');
//     final keyExpiryString = await _storage.read(key: 'key_expiry');

//     if (tokenExpiryString != null) {
//       _tokenExpiry = DateTime.parse(tokenExpiryString);
//     }
//     if (keyExpiryString != null) {
//       _keyExpiry = DateTime.parse(keyExpiryString);
//     }
//   }

//   Future<void> _loginAndFetchKey() async {
//     try {
//       // 1. Perform login
//       final loginResponse = await http.post(
//         Uri.parse('$_baseUrl$_loginEndpoint'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({'email': _email, 'password': _password}),
//       );

//       if (loginResponse.statusCode != 200) {
//         throw Exception('Login failed: ${loginResponse.statusCode}');
//       }

//       final loginData = json.decode(loginResponse.body)['data'] as String;
//       final loginJson = json.decode(loginData) as Map<String, dynamic>;

//       _authToken = loginJson['token'] as String;
//       _tokenExpiry = DateTime.parse(loginJson['expires_at'] as String);

//       // 2. Immediately fetch the encrypted key
//       await _fetchEncryptedKey();

//       // 3. Store everything
//       await _storage.write(key: 'auth_token', value: _authToken);
//       await _storage.write(
//           key: 'token_expiry', value: _tokenExpiry!.toIso8601String());
//     } catch (e) {
//       print('Login error: $e');
//       rethrow;
//     }
//   }

//   Future<void> _fetchEncryptedKey() async {
//     if (_authToken == null) return;

//     final keyResponse = await http.get(
//       Uri.parse('$_baseUrl$_apiKeyEndpoint'),
//       headers: {'Authorization': 'Bearer $_authToken'},
//     );

//     if (keyResponse.statusCode != 200) {
//       throw Exception('Failed to get key: ${keyResponse.statusCode}');
//     }

//     final keyData = json.decode(keyResponse.body)['data'] as String;
//     final keyJson = json.decode(keyData) as Map<String, dynamic>;

//     _encryptedKey = keyJson['encrypted_key'] as String;
//     _keyExpiry = DateTime.parse(keyJson['expires_at'] as String);

//     await _storage.write(key: 'encrypted_key', value: _encryptedKey);
//     await _storage.write(
//         key: 'key_expiry', value: _keyExpiry!.toIso8601String());
//   }

//   void _startAutoRefresh() {
//     _tokenRefreshTimer?.cancel();
//     _tokenRefreshTimer =
//         Timer.periodic(const Duration(seconds: 1), (timer) async {
//       if (!isTokenValid) {
//         print('Token expired - refreshing...');
//         await _loginAndFetchKey();
//       } else if (!isKeyValid) {
//         print('Key expired - refreshing...');
//         await _fetchEncryptedKey();
//       }
//     });
//   }

//   void dispose() {
//     _tokenRefreshTimer?.cancel();
//   }
// }
