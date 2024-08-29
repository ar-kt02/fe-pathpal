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
        _showErrorMsg('Error occured. Please try again.');
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
            style: const TextStyle(fontSize: 15),
          ),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign up'),
        backgroundColor: const Color(0xFFFF9E6E),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: _validateName,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: _validateEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              TextFormField(
                controller: _petNameController,
                decoration: const InputDecoration(
                  labelText: 'Pet Name',
                  border: OutlineInputBorder(),
                ),
                validator: _validatePetName,
              ),
              const Text('Select your pet:'),
              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _handlePetSelection(),
                ),
              ),
              ElevatedButton(
                onPressed: _isLoading ? null : _signupUser,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Sign up'),
              ),
            ],
          ),
        ),
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
