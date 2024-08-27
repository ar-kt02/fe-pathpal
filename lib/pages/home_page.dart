import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();
  String _name = "loading";
  int _level = 0;
  int _xp = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString("email");

    if (email != null) {
      final userInfo = await _apiService.fetchUserInfo(email);
      if (userInfo != null) {
        setState(() {
          _name = userInfo['pet_details']['pet_name'] ?? "loading";
          _level = userInfo['level'] ?? 0;
          _xp = userInfo['xp'] ?? 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 101, 111, 255),
        centerTitle: true,
        elevation: 4.0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 60,
                child: Center(
                  child: Text(
                    'Name: $_name | Level: $_level | XP: $_xp',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: SizedBox(
                  height: 420,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: ModelViewer(
                      src: 'assets/shiba.glb',
                      alt: 'Shiba Inu model',
                      ar: true,
                      arModes: ['scene-viewer', 'webxr', 'quick-look'],
                      disableZoom: true,
                      iosSrc: 'assets/shiba.usdz',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 8.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: SizedBox(
                  height: 110,
                  child: Center(
                    child: Text(
                      "Accessories",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
