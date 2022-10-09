import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';

import 'device.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final flutterBlue = FlutterBlue.instance;

  List<ScanResult> scanResults = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    listenDevices();
  }

  Future<void> listenDevices() async {
    await Permission.bluetooth.request();
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
    setState(() {
      loading = true;
    });
    flutterBlue.startScan(timeout: const Duration(seconds: 10));
    flutterBlue.scanResults.listen((results) {
      setState(() {
        scanResults = results;
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth test'),
      ),
      body: loading
          ? Column(
              children: const [
                Text('Looking for devices...'),
                CircularProgressIndicator(),
              ],
            )
          : ListView(
              children: scanResults
                  .map(
                    (result) => ListTile(
                      title: Text(
                        result.device.name.isEmpty
                            ? 'Unknown device ${scanResults.indexOf(result)}'
                            : result.device.name,
                      ),
                      subtitle: Text(result.device.id.toString()),
                      trailing: const Icon(Icons.keyboard_arrow_right),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => DevicePage(
                            device: result.device,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}
