import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Card(
                  child: SizedBox(
                      height: 50,
                      child: Center(
                        child: Text("Pet Name: test | Level: 500, Steps: 5255",
                            style: TextStyle(fontSize: 20)),
                      ))),
              Card(
                child: SizedBox(
                  height: 500,
                  child: Flutter3DViewer(
                    src: 'assets/shiba.glb',
                    progressBarColor: Colors.amber,
                  ),
                ),
              ),
              Card(
                child: SizedBox(
                  height: 110,
                  child: Center(
                    child: Text(
                      "Accesories",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
