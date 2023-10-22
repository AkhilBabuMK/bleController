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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("BLE SCANNER"),
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
                StreamBuilder<List<ScanResult>>(
                  stream: controller.scanResults,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final data = snapshot.data![index];
                          final deviceName = data.device.name;
                          final deviceId = data.device.id.id;
                          final rssi = data.rssi.toString();
                          final iBeaconData =
                              parseIBeaconData(data.advertisementData);

                          return Card(
                            elevation: 2,
                            child: ListTile(
                              title: Text(deviceName),
                              subtitle:
                                  Text('$deviceId - RSSI: $rssi\n$iBeaconData'),
                            ),
                          );
                        },
                      );
                    } else {
                      return Center(
                        child: Text("No Device Found"),
                      );
                    }
                  },
                ),
                ElevatedButton(
                  onPressed: () => controller.scanDevices(),
                  child: Text("Scan"),
                ),
                SizedBox(
                  height: 15,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String parseIBeaconData(AdvertisementData data) {
    // Assuming iBeacon data follows a specific format
    if (data.manufacturerData.containsKey(0x004C)) {
      final iBeaconBytes = data.manufacturerData[0x004C];
      // Extract and format iBeacon data as needed
      // iBeacon data typically includes proximity UUID, major, minor, and other information.
      return 'iBeacon Data: ${iBeaconBytes.toString()}';
    }
    return 'No iBeacon Data';
  }
}
