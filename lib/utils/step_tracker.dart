import 'dart:async';
import 'dart:math';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'package:flutter/material.dart';

class StepTracker {
  int todaySteps = 0;
  int totalSteps = 0;
  int stepsToTriggerPatch = 0;
  int lastPedometerCount = 0;
  int currentXp = 0;
  int currentLevel = 1;
  String email = "";
  DateTime? lastUpdateTime;
  StreamSubscription<StepCount>? pedometerSubscription;
  bool isInitialized = false;
  final ApiService apiService = ApiService();
  final Function(int, int) stepsUpdateHandler;
  final BuildContext context;

  StepTracker({required this.stepsUpdateHandler, required this.context});

  Future<void> initialiseData() async {
    await _accessEmail();
    await _loadLocalData();

    if (email.isNotEmpty) {
      await _fetchInitialData();
      _runPedometer();
    }
  }

  Future _loadLocalData() async {
    final prefs = await SharedPreferences.getInstance();

    todaySteps = prefs.getInt('todaySteps') ?? 0;
    totalSteps = prefs.getInt('totalSteps') ?? 0;
    lastPedometerCount = prefs.getInt("lastPedometerCount") ?? 0;
    currentXp = prefs.getInt('currentXp') ?? 0;
    currentLevel = prefs.getInt('currentLevel') ?? 1;

    String? timeString = prefs.getString('lastUpdateTime');
    if (timeString != null) {
      lastUpdateTime = DateTime.parse(timeString);
    }
  }

  Future<void> _fetchInitialData() async {
    try {
      final userInfo = await apiService.fetchUserInfo(email);

      if (userInfo != null) {
        int apiTodaySteps = userInfo['step_details']['todays_steps'] ?? 0;
        int apiTotalSteps = userInfo['step_details']['total_steps'] ?? 0;
        int apiCurrentXp = userInfo['xp'] ?? 0;
        int apiCurrentLevel = userInfo['level'] ?? 1;

        bool isDifferentDay = lastUpdateTime != null &&
            !_isSameDay(lastUpdateTime!, DateTime.now());
        if (isDifferentDay) {
          todaySteps = 0;
        }

        todaySteps = todaySteps > apiTodaySteps ? todaySteps : apiTodaySteps;
        totalSteps = totalSteps > apiTotalSteps ? totalSteps : apiTotalSteps;
        currentXp = apiCurrentXp;
        currentLevel = apiCurrentLevel;

        stepsUpdateHandler(todaySteps, totalSteps);
        await _saveLocalData();
      }
    } catch (err) {
      return;
    }
  }

  bool _isSameDay(DateTime dayA, DateTime dayB) {
    return dayA.year == dayB.year &&
        dayA.month == dayB.month &&
        dayA.day == dayB.day;
  }

  Future _saveLocalData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('todaySteps', todaySteps);
    await prefs.setInt('totalSteps', totalSteps);
    await prefs.setInt('lastPedometerCount', lastPedometerCount);
    await prefs.setInt('currentXp', currentXp);
    await prefs.setInt('currentLevel', currentLevel);

    await prefs.setString('lastUpdateTime', DateTime.now().toString());
  }

  Future<void> _accessEmail() async {
    final prefs = await SharedPreferences.getInstance();
    email = prefs.getString("email") ?? "";
  }

  void _runPedometer() {
    pedometerSubscription = Pedometer.stepCountStream.listen((StepCount event) {
      _handlePedometerSetup(event.steps);
    });
  }

  Future<void> _handlePedometerSetup(int newPedometerCount) async {
    if (!isInitialized) {
      isInitialized = true;
      if (lastPedometerCount > 0) {
        int stepsWhenClosed = newPedometerCount - lastPedometerCount;

        if (stepsWhenClosed > 0) {
          await _updateSteps(stepsWhenClosed);
        }
      }
    } else {
      int stepIncrease = newPedometerCount - lastPedometerCount;

      if (stepIncrease > 0) {
        await _updateSteps(stepIncrease);
      }
    }

    lastPedometerCount = newPedometerCount;
    await _saveLocalData();
  }

  Future<void> _updateSteps(int stepChanges) async {
    todaySteps += stepChanges;
    totalSteps += stepChanges;
    stepsToTriggerPatch += stepChanges;

    stepsUpdateHandler(todaySteps, totalSteps);

    if (stepsToTriggerPatch >= 10) {
      await _patchUserSteps();
      await _patchUserXpAndLevel();
      stepsToTriggerPatch = 0;
    }
  }

  Future<void> _patchUserSteps() async {
    try {
      await apiService.patchUserSteps(email, todaySteps, totalSteps);
    } catch (e) {
      return;
    }
  }

  Future<void> _patchUserXpAndLevel() async {
    try {
      int newXp = totalSteps ~/ 60;
      int newLevel = (newXp ~/ 100) + 1;

      if (newXp != currentXp || newLevel != currentLevel) {
        await apiService.patchUserXpAndLevel(email, newXp, newLevel);
        currentXp = newXp;
        currentLevel = newLevel;
        await _saveLocalData();

        final userInfo = await apiService.fetchUserInfo(email);
        if (userInfo != null) {
          List<String> collectedItems =
              List<String>.from(userInfo['collected_items'] ?? []);

          String newToy = _newToyOnLevel();

          if (!collectedItems.contains(newToy)) {
            collectedItems.add(newToy);
            await apiService.patchCollectedItems(email, collectedItems);
            _levelUpAlert(newLevel, newToy);
          }
        }
      }
    } catch (e) {
      return;
    }
  }

  String _newToyOnLevel() {
    List<String> toyValues = _toyMap.keys.toList();

    final random = Random();
    int randomIndex = random.nextInt(toyValues.length);

    return toyValues[randomIndex];
  }

  void _levelUpAlert(int level, String newToy) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromRGBO(33, 33, 33, 0.9),
          title: const Text(
            'LEVEL UP!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'You have reached Lvl. $level and acquired a new item:',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                width: 200,
                child: ModelViewer(
                  src: _toyMap[newToy] ?? '',
                  alt: newToy,
                  ar: false,
                  autoRotate: true,
                  cameraControls: true,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void dispose() {
    pedometerSubscription?.cancel();
  }

  final Map<String, String> _toyMap = {
    'ball_thrower': 'assets/toys/ball_thrower_blue.glb',
    'bone': 'assets/toys/bone_grey.glb',
    'snack_holder': 'assets/toys/snack_holder_red.glb',
    'dog_toys': 'assets/toys/dog_toys.glb',
    'carrot': 'assets/toys/carrot.glb'
  };
}
