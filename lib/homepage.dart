import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'connect_page.dart';
import 'controllers/bluetooth_controller.dart';
import 'package:permission_handler/permission_handler.dart';
import 'connectPage2.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _locationPermissionGranted = false;
  final Permission _locationPermission = Permission.location;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final PermissionStatus status = await _locationPermission.status;
    if (status.isGranted) {
      setState(() {
        _locationPermissionGranted = true;
      });
    } else {
      final Map<Permission, PermissionStatus> result = await [
        _locationPermission,
        Permission.bluetooth,
      ].request();
      if (result[_locationPermission]!.isGranted) {
        setState(() {
          _locationPermissionGranted = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<BluetoothController>(
        init: BluetoothController(),
        builder: (controller) {
          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  color: Colors.deepPurple,
                  child: const Center(
                    child: Text(
                      " Bluetooth App ",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_locationPermissionGranted) {
                        controller.scanDevices();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Location permission required'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.deepPurple,
                      minimumSize: const Size(350, 55),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                    ),
                    child: const Text(
                      "Scan",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Obx(
                  () {
                    if (controller.isScanning.value) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (controller.deviceList.isEmpty) {
                      return const Center(
                        child: Text("No devices found"),
                      );
                    } else {
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: controller.deviceList.length,
                        itemBuilder: (context, index) {
                          final scanResult = controller.deviceList[index];
                          final device = scanResult.device;

                          return GestureDetector(
                            onTap: () async {
                              // Connect to the selected device
                              if (_locationPermissionGranted) {
                                // Connect to the selected device
                                await controller.connectToDevice(device);

                                print("checking connected or not");
                                // Check if the connection was successful
                                if (controller.isConnected.value) {
                                  // Navigate to the connected page
                                  print("device connected");

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ConnectedPage2(
                                        deviceName:
                                            device.name ?? 'Unknown devices',
                                        device: device,
                                      ),
                                    ),
                                  );
                                } else {
                                  print("device not connected");
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Location permission required'),
                                  ),
                                );
                              }
                            },
                            child: Card(
                              elevation: 2,
                              child: ListTile(
                                title: Text(device.name ?? 'Unknown Device'),
                                subtitle: Text(device.id.toString()),
                                trailing: Text(scanResult.rssi.toString()),
                              ),
                            ),
                          );
                        },
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
}
