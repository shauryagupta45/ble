import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_blue_plus/gen/flutterblueplus.pbjson.dart';

class data {
  late String serviceid;
  late String charid;
  late String readid;
  late String writeid;
}

class ConnectedPage extends StatefulWidget {
  final String deviceName;
  final BluetoothDevice device;

  const ConnectedPage({
    Key? key,
    required this.deviceName,
    required this.device,
  }) : super(key: key);

  @override
  _ConnectedPageState createState() => _ConnectedPageState();
}

class _ConnectedPageState extends State<ConnectedPage> {
  String readUUID = '1';
  String writeUUID = '2';
  List<data> readData = [];

  bool showData = false;

  Future<void> readCharacteristics() async {
    // Discover the services of the device
    List<BluetoothService> services = await widget.device.discoverServices();

    // Iterate through the services
    for (BluetoothService service in services) {
      // Iterate through the characteristics of the service
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        // Read the UUIDs of the service and characteristic
        String serviceUUID = service.uuid.toString();
        String characteristicUUID = characteristic.uuid.toString();

        if (characteristic.properties.read) {
          readUUID = characteristic.uuid.toString();
        }

        if (characteristic.properties.write) {
          writeUUID = characteristic.uuid.toString();
        }

        data obj = data();
        obj.serviceid = serviceUUID;
        obj.charid = characteristicUUID;
        obj.readid = readUUID;
        obj.writeid = writeUUID;

        setState(() {
          readData.add(obj);
        });

        // Use the UUIDs as needed
        print('Service UUID: $serviceUUID');
        print('Characteristic UUID: $characteristicUUID');
        print('Read UUID: $readUUID');
        print('Write UUID: $writeUUID');
      }
    }

    setState(() {
      showData = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connected'),
        actions: [
          IconButton(
            onPressed: () => _disconnectDevice(context),
            icon: const Text("Disconnect"),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await readCharacteristics();
              },
              child: const Text("READ"),
            ),
            if (showData)
              Expanded(
                child: ListView.builder(
                  itemCount: readData.length,
                  itemBuilder: (BuildContext context, int index) {
                    data obj = readData[index];
                    return ListTile(
                      title: Text('Service ID: ${obj.serviceid}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Characteristic ID: ${obj.charid}'),
                          Text('Read ID: ${obj.readid}'),
                          Text('Write ID: ${obj.writeid}'),
                          const Text(
                              '--------------------------------------------'),
                        ],
                      ),
                    );
                  },
                ),
              )
          ],
        ),
      ),
    );
  }

  void _disconnectDevice(BuildContext context) async {
    try {
      // Disconnect the device
      await widget.device.disconnect();

      // Navigate back to the home page
      Navigator.pop(context);
    } catch (e) {
      if (kDebugMode) {
        print('Error disconnecting from device: $e');
      }
    }
  }
}
