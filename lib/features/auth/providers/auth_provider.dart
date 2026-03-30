import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unigpa/features/auth/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://dummyjson.com'));

  UserModel? _user;
  UserModel? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _isInitializing = true;
  bool get isInitializing => _isInitializing;

  String? _error;
  String? get error => _error;

  bool get isAuthenticated => _user != null && _user!.accessToken.isNotEmpty;

  AuthProvider() {
    _loadUserFromPrefs();
  }

  Future<void> _loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token != null && token.isNotEmpty) {
      try {
        final response = await _dio.get(
          '/auth/me',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );

        if (response.statusCode == 200) {
          final data = response.data;
          data['accessToken'] = token;
          _user = UserModel.fromJson(data);
        } else {
          await logout();
        }
      } catch (e) {
        await logout();
      }
    }

    _isInitializing = false;
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'username': username,
          'password': password,
          'expiresInMins': 30,
        },
      );

      if (response.statusCode == 200) {
        _user = UserModel.fromJson(response.data);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', _user!.accessToken);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on DioException {
      _error = 'Tên đăng nhập/Mật khẩu không đúng!';
    } catch (e) {
      _error = 'Đã có lỗi xảy ra.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _dio.post(
        '/users/add',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Đăng ký thất bại.';
    } catch (e) {
      _error = 'Đã có lỗi xảy ra.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String gender,
    required String image,
  }) async {
    if (_user == null) return false;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _dio.put(
        '/users/${_user!.id}',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'gender': gender,
          'image': image,
        },
      );

      if (response.statusCode == 200) {
        _user = _user!.copyWith(
          firstName: firstName,
          lastName: lastName,
          email: email,
          gender: gender,
          image: image,
        );
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Cập nhật thất bại.';
    } catch (e) {
      _error = 'Đã có lỗi xảy ra.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    notifyListeners();
  }
}
