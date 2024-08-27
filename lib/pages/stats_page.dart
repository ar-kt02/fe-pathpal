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
      appBar: AppBar(
        title: const Text("Stats",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            )),
        backgroundColor: const Color.fromARGB(255, 101, 111, 255),
        centerTitle: true,
        elevation: 4.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Total Steps:',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$_totalSteps',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                    const SizedBox(height: 30),
                    GaugeTracker(todaySteps: _todaySteps),
                  ],
                ),
        ),
      ),
    );
  }
}
