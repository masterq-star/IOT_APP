// ignore_for_file: non_constant_identifier_names, depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_esp/Helper/service_locator.dart';
import 'package:flutter_esp/Service/MQTTAppState.dart';
import 'package:flutter_esp/Service/MQTTManager.dart';
import 'package:flutter_esp/components/card_control.dart';
import 'package:flutter_esp/components/temp_humi_gauge.dart';
import 'package:flutter_esp/components/volt_current_card.dart';
import 'package:flutter_esp/size_config.dart';
import 'package:provider/provider.dart';

void main() {
  setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MQTTManager>(
      create: (context) => service_locator<MQTTManager>(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late MQTTManager _manager = MQTTManager();

  void ConnectMqtt() {
    Future.delayed(const Duration(microseconds: 100), () => _manager.connect());
    Future.delayed(const Duration(seconds: 4),
        () => _manager.subScribeTo("B4E62DB826BD_U"));
    print(_manager.currentState.getAppConnectionState);
  }

  @override
  void dispose() {
    // ignore: todo
    // TODO: implement dispose
    Future.delayed(const Duration(microseconds: 300),
        () => _manager.unSubscribeFromCurrentTopic());
    Future.delayed(
        const Duration(microseconds: 600), () => _manager.disconnect());
    super.dispose();
  }

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    ConnectMqtt();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    _manager = Provider.of<MQTTManager>(context);
    return SafeArea(
      child: Scaffold(
        // appBar: AppBar(
        //   title: Text(widget.title),
        // ),
        body: Column(
          children: [
            GaugeTemHu(
                humi: _manager.currentState.gethum,
                temp: _manager.currentState.gettemp),
            CardControlDevice(
              manager: _manager,
              state_d1: _manager.currentState.getd1,
              state_d2: _manager.currentState.getd2,
              state_d3: _manager.currentState.getd3,
              state_d4: _manager.currentState.getd4,
            ),
            VoltCurrentCard(
              volgate: _manager.currentState.getvolt,
              current: _manager.currentState.getcurrent,
              power: _manager.currentState.getPower,
            ),
            // ElevatedButton(
            //     onPressed: () {
            //       _manager.subScribeTo("topic_test");
            //     },
            //     child: const Text("subrice")),
          ],
        ),
      ),
    );
  }
}
