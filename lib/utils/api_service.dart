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

  Future<void> patchUserXpAndLevel(
      String email, int newXp, int newLevel) async {
    try {
      await _dio
          .patch('/users/$email/', data: {'xp': newXp, 'level': newLevel});
    } catch (e) {
      return;
    }
  }

  Future<void> patchSelectedToy(String email, String toyKey) async {
    try {
      await _dio.patch('/users/$email/', data: {
        'pet_details': {
          'selected_toy': toyKey,
        },
      });
    } catch (e) {
      return;
    }
  }

  Future<Map<String, dynamic>?> signupUser(
      String name, String email, String petName, String selectedPet) async {
    try {
      final response = await _dio.post('/users/', data: {
        'name': name,
        'email': email,
        'pet_details': {
          'pet_name': petName,
          'selected_pet': selectedPet,
        },
      });
      if (response.statusCode == 201) {
        return response.data;
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}
