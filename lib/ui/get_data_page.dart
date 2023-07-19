import 'package:flutter/material.dart';
import 'package:http/http.dart';

class GetDataPage extends StatelessWidget {
  const GetDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const GetDataScreen(title: 'Get Data Test');
  }
}

class GetDataScreen extends StatefulWidget {
  const GetDataScreen({super.key, required this.title});

  final String title;

  @override
  State<GetDataScreen> createState() => GetDataState();
}

class GetDataState extends State<GetDataScreen> {
  final String apiUrl = "https://reqres.in/api/users?per_page=15";
  int _counter = 0;
  double _flowRate = 0;
  double _calculatedDebit = 0;
  double _level = 0;
  double _temperature = 0;
  double _pressure = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  double reqFlowRate() {
    return 0;
  }

  double reqCalculatedDebit() {
    return 0;
  }

  double reqLevel() {
    return 0;
  }

  double reqTemperature() {
    return 0;
  }

  double reqTressure() {
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Flow Rate: '),
              Text('Calculated Debit: '),
              Text('Level: '),
              Text('Temperature: '),
              Text('Pressure: '),
            ],
          ),
        ));
  }
}
