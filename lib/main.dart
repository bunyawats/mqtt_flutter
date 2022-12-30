import 'dart:async';

import 'package:flutter/material.dart';
import 'services/mqtt_client.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Mqtt Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _mqttMessage = "";

  @override
  void initState() {
    super.initState();
    startMqttListener(_changeMqttMessage);
  }

  void _changeMqttMessage(String mqttMessage) {
    setState(() {
      _mqttMessage = mqttMessage;
    });
  }

  @override
  Widget build(BuildContext context) {
    const instruction = 'MQTT Message:';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              instruction,
              style: TextStyle( fontSize: 26),
            ),
            const SizedBox(height: 25),
            Text(
              _mqttMessage,
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
    );
  }
}
