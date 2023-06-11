import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';

class BluetoothController extends GetxController {
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  RxList<ScanResult> deviceList = <ScanResult>[].obs;
  RxBool isScanning = false.obs;
  RxBool isConnected = false.obs;

  BluetoothDevice? connectedDevice; // Store the connected device

  Future<void> scanDevices() async {
    try {
      isScanning.value = true;

      // Clear previous scan results
      deviceList.clear();

      // Scan for 5 seconds
      final scanResults = await flutterBlue
          .scan(
            timeout: const Duration(seconds: 3),
          )
          .toList();

      deviceList.addAll(scanResults);
    } finally {
      isScanning.value = false;
    }
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      // Stop scanning if it's currently ongoing
      if (isScanning.value) {
        await flutterBlue.stopScan();
      }

      // Connect to the device
      await device.connect();

      // Discover services and characteristics
      await device.discoverServices();
      // Update connection state and connected device
      isConnected.value = true;
      connectedDevice = device;
    } catch (e) {
      if (kDebugMode) {
        print('Error connecting to device: $e');
      }
    }
  }

  Future<void> disconnectDevice() async {
    try {
      if (connectedDevice != null) {
        // Disconnect the device
        await connectedDevice!.disconnect();
        // Update connection state and connected device
        isConnected.value = false;
        connectedDevice = null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error disconnecting from device: $e');
      }
    }
  }
}
