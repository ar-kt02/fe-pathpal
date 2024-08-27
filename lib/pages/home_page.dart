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
    // TODO: implement initState
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
          _level = userInfo['level'] ?? "loading";
          _xp = userInfo['xp'] ?? "loading";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Home'), backgroundColor: const Color(0xFFFF9E6E)),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 60,
              child: Center(
                child: Text(
                  'Name: $_name | Level: $_level | XP: $_xp',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            Card(
              child: SizedBox(
                height: 420,
                child: ModelViewer(
                  src: 'assets/shiba.glb',
                  alt: 'Shiba Inu model',
                  ar: true,
                  arModes: ['scene-viewer', 'webxr', 'quick-look'],
                  // autoRotate: true,
                  disableZoom: true,
                  // cameraControls: true,
                  iosSrc: 'assets/shiba.usdz',
                ),
              ),
            ),
            Card(
              child: SizedBox(
                height: 110,
                child: Center(
                  child: Text(
                    "Accessories",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
