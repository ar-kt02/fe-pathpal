import 'package:flutter/material.dart';
import '../utils/step_tracker.dart';
import '../widgets/gauge_tracker.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  StatsPageState createState() => StatsPageState();
}

class StatsPageState extends State<StatsPage> {
  late StepTracker _stepTracker;
  int _todaySteps = 0;
  int _totalSteps = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _stepTracker = StepTracker(stepsUpdateHandler: _stepsUpdateHandler);
    _stepTracker.initialiseData().then((_) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _stepTracker.dispose();
    super.dispose();
  }

  void _stepsUpdateHandler(int todaySteps, int totalSteps) {
    setState(() {
      _todaySteps = todaySteps;
      _totalSteps = totalSteps;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF00C9FF),
              Color(0xFF92FE9D),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Total Steps:\n $_totalSteps',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GaugeTracker(todaySteps: _todaySteps),
                  ],
                ),
        ),
      ),
    );
  }
}
