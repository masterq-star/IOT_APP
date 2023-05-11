// ignore_for_file: non_constant_identifier_names, avoid_print, must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_esp/Service/MQTTManager.dart';
import 'package:flutter_esp/size_config.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_svg/flutter_svg.dart';

// ignore: must_be_immutable
class CardControlDevice extends StatefulWidget {
  CardControlDevice(
      {Key? key,
      required this.manager,
      required this.state_d1,
      required this.state_d2,
      required this.state_d3,
      required this.state_d4})
      : super(key: key);
  // ignore: non_constant_identifier_names
  MQTTManager manager;
  bool state_d1;
  bool state_d2;
  bool state_d3;
  bool state_d4;

  @override
  State<CardControlDevice> createState() => _CardControlDeviceState();
}

class _CardControlDeviceState extends State<CardControlDevice> {
  // String parse_json_data(int data) {
  //   String jsonData = "";
  //   jsonData = "{\"data\":$data}";
  //   return jsonData;
  // }
  void toggle_d1() {
    setState(() {
      widget.state_d1 = !widget.state_d1;
    });
    print(get_data_device());
    upload(get_data_device());

    // _manager.publish(parse_json_data(get_data_device()),"test");
  }

  void toggle_d2() {
    setState(() {
      widget.state_d2 = !widget.state_d2;
    });
    print(get_data_device());
    upload(get_data_device());
    // _manager.publish(parse_json_data(get_data_device()),"test");
  }

  void toggle_d3() {
    setState(() {
      widget.state_d3 = !widget.state_d3;
    });
    print(get_data_device());
    upload(get_data_device());
    //  _manager.publish(parse_json_data(get_data_device()),"test");
  }

  void toggle_d4() {
    setState(() {
      widget.state_d4 = !widget.state_d4;
    });
    print(get_data_device());
    upload(get_data_device());
    // _manager.publish(parse_json_data(get_data_device()),"test");
  }

  int get_data_device() {
    int data = 0;
    if (widget.state_d1) {
      data += 1;
    } else {
      data += 0;
    }
    if (widget.state_d2) {
      data += 2;
    } else {
      data += 0;
    }
    if (widget.state_d3) {
      data += 4;
    } else {
      data += 0;
    }
    if (widget.state_d4) {
      data += 8;
    } else {
      data += 0;
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Center(
          child: Text(
            "Control Device",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w300,
                fontFamily: 'Sora',
                color: Colors.black),
          ),
        ),
        Row(
          children: [
            const Spacer(),
            CardDevice(
              link_svg_file: "access/icon/house.svg",
              Tap: () {
                toggle_d1();
              },
              color: widget.state_d1
                  ? const Color.fromARGB(255, 69, 171, 189)
                  : const Color.fromARGB(255, 241, 239, 239),
            ),
            const Spacer(),
            CardDevice(
              link_svg_file: "access/icon/fan.svg",
              Tap: () {
                toggle_d2();
              },
              color: widget.state_d2
                  ? const Color.fromARGB(255, 69, 171, 189)
                  : const Color.fromARGB(255, 241, 239, 239),
            ),
            const Spacer()
          ],
        ),
        Row(
          children: [
            const Spacer(),
            CardDevice(
              link_svg_file: "access/icon/internet.svg",
              Tap: () {
                toggle_d3();
              },
              color: widget.state_d3
                  ? const Color.fromARGB(255, 69, 171, 189)
                  : const Color.fromARGB(255, 241, 239, 239),
            ),
            const Spacer(),
            CardDevice(
              link_svg_file: "access/icon/wifi.svg",
              Tap: () {
                toggle_d4();
              },
              color: widget.state_d4
                  ? const Color.fromARGB(255, 69, 171, 189)
                  : const Color.fromARGB(255, 241, 239, 239),
            ),
            const Spacer()
          ],
        )
      ],
    );
  }

  void upload(int data) {
    String jsonData = "{\"data\":$data}";
    try {
      widget.manager.publish(jsonData, "B4E62DB826BD_D");
    } on Exception catch (e) {
      print(e.toString());
    }
  }
}

class CardDevice extends StatelessWidget {
  CardDevice(
      {Key? key,
      required this.link_svg_file,
      required this.Tap,
      required this.color})
      : super(key: key);
  Function Tap;
  Color color;
  final String link_svg_file;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(10, 20, 10, 20),
      shadowColor: Colors.blueGrey,
      color: color,
      elevation: 5,
      shape: RoundedRectangleBorder(
        //side: BorderSide(color: Color.fromARGB(179, 182, 0, 0), width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          onTap: () {
            Tap();
          },
          child: SizedBox(
            width: getProportionateScreenWidth(100),
            height: getProportionateScreenWidth(100),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SvgPicture.asset(link_svg_file),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
