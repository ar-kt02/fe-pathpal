import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_service.dart';
import 'main_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final ApiService _apiService = ApiService();

  Future<void> _loginUser() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _errorMsg('Enter a valid email');
      return;
    }

    if (await _checkUserExists(email)) {
      await _saveEmail(email);
      _navigateMainScreen();
    } else {
      _errorMsg('Account not found');
    }
  }

  Future<bool> _checkUserExists(String email) async {
    return await _apiService.checkUserExists(email);
  }

  Future<void> _saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
  }

  void _navigateMainScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  void _errorMsg(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Log in'),
          backgroundColor: const Color(0xFFFF9E6E)),
      body: Container(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                  labelText: 'Enter your email', border: OutlineInputBorder()),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: OutlinedButton(
                onPressed: _loginUser,
                child: const Text('Log in'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
