import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  int _stepsCount = 0;

  @override
  void initState() {
    super.initState();
    Pedometer.stepCountStream.listen((stepCount) {
      setState(() {
        _stepsCount = stepCount.steps;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Stats"), backgroundColor: const Color(0xFFFF9E6E)),
      body: Center(
        child: Text('Total Steps: $_stepsCount'),
      ),
    );
  }
}
