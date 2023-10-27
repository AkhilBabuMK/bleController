import 'package:customeble/ble_controller.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Initialize a set to store unique iBeacon data
  Set<Map<String, dynamic>> iBeaconDataSet = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("BRAILLUME"),
        centerTitle: true,
      ),
      body: GetBuilder<BleController>(
        init: BleController(),
        builder: (controller) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 15,
                ),
                ElevatedButton(
                  onPressed: () => controller.scanDevices(),
                  child: Text("Scan"),
                ),
                SizedBox(
                  height: 15,
                ),
                StreamBuilder<List<ScanResult>>(
                  stream: controller.scanResults,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: snapshot.data!.map((data) {
                              final deviceName = data.device.name;
                              final deviceId = data.device.id.id;
                              final rssi = data.rssi.toString();
                              final iBeaconData = parseIBeaconData(
                                  data.advertisementData,
                                  deviceName,
                                  deviceId,
                                  rssi);

                              if (iBeaconData != null) {
                                iBeaconDataSet.add(iBeaconData);
                              }

                              // Only create ListTile if iBeaconData is not null
                              if (iBeaconData != null) {
                                return Card(
                                  elevation: 2,
                                  child: ListTile(
                                    title: Text(deviceName),
                                    subtitle: Text(
                                        '$deviceId - RSSI: $rssi\n${iBeaconData["iBeaconData"]}'),
                                  ),
                                );
                              } else {
                                return SizedBox
                                    .shrink(); // Return an empty widget if iBeaconData is null
                              }
                            }).toList(),
                          ),
                        ),
                      );
                    } else {
                      return Center(
                        child: Text("No Device Found"),
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Map<String, dynamic>? parseIBeaconData(
      AdvertisementData data, String deviceName, String deviceId, String rssi) {
    if (data.manufacturerData.containsKey(76)) {
      final iBeaconBytes = data.manufacturerData[76];
      print(iBeaconBytes);

      if (iBeaconBytes != null && iBeaconBytes.length >= 22) {
        final uuid = iBeaconBytes.sublist(2, 18);
        final major = iBeaconBytes.sublist(18, 20);
        final minor = iBeaconBytes.sublist(20, 22);

        final formattedUUID = uuidToString(uuid);
        final majorValue = bytesToInt(major);
        final minorValue = bytesToInt(minor);
        print(majorValue);
        print(minorValue);
        return {
          'deviceName': deviceName,
          'deviceId': deviceId,
          'rssi': rssi,
          'iBeaconData':
              'UUID: $formattedUUID Major: $majorValue Minor: $minorValue',
        };
      }
    }
    return null;
  }

  String uuidToString(List<int> bytes) {
    final buffer = StringBuffer();
    for (final byte in bytes) {
      buffer.write(byte.toRadixString(16).padLeft(2, '0'));
    }

    final formatted = buffer.toString();
    return '${formatted.substring(0, 8)}-${formatted.substring(8, 12)}-${formatted.substring(12, 16)}-${formatted.substring(16, 20)}-${formatted.substring(20, 32)}';
  }

  int bytesToInt(List<int> bytes) {
    int value = 0;
    for (final byte in bytes) {
      value = (value << 8) | byte;
    }
    return value;
  }
}
