import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

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
  double _second = .0;
  final List<bool> _isSelectedList = [false];

  @override
  void initState() {
    super.initState();
    startMqttListener(_changeMqttMessage);
  }

  void _changeMqttMessage(String mqttMessage) {
    setState(() {
      _mqttMessage = mqttMessage;
      _second = double.parse(mqttMessage);
    });
  }

  Widget _buildRadialGauge() {
    return SizedBox(
      width: 200,
      height: 200,
      child: SfRadialGauge(
          title: const GaugeTitle(
              text: 'Seconds from MQTT',
              textStyle:
                  TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
          axes: <RadialAxis>[
            RadialAxis(minimum: 0, maximum: 60, ranges: <GaugeRange>[
              GaugeRange(
                  startValue: 0,
                  endValue: 50,
                  color: Colors.green,
                  startWidth: 10,
                  endWidth: 10),
              GaugeRange(
                  startValue: 50,
                  endValue: 100,
                  color: Colors.orange,
                  startWidth: 10,
                  endWidth: 10),
              GaugeRange(
                  startValue: 100,
                  endValue: 150,
                  color: Colors.red,
                  startWidth: 10,
                  endWidth: 10)
            ], pointers: <GaugePointer>[
              NeedlePointer(value: _second)
            ], annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                  widget: Container(
                    child: Text(
                      _mqttMessage,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  angle: 90,
                  positionFactor: 0.5)
            ]),
          ]),
    );
  }

  Widget _buildToggleButtons() {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        shape: const RoundedRectangleBorder(),
        side: const BorderSide(width: 2, color: Colors.red),
      ),
      onPressed: () {
        setState(() {
          _isSelectedList[0] = !_isSelectedList[0];
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ToggleButtons(
          isSelected: _isSelectedList,
          onPressed: (int index) {},
          children: const <Widget>[
            Icon(
              Icons.ac_unit,
              size: 150,
            ),
          ],
        ),
      ),
    );
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
              style: TextStyle(fontSize: 26),
            ),
            const SizedBox(height: 25),
            Text(
              _mqttMessage,
              style: Theme.of(context).textTheme.headline4,
            ),
            _buildRadialGauge(),
            _buildToggleButtons(),
          ],
        ),
      ),
    );
  }
}
