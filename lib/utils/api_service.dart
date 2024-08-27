import 'package:dio/dio.dart';
class ApiService {
  final Dio _dio = Dio();
  ApiService() {
    _dio.options.baseUrl = 'https://path-pal-1faa351bcfa7.herokuapp.com/api';
    _dio.options.contentType = 'application/json';
  }
  Future<bool> checkUserExists(String email) async {
    try {
      final response = await _dio.get('/users/$email/');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  Future<Map<String, dynamic>?> fetchUserInfo(String email) async {
    try {
      final response = await _dio.get('/users/$email/');
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      return null;
    }
    return null;
  }
  Future<void> patchUserSteps(
      String email, int todaySteps, int totalSteps) async {
    try {
      await _dio.patch('/users/$email/', data: {
        'step_details': {
          'todays_steps': todaySteps,
          'total_steps': totalSteps,
        },
      });
    } catch (e) {
      return;
    }
  }
  Future<void> patchUserXp(String email, int xpIncrease) async {
    try {
      await _dio.patch('/users/$email/', data: {'xp': xpIncrease});
    } catch (e) {
      return;
    }
  }
}









