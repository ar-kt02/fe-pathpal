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
}
