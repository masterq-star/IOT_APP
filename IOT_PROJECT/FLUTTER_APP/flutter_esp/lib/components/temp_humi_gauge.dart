// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_gauges/gauges.dart';

class GaugeTemHu extends StatelessWidget {
  GaugeTemHu({Key? key, required this.humi, required this.temp})
      : super(key: key);
  double temp;
  double humi;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const Center(
            child: Text(
              "Inside Humi and temp",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                  fontFamily: 'Sora'),
            ),
          ),
          Row(
            children: [
              const Spacer(),
              Gauge(
                value: temp,
                unit: "°C",
              ),
              Gauge(
                value: humi,
                unit: "%",
              ),
              const Spacer()
            ],
          ),
        ],
      ),
    );
  }
}

class Gauge extends StatelessWidget {
  Gauge({Key? key, required this.value, required this.unit}) : super(key: key);
  double value;
  String unit;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 150,
      child: SfRadialGauge(
        enableLoadingAnimation: true,
        axes: <RadialAxis>[
          RadialAxis(
              showLabels: false,
              showTicks: false,
              radiusFactor: 0.8,
              maximum: 100,
              axisLineStyle: const AxisLineStyle(
                  cornerStyle: CornerStyle.startCurve, thickness: 5),
              annotations: <GaugeAnnotation>[
                GaugeAnnotation(
                    angle: 90,
                    widget: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text('$value',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic)),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
                          child: Text(
                            unit,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      ],
                    )),
                const GaugeAnnotation(
                  angle: 124,
                  positionFactor: 1.1,
                  widget: Text('0', style: TextStyle(fontSize: 12)),
                ),
                const GaugeAnnotation(
                  angle: 54,
                  positionFactor: 1.1,
                  widget: Text('100', style: TextStyle(fontSize: 12)),
                ),
              ],
              pointers: <GaugePointer>[
                RangePointer(
                  value: value,
                  width: 10,
                  pointerOffset: -2,
                  cornerStyle: CornerStyle.bothCurve,
                  color: const Color(0xFFF67280),
                  gradient: const SweepGradient(colors: <Color>[
                    Color.fromARGB(255, 118, 246, 255),
                    Color.fromARGB(255, 1, 47, 253),
                  ], stops: <double>[
                    0.25,
                    0.75
                  ]),
                ),
                // MarkerPointer(
                //   value: 136,
                //   color: Colors.white,
                //   markerType: MarkerType.circle,
                // ),
              ]),
        ],
      ),
    );
  }
}
