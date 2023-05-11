// ignore_for_file: file_names

import 'dart:convert';
import 'dart:math';
import 'package:flutter_esp/models/Sensor.dart';

enum MQTTAppConnectionState {
  connected,
  disconnected,
  connecting,
  connectedSubscribed,
  connectedUnSubscribed
}

class MQTTAppState {
  MQTTAppConnectionState _appConnectionState =
      MQTTAppConnectionState.disconnected;
  String _receivedText = '';
  String _historyText = '';
  double hum = 0;
  double temp = 0;
  double volt = 0;
  double current = 0;
  double power = 0;
  int data = 0;
  bool d1 = false;
  bool d2 = false;
  bool d3 = false;
  bool d4 = false;
  ConvertToBool(int data) {
    if ((data & 1) > 0) {
      d1 = true;
    } else {
      d1 = false;
    }
    if ((data & 2) > 0) {
      d2 = true;
    } else {
      d2 = false;
    }
    if ((data & 4) > 0) {
      d3 = true;
    } else {
      d3 = false;
    }
    if ((data & 8) > 0) {
      d4 = true;
    } else {
      d4 = false;
    }
  }

  void setReceivedText(String text) {
    _receivedText = text;
    // _historyText = _historyText + '\n' + _receivedText;
    final json = jsonDecode(text);
    final sensor = Sensor.fromJson(json);
    data = sensor.data;
    hum = sensor.temp[1];
    temp = sensor.temp[0];
    volt = sensor.volt[0];
    current = sensor.volt[1];
    power = roundDouble((volt * current) / 1000, 5);
    ConvertToBool(data);
  }

  void setAppConnectionState(MQTTAppConnectionState state) {
    _appConnectionState = state;
  }

  void clearText() {
    _historyText = "";
    _receivedText = "";
  }

  double get gettemp => temp;
  double get gethum => hum;
  double get getvolt => volt;
  double get getcurrent => current;
  double get getPower => power;
  String get getReceivedText => _receivedText;
  String get getHistoryText => _historyText;
  int get getdata => data;
  bool get getd1 => d1;
  bool get getd2 => d2;
  bool get getd3 => d3;
  bool get getd4 => d4;

  MQTTAppConnectionState get getAppConnectionState => _appConnectionState;
}

double roundDouble(num value, num places) {
  num mod = pow(10.0, places);
  return ((value * mod).round().toDouble() / mod);
}
