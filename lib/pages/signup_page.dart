import 'package:flutter/material.dart';
import '../utils/api_service.dart';
import 'main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _petNameController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String _selectedPet = 'dog';

  final Map<String, String> _petMap = {
    'dog': 'assets/shiba.glb',
    'panda': "assets/panda.glb"
  };

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter a name.';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter an email';
    }
    if (!RegExp(
            r"^[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?$")
        .hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePetName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter your pet name';
    }
    return null;
  }

  void _signupUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final signUpResult = await _apiService.signupUser(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _petNameController.text.trim(),
          _selectedPet,
        );

        if (signUpResult != null) {
          await _saveEmail(_emailController.text.trim());
          _navigateToMainScreen();
        } else {
          _showErrorMsg('Signup failed. Please try again.');
        }
      } catch (e) {
        _showErrorMsg('Error occurred. Please try again.');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
  }

  void _navigateToMainScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  void _showErrorMsg(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  List<Widget> _handlePetSelection() {
    return _petMap.entries.map((entry) {
      bool isSelected = _selectedPet == entry.key;
      String formattedKey = entry.key.replaceAll('_', ' ');

      return Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedPet = entry.key;
              });
            },
            child: Card(
              color: isSelected ? Colors.amber.shade300 : Colors.transparent,
              child: SizedBox(
                width: 90,
                height: 90,
                child: IgnorePointer(
                  ignoring: true,
                  child: ModelViewer(
                    src: entry.value,
                    alt: entry.key,
                    ar: false,
                    autoRotate: true,
                    disableZoom: true,
                    cameraControls: false,
                  ),
                ),
              ),
            ),
          ),
          Text(
            formattedKey,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.white,
            ),
          ),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/image_background.png',
            fit: BoxFit.fill,
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: Offset(2.0, 2.0),
                                blurRadius: 3.0,
                                color: Color.fromARGB(128, 0, 0, 0),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Sign up to get started',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            shadows: [
                              Shadow(
                                offset: Offset(2.0, 2.0),
                                blurRadius: 3.0,
                                color: Color.fromARGB(128, 0, 0, 0),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          labelStyle: const TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.8),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide:
                                const BorderSide(color: Color(0xFF78C850)),
                          ),
                        ),
                        validator: _validateName,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: const TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.8),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide:
                                const BorderSide(color: Color(0xFF78C850)),
                          ),
                        ),
                        validator: _validateEmail,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _petNameController,
                        decoration: InputDecoration(
                          labelText: 'Pet Name',
                          labelStyle: const TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.8),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide:
                                const BorderSide(color: Color(0xFF78C850)),
                          ),
                        ),
                        validator: _validatePetName,
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'Select your pet:',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 120,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: _handlePetSelection(),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Center(
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _signupUser,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              backgroundColor: const Color(0xFF78C850),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator()
                                : const Text(
                                    'Sign up',
                                    style: TextStyle(fontSize: 18),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Already have an account? Log in",
                          
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _petNameController.dispose();
    super.dispose();
  }
}
