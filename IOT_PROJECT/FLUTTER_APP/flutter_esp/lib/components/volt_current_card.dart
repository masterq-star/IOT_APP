import 'package:flutter/material.dart';
import 'package:flutter_esp/size_config.dart';

// ignore: must_be_immutable
class VoltCurrentCard extends StatelessWidget {
  VoltCurrentCard(
      {Key? key,
      required this.volgate,
      required this.current,
      required this.power})
      : super(key: key);
  double volgate = 220.22;
  double current = 15;
  double power = 0;
  double energy = 0;
  double money = 0;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
          width: getProportionateScreenWidth(300),
          height: getProportionateScreenWidth(200),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment(0.8, 1),
                  colors: [
                    Color.fromARGB(255, 255, 251, 240),
                    Color.fromARGB(255, 201, 240, 225),
                    Color.fromARGB(255, 228, 222, 207)
                  ])),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const Spacer(),
                const Center(
                  child: Text(
                    'Electric managment',
                    style: TextStyle(
                        fontSize: 15,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Sora'),
                  ),
                ),
                Textvariable(
                    title: 'Volgate:', variable: volgate, unit: 'Volt'),
                Textvariable(variable: current, title: 'Current: ', unit: 'A'),
                Textvariable(variable: power, title: 'Power: ', unit: 'W'),
                Textvariable(variable: energy, title: 'Energy: ', unit: 'Wh'),
                Textvariable(variable: money, title: 'Money: ', unit: 'vnđ'),
                const Spacer()
              ],
            ),
          )),
    );
  }
}

// ignore: must_be_immutable
class Textvariable extends StatelessWidget {
  Textvariable(
      {Key? key,
      required this.variable,
      required this.title,
      required this.unit})
      : super(key: key);

  final double variable;
  String title;
  String unit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: title,
              style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                  fontFamily: 'Sora',
                  fontWeight: FontWeight.w300),
              children: <TextSpan>[
                TextSpan(
                  text: '$variable  $unit',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
