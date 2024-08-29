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
  String _name = "loading...";
  int _level = 0;
  int _xp = 0;
  String email = "";
  String _selectedPet = '';
  String _selectedToy = '';
  String _selectToyInput = '';
  List<String> _collectedItems = [];

  final Map<String, String> _petMap = {
    'dog': 'assets/shiba.glb',
    'panda': "assets/panda.glb"
  };

  final Map<String, String> _toyMap = {
    'ball_thrower': 'assets/toys/ball_thrower_blue.glb',
    'bone': 'assets/toys/bone_grey.glb',
    'snack_holder': 'assets/toys/snack_holder_red.glb',
    'dog_toys': 'assets/toys/dog_toys.glb',
    'carrot': 'assets/toys/carrot.glb'
  };

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    email = prefs.getString("email") ?? "";

    if (email.isNotEmpty) {
      final userInfo = await _apiService.fetchUserInfo(email);
      if (userInfo != null) {
        setState(() {
          _name = userInfo['pet_details']['pet_name'] ?? "";
          _level = userInfo['level'] ?? "0";
          _xp = userInfo['xp'] ?? "0";

          _collectedItems =
              List<String>.from(userInfo['collected_items'] ?? []);
          String selectedToy = userInfo['pet_details']['selected_toy'] ?? '';
          _selectedToy = _toyMap[selectedToy] ?? '';
          _selectToyInput = _selectedToy;

          String selectedPet = userInfo['pet_details']['selected_pet'] ?? '';
          _selectedPet = _petMap[selectedPet] ?? '';
        });
      }
    }
  }

  Future<void> _changeToy() async {
    if (_selectToyInput != _selectedToy) {
      setState(() {
        _selectedToy = _selectToyInput;
      });

      if (email.isNotEmpty) {
        final newToyKey = _toyMap.entries
            .firstWhere((entry) => entry.value == _selectedToy,
                orElse: () => const MapEntry('', ''))
            .key;

        if (newToyKey.isNotEmpty) {
          await _apiService.patchSelectedToy(email, newToyKey);
        }
      }
    }
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
          Column(
            children: <Widget>[
              Expanded(
                child: Stack(
                  children: [
                    Center(
                      child: SizedBox(
                        height: 420,
                        child: _selectedPet.isNotEmpty
                            ? ModelViewer(
                                src: _selectedPet,
                                alt: _selectedPet,
                                ar: true,
                                arModes: const [
                                  'scene-viewer',
                                  'webxr',
                                  'quick-look'
                                ],
                                autoRotate: true,
                                disableZoom: false,
                                cameraControls: true,
                                iosSrc: 'assets/shiba.usdz',
                              )
                            : const Center(child: Text('Loading pet...')),
                      ),
                    ),
                    Positioned(
                      top: 40,
                      left: 20,
                      child: Text(
                        '$_xp XP',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 61,
                      right: 20,
                      child: Text(
                        'Lvl $_level',
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 0,
                      right: 0,
                      child: Text(
                        _name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 120,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: _handleToySelection(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectToyInput == _selectedToy
                        ? Colors.grey
                        : Colors.green.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                  ),
                  onPressed:
                      _selectToyInput == _selectedToy ? null : _changeToy,
                  child: Text(
                    _selectToyInput == _selectedToy ? 'Equipped' : 'Change Toy',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _handleToySelection() {
    return _toyMap.entries.where((entries) {
      return _collectedItems.contains(entries.key);
    }).map((entries) {
      bool isSelected = _selectToyInput == entries.value;
      String formattedKey = entries.key.replaceAll('_', ' ');

      return Container(
        width: 100,
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectToyInput = entries.value;
                });
              },
              child: Card(
                color: isSelected ? Colors.amber.shade300 : Colors.transparent,
                child: SizedBox(
                  height: 75,
                  child: IgnorePointer(
                    ignoring: true,
                    child: ModelViewer(
                      src: entries.value,
                      alt: entries.key,
                      ar: false,
                      autoRotate: false,
                      disableZoom: true,
                      cameraControls: false,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    formattedKey,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
