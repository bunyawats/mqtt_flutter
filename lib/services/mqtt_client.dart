import 'dart:async';
import 'dart:io';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

final client = MqttServerClient('10.0.2.2', '');

const secondTopic = 'test';
const toggleTopic = 'test/toggle';

Future<void> connectMqttBroker() async {
  client.logging(on: true);
  client.setProtocolV311();
  client.keepAlivePeriod = 20;
  client.connectTimeoutPeriod = 2000; // milliseconds
  client.onDisconnected = onDisconnected;
  client.onConnected = onConnected;
  client.onSubscribed = onSubscribed;
  client.pongCallback = pong;

  final connMess = MqttConnectMessage()
      .withClientIdentifier('Mqtt_MyClientUniqueId')
      .withWillTopic('willtopic') // If you set this you must set a will message
      .withWillMessage('My Will message')
      .startClean() // Non persistent session for testing
      .withWillQos(MqttQos.atLeastOnce);
  client.connectionMessage = connMess;

  try {
    await client.connect();
  } on NoConnectionException catch (e) {
    client.disconnect();
  } on SocketException catch (e) {
    client.disconnect();
  }

  /// Check we are connected
  if (client.connectionStatus!.state != MqttConnectionState.connected) {
    client.disconnect();
  }
}

Future<void> startSecondListener(
    void Function(double second) changeMqttMessage) async {
  client.subscribe(secondTopic, MqttQos.atMostOnce);

  client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
    if (c![0].topic == secondTopic) {
      final recMess = c![0].payload as MqttPublishMessage;
      final pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      changeMqttMessage(double.parse(pt));
    }
  });
}

Future<void> startToggleUpdateListener(
    void Function(bool state) changeMqttMessage) async {
  client.subscribe(toggleTopic, MqttQos.atMostOnce);

  client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
    if (c![0].topic == toggleTopic) {
      final recMess = c![0].payload as MqttPublishMessage;
      final pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      changeMqttMessage(pt == "on");
    }
  });
}

void publishToggleButtonState(bool state) {
  final builder = MqttClientPayloadBuilder();
  builder.addString(state ? "on" : "off");

  client.publishMessage('test/toggle', MqttQos.exactlyOnce, builder.payload!);
}

void onSubscribed(String topic) {
  print('onSubscribed confirmed for topic $topic');
}

void onDisconnected() {
  print('onDisconnected client callback - Client disconnection');
}

void onConnected() {
  print('onConnected client callback - Client connection was successful');
}

void pong() {
  print('pong response client callback invoked');
}
