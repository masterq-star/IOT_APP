// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:flutter_esp/Service/MQTTAppState.dart';

class MQTTManager extends ChangeNotifier {
  // Private instance of client
  final MQTTAppState _currentState = MQTTAppState();
  final MqttServerClient _client =
      MqttServerClient.withPort('103.101.162.184', 'flutter_test', 1883);
  String _topic = "";

  void initializeMQTTClient() {
    // Save the values
    _client.keepAlivePeriod = 20;
    _client.secure = false;
    _client.autoReconnect = true;
    _client.pongCallback = pong;
    _client.logging(on: true);

    /// Add the successful connection callback
    _client.onDisconnected = onDisconnected;
    _client.onConnected = onConnected;
    _client.onSubscribed = onSubscribed;
    _client.onUnsubscribed = onUnsubscribed;

    final connMess = MqttConnectMessage()
        .withClientIdentifier("flutter_test")
        .authenticateAs("test", "test")
        .withWillTopic('willtopic')
        .withWillMessage('My Will message')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    print('EXAMPLE::Mosquitto client connecting....');
    _client.connectionMessage = connMess;
  }

  MQTTAppState get currentState => _currentState;
  // Connect to the host
  void connect() async {
    initializeMQTTClient();
    print("try connect to mqtt server");
    assert(_client != null);
    try {
      print('EXAMPLE::Mosquitto start client connecting....');
      _currentState.setAppConnectionState(MQTTAppConnectionState.connecting);
      updateState();
      await _client.connect();
    } on Exception catch (e) {
      print('EXAMPLE::client exception - $e');
      disconnect();
    }
  }

  void disconnect() {
    print('Disconnected');
    _client.disconnect();
  }

  void publish(String message, String topic) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);
    _client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
  }

  /// The subscribed callback
  void onSubscribed(String topic) {
    print('EXAMPLE::Subscription confirmed for topic $topic');
    _currentState
        .setAppConnectionState(MQTTAppConnectionState.connectedSubscribed);
    updateState();
  }

  void onUnsubscribed(String? topic) {
    print('EXAMPLE::onUnsubscribed confirmed for topic $topic');
    _currentState.clearText();
    _currentState
        .setAppConnectionState(MQTTAppConnectionState.connectedUnSubscribed);
    updateState();
  }

  /// The unsolicited disconnect callback
  void onDisconnected() {
    print('EXAMPLE::OnDisconnected client callback - Client disconnection');
    if (_client.connectionStatus!.returnCode ==
        MqttConnectReturnCode.noneSpecified) {
      print('EXAMPLE::OnDisconnected callback is solicited, this is correct');
    }
    _currentState.clearText();
    _currentState.setAppConnectionState(MQTTAppConnectionState.disconnected);
    updateState();
  }

  /// The successful connect callback
  void onConnected() {
    _currentState.setAppConnectionState(MQTTAppConnectionState.connected);
    updateState();
    print('EXAMPLE::Mosquitto client connected....');
    _client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
      final String pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      _currentState.setReceivedText(pt);
      updateState();
      print(
          'EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
      print('');
    });
    print(
        'EXAMPLE::OnConnected client callback - Client connection was sucessful');
  }

  void subScribeTo(String topic) {
    // Save topic for future use
    _topic = topic;

    try {
      _client.subscribe(topic, MqttQos.atLeastOnce);
    } catch (e) {
      print(e.toString());
    }
  }

  /// Unsubscribe from a topic
  void unSubscribe(String topic) {
    _client.unsubscribe(topic);
  }

  /// Unsubscribe from a topic
  void unSubscribeFromCurrentTopic() {
    _client.unsubscribe(_topic);
  }

  void updateState() {
    //controller.add(_currentState);
    notifyListeners();
  }

  void pong() {
    print('Ping response client callback invoked');
  }
}
