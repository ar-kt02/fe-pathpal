import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text('Home'), backgroundColor: Color(0xFFFF9E6E)),
      body: const SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 60,
              child: Center(
                child: Text(
                  "Name: Dag | Level: 500 | Steps: 5255",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            Card(
              child: SizedBox(
                height: 420,
                child: ModelViewer(
                  src: 'assets/shiba.glb',
                  alt: 'Shiba Inu model',
                  ar: true,
                  arModes: ['scene-viewer', 'webxr', 'quick-look'],
                  autoRotate: true,
                  disableZoom: true,
                  cameraControls: true,
                  iosSrc: 'assets/shiba.usdz',
                ),
              ),
            ),
            Card(
              child: SizedBox(
                height: 110,
                child: Center(
                  child: Text(
                    "Accessories",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
