import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class GaugeTracker extends StatelessWidget {
  final int todaySteps;

  const GaugeTracker({super.key, required this.todaySteps});

  @override
  Widget build(BuildContext context) {
    return SfRadialGauge(
      enableLoadingAnimation: true,
      axes: <RadialAxis>[
        RadialAxis(
          showLabels: false,
          showTicks: false,
          radiusFactor: 1,
          maximum: 5000,
          axisLineStyle: const AxisLineStyle(
              cornerStyle: CornerStyle.startCurve, thickness: 5),
          annotations: <GaugeAnnotation>[
            GaugeAnnotation(
              angle: 90,
              widget: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text('$todaySteps',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          fontSize: 30)),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(0, 2, 0, 0),
                    child: Text(
                      'steps today',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          fontSize: 14),
                    ),
                  )
                ],
              ),
            ),
            const GaugeAnnotation(
              angle: 124,
              positionFactor: 1.1,
              widget: Text('0', style: TextStyle(fontSize: 14)),
            ),
            const GaugeAnnotation(
              angle: 54,
              positionFactor: 1.1,
              widget: Text('5000', style: TextStyle(fontSize: 14)),
            ),
          ],
          pointers: <GaugePointer>[
            RangePointer(
              value: todaySteps.toDouble(),
              width: 18,
              pointerOffset: -6.5,
              cornerStyle: CornerStyle.bothCurve,
              color: const Color(0xFFF67280),
              gradient: const SweepGradient(colors: <Color>[
                Color.fromARGB(255, 175, 118, 255),
                Color.fromARGB(255, 78, 122, 245)
              ], stops: <double>[
                0.25,
                0.75
              ]),
            ),
            MarkerPointer(
              value: todaySteps.toDouble() - 70,
              color: Colors.white,
              markerType: MarkerType.circle,
            ),
          ],
        ),
      ],
    );
  }
}
