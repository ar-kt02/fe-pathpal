import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Stats")),
      body: const Center(
          child: Text('Stats Page Initial', style: TextStyle(fontSize: 30))),
    );
  }
}
