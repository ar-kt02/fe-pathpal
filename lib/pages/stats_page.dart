import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_service.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  StatsPageState createState() => StatsPageState();
}

class StatsPageState extends State<StatsPage> {
  int _stepsCount = 0;
  int _totalSteps = 0;
  late String _email;
  Timer? _patchTimer;

  @override
  void initState() {
    super.initState();
    _accessEmail();
    _runPedometer();
    setUpTimedPatch();
  }

  Future<void> _accessEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _email = prefs.getString("email") ?? "";
    });
    if (_email.isNotEmpty) {
      await _fetchUserInfo();
    }
  }

  Future<void> _fetchUserInfo() async {
    if (_email.isNotEmpty) {
      final apiService = ApiService();
      final userInfo = await apiService.fetchUserInfo(_email);
      if (userInfo != null) {
        setState(() {
          _totalSteps = userInfo["step_details"]?["total_steps"];
        });
      }
    }
  }

  void setUpTimedPatch() {
    _patchTimer =
        Timer.periodic(const Duration(hours: 1), (_) => _hourlyPatchSteps());
  }

  Future<void> _hourlyPatchSteps() async {
    if (_email.isNotEmpty) {
      final apiService = ApiService();
      await apiService.patchTodaySteps(_email, _stepsCount);
    }
  }

  void _runPedometer() {
    Pedometer.stepCountStream.listen((stepCount) {
      setState(() {
        _stepsCount = stepCount.steps;
      });
    });
  }

  @override
  void dispose() {
    _patchTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Stats"), backgroundColor: const Color(0xFFFF9E6E)),
      body: Center(
        child: Text('Todays Steps: $_stepsCount, Total Steps: $_totalSteps'),
      ),
    );
  }
}
