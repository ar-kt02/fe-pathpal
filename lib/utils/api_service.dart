import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio();
  final String _baseURL = 'https://path-pal-1faa351bcfa7.herokuapp.com/api';

  Future<bool> checkUserExists(String email) async {
    try {
      final response = await _dio.get('$_baseURL/users/$email');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> fetchUserInfo(String email) async {
    try {
      final response = await _dio.get('$_baseURL/users/$email');
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<void> patchTodaySteps(String email, int todaySteps) async {
    try {
      await _dio.patch('$_baseURL/users/$email', data: {
        'step_details': {'todays_steps': todaySteps}
      });
    } catch (e) {
      return;
    }
  }
}
