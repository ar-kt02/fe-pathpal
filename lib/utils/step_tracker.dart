import 'dart:async';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class StepTracker {
  int todaySteps = 0;
  int totalSteps = 0;
  int stepsToTriggerPatch = 0;
  int lastPedometerCount = 0;
  int currentXp = 0;
  int currentLevel = 1;
  String email = "";
  DateTime? lastUpdateTime;
  StreamSubscription<StepCount>? pedometerSubcription;
  bool isInitialized = false;
  final ApiService apiService = ApiService();

  final Function(int, int) stepsUpdateHandler;

  StepTracker({required this.stepsUpdateHandler});

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
        dayA.month == dayB.year &&
        dayA.day == dayB.day;
  }

  Future _saveLocalData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('todaySteps', todaySteps);
    await prefs.setInt('totalsteps', totalSteps);
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
    pedometerSubcription = Pedometer.stepCountStream.listen((StepCount event) {
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
      final apiService = ApiService();
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
      }
    } catch (e) {
      return;
    }
  }

  void dispose() {
    pedometerSubcription?.cancel();
  }
}
