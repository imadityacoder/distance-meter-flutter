import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DistanceSensorPage(),
    );
  }
}

class DistanceSensorPage extends StatefulWidget {
  const DistanceSensorPage({super.key});

  @override
  _DistanceSensorPageState createState() => _DistanceSensorPageState();
}

class _DistanceSensorPageState extends State<DistanceSensorPage> {
  String distance = "0.0";
  late SerialPort port;
  late SerialPortReader reader;
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    initSerial();
  }

  Future<void> initSerial() async {
  try {
    final availablePorts = SerialPort.availablePorts;
    print("Available ports: $availablePorts");
    String mainPort = availablePorts[0];
    print(mainPort);
    if (availablePorts.isNotEmpty) {
      print('starting');
      port = SerialPort(mainPort); // Replace with specific port if needed
      print(port);

      if (port.openReadWrite()) {
        setState(() {
          isConnected = true;
        });

        reader = SerialPortReader(port);
        reader.stream.listen((data) {
          setState(() {
            distance = String.fromCharCodes(data).trim();
          });
        });
      } else {
        print("Failed to open port.");
      }
    } else {
      print("No available ports found.");
    }
  } catch (e) {
    print("Error initializing serial port: $e");
  }
}


  @override
  void dispose() {
    if (isConnected) {
      reader.close();
      port.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Distance Measurement")),
      body: Center(
        child: Text(
          isConnected
              ? "Distance:\n $distance cm"
              : "Connecting to the sensor...",
          style: TextStyle(fontSize: 40),
        ),
      ),
    );
  }
}
