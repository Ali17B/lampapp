import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothManager {
  BluetoothConnection? connection;

  Future<List<BluetoothDevice>> getBondedDevices() async {
    return await FlutterBluetoothSerial.instance.getBondedDevices();
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    connection = await BluetoothConnection.toAddress(device.address);
  }

  void sendData(String message) {
    if (connection != null) {
      connection!.output.add(Uint8List.fromList(utf8.encode(message + '\r\n')));
    }
  }

  Stream<Uint8List>? get onDataReceived => connection?.input;

  void dispose() {
    connection?.close();
  }
}

class homePage extends StatefulWidget {
  const homePage({Key? key}) : super(key: key);

  @override
  _homePageState createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  final bluetoothManager = BluetoothManager();
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    _requestBluetoothPermissions();
  }

  // Bluetooth izinlerini isteyen metot
  Future<void> _requestBluetoothPermissions() async {
    if (await Permission.bluetoothConnect.request().isGranted) {
    } else {}
  }

  void _connectToBluetoothDevice() async {
    List<BluetoothDevice> devices = await bluetoothManager.getBondedDevices();
    try {
      BluetoothDevice hc06 =
          devices.firstWhere((device) => device.name == 'HC-06');
      await bluetoothManager.connectToDevice(hc06);
      bluetoothManager.onDataReceived?.listen((data) {
        //String receivedData = utf8.decode(data);
      });

      setState(() {
        isConnected = true;
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Hata'),
            content: Text('Bluetooth cihazına bağlanılamadı.'),
            actions: [
              TextButton(
                child: Text('Tamam'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _sendCommand(String command) {
    bluetoothManager.sendData(command);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(245, 245, 250, 0.959),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(245, 245, 250, 0.959),
        title: Text(
          'Led Kontrol',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.bluetooth),
            color: isConnected ? Colors.blue : Colors.grey,
            onPressed: isConnected ? null : _connectToBluetoothDevice,
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[],
            ),
          ),
          SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.only(left: 40, right: 40),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 45),
                  backgroundColor: Colors.red),
              onPressed: isConnected ? () => _sendCommand('1') : null,
              child: null,
            ),
          ),
        ],
      ),
    );
  }
}
