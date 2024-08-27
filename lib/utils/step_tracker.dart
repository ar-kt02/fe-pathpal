import 'dart:async';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class StepTracker {
  int todaySteps = 0;
  int totalSteps = 0;
  int stepsToTriggerPatch = 0;
  int lastPedometerCount = 0;
  String email = "";
  StreamSubscription<StepCount>? pedometerSubcription;

  final Function(int, int) stepsUpdateHandler;

  StepTracker({required this.stepsUpdateHandler});

  Future<void> initialiseData() async {
    await _accessEmail();

    if (email.isNotEmpty) {
      await _fetchInitialData();
      _runPedometer();
    }
  }

  Future<void> _fetchInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    final apiService = ApiService();

    try {
      final userInfo = await apiService.fetchUserInfo(email);

      if (userInfo != null) {
        todaySteps = userInfo['step_details']['todays_steps'] ?? 0;
        totalSteps = userInfo['step_details']['total_steps'] ?? 0;
        lastPedometerCount =
            prefs.getInt('lastPedometerCountLocal') ?? todaySteps;

        await _updateLocalData();
        stepsUpdateHandler(todaySteps, totalSteps);
      }
    } catch (err) {
      return;
    }
  }

  Future<void> _accessEmail() async {
    final prefs = await SharedPreferences.getInstance();
    email = prefs.getString("email") ?? "";
  }

  void _runPedometer() {
    pedometerSubcription = Pedometer.stepCountStream.listen((stepCount) {
      _updateSteps(stepCount.steps);
    });
  }

  Future<void> _updateSteps(int newPedometerCount) async {
    if (newPedometerCount < lastPedometerCount) {
      lastPedometerCount = newPedometerCount;
      return;
    }

    int stepIncrease = newPedometerCount - lastPedometerCount;
    lastPedometerCount = newPedometerCount;

    if (stepIncrease > 0) {
      todaySteps += stepIncrease;
      totalSteps += stepIncrease;
      stepsToTriggerPatch += stepIncrease;

      await _updateLocalData();
      stepsUpdateHandler(todaySteps, totalSteps);

      if (stepsToTriggerPatch >= 50) {
        await _patchUserSteps();
        stepsToTriggerPatch = 0;
      }
    }
  }

  Future<void> _updateLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastPedometerCountLocal', lastPedometerCount);
  }

  Future<void> _patchUserSteps() async {
    try {
      final apiService = ApiService();
      await apiService.patchUserSteps(email, todaySteps, totalSteps);
    } catch (e) {
      return;
    }
  }

  void dispose() {
    pedometerSubcription?.cancel();
  }
}
