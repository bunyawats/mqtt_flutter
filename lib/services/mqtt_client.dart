import 'dart:async';
import 'dart:io';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

final client = MqttServerClient('10.0.2.2', '');


Future<void>  startMqttListener (void Function(String mqttMessage) changeMqttMessage) async{

  client.logging(on: true);
  client.setProtocolV311();
  client.keepAlivePeriod = 20;
  client.connectTimeoutPeriod = 2000; // milliseconds
  client.onDisconnected = onDisconnected;
  client.onConnected = onConnected;
  client.onSubscribed = onSubscribed;
  client.pongCallback = pong;

  /// Create a connection message to use or use the default one. The default one sets the
  /// client identifier, any supplied username/password and clean session,
  /// an example of a specific one below.
  final connMess = MqttConnectMessage()
      .withClientIdentifier('Mqtt_MyClientUniqueId')
      .withWillTopic('willtopic') // If you set this you must set a will message
      .withWillMessage('My Will message')
      .startClean() // Non persistent session for testing
      .withWillQos(MqttQos.atLeastOnce);
  print('EXAMPLE::Mosquitto client connecting....');
  client.connectionMessage = connMess;


  try {
    await client.connect();
  } on NoConnectionException catch (e) {
    // Raised by the client when connection fails.
    print('EXAMPLE::client exception - $e');
    client.disconnect();
  } on SocketException catch (e) {
    // Raised by the socket layer
    print('EXAMPLE::socket exception - $e');
    client.disconnect();
  }

  /// Check we are connected
  if (client.connectionStatus!.state == MqttConnectionState.connected) {
    print('EXAMPLE::Mosquitto client connected');
  } else {
    /// Use status here rather than state if you also want the broker return code.
    print(
        'EXAMPLE::ERROR Mosquitto client connection failed - disconnecting, status is ${client.connectionStatus}');
    client.disconnect();
  }

  /// Ok, lets try a subscription
  print('EXAMPLE::Subscribing to the test/lol topic');
  const topic = 'test'; // Not a wildcard topic
  client.subscribe(topic, MqttQos.atMostOnce);


  client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
    final recMess = c![0].payload as MqttPublishMessage;
    final pt =
    MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

    print(
        'EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
    print('');

    changeMqttMessage("$pt");
  });


  // var counter = 15;
  // Timer.periodic(const Duration(seconds: 2), (timer) {
  //   changeMqttMessage("${timer.tick}");
  // });


}

/// The subscribed callback
void onSubscribed(String topic) {
  print('EXAMPLE::Subscription confirmed for topic $topic');
}

/// The unsolicited disconnect callback
void onDisconnected() {
  print('EXAMPLE::OnDisconnected client callback - Client disconnection');
}

/// The successful connect callback
void onConnected() {
  print(
      'EXAMPLE::OnConnected client callback - Client connection was successful');
}

void pong() {
  print('EXAMPLE::Ping response client callback invoked');
}
