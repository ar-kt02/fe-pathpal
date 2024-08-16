import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SizedBox.expand(
        child: Center(
          child: Text(
            "Home Page initial",
            style: TextStyle(fontSize: 30),
          ),
        ),
      ),
    );
  }
}
