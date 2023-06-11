import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutterblueplus/terminal_model.dart';

class ConnectedPage2 extends StatefulWidget {
  final String deviceName;
  final BluetoothDevice device;

  const ConnectedPage2({
    Key? key,
    required this.deviceName,
    required this.device,
  }) : super(key: key);

  @override
  _ConnectedPage2State createState() => _ConnectedPage2State();
}

class _ConnectedPage2State extends State<ConnectedPage2> {
  bool lock = true;
  late String deviceUUID;
  int connectionStatus = 1;

  BluetoothCharacteristic? characteristic;
  StreamController<String> streamController = StreamController();

  Stream<List<int>>? value;

  String? espData;
  Terminal? terminal;

  List<BluetoothService> services = [];
  bool showData = false;

  Future<String?> getDeviceUUID() async {
    List<BluetoothService> services = await widget.device.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.isNotifying) {
          print(" heeee : ${characteristic.uuid}");
          return characteristic.uuid.toString();
        }
      }
    }
    return "abc";
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // await widget.device.connect();
      print(1);
      connectionStatus = 1;
      deviceUUID = (await getDeviceUUID())!;
      print(2);
      services = await widget.device.discoverServices();
      print(3);
      stream();
      print(4);
      // Fetch data and update terminal
      fetchDataAndUpdateTerminal();
    });

    super.initState();
  }

  // Future<void> fetchDataAndUpdateTerminal() async {
  //   // Fetch data using the characteristic UUID
  //   if (deviceUUID != null) {
  //     BluetoothService service = services.firstWhere(
  //       (service) => service.uuid.toString() == deviceUUID,
  //       // orElse: () => null, // Default value when no match is found
  //     );
  //     if (service != null) {
  //       BluetoothCharacteristic characteristic =
  //           service.characteristics.firstWhere(
  //         (characteristic) => characteristic.isNotifying,
  //         // orElse: () => null, // Default value when no match is found
  //       );
  //       if (characteristic != null) {
  //         characteristic.value.listen((value) {
  //           setState(() {
  //             // Parse and update terminal with the fetched data
  //             terminal = Terminal.fromJson(json.decode(utf8.decode(value)));
  //           });
  //         });
  //       }
  //     }
  //   }
  // }
  Future<void> fetchDataAndUpdateTerminal() async {
    // Fetch data using the characteristic UUID
    if (deviceUUID != null) {
      try {
        BluetoothService service = services.firstWhere(
          (service) => service.uuid.toString() == deviceUUID,
        );
        BluetoothCharacteristic characteristic =
            service.characteristics.firstWhere(
          (characteristic) => characteristic.isNotifying,
        );

        characteristic.value.listen((value) {
          setState(() {
            // Parse and update terminal with the fetched data
            terminal = Terminal.fromJson(json.decode(utf8.decode(value)));
          });
        });
      } catch (e) {
        print('No matching service or characteristic found');
        return null;
      }
    }
  }

  @override
  void dispose() {
    widget.device.disconnect();
    services.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Connected ${widget.deviceName}"),
        actions: [
          IconButton(
            onPressed: () => _disconnectDevice(context),
            icon: const Text("Disconnect"),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Center(
            child: ElevatedButton(
                onPressed: lock == true ? lock0 : unLock,
                style: ElevatedButton.styleFrom(
                    backgroundColor: lock == true
                        ? Colors.deepPurple[50]
                        : Colors.green[100],
                    fixedSize: const Size(180, 90)),
                child: Text(
                  lock == true ? "Lock" : "Unlock",
                  style: const TextStyle(fontSize: 22),
                )),
          ), // LOCK-UNLOCK BUTTON
          const SizedBox(
            height: 40,
          )
        ],
      ),
      body: terminal == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      crossAxisSpacing: 1,
                      mainAxisSpacing: 2,
                      crossAxisCount: 2,
                      children: <Widget>[
                        Card(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Text("Backup % : "),
                              terminal!.ba == null
                                  ? const Text("Connect to Device")
                                  : Text("${terminal!.ba}"),
                            ],
                          ),
                        ),
                        Card(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Text("Backup Battery Voltage"),
                              terminal!.baV == null
                                  ? const Text("Connect to Device")
                                  : Text("${terminal!.baV}"),
                            ],
                          ),
                        ),
                        Card(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Text("HELLO : "),
                              terminal!.h == null
                                  ? const Text("Connect to Device")
                                  : Text("${terminal!.h}"),
                            ],
                          ),
                        ),
                        // Card(
                        //   child: Column(
                        //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        //     children: [
                        //       const Text("Backup Battery Voltage"),
                        //       terminal!.abv == null
                        //           ? const Text("Connect to Device")
                        //           : Text("${terminal!.abv}v"),
                        //     ],
                        //   ),
                        // ),
                        // Card(
                        //   child: Column(
                        //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        //     children: [
                        //       const Text("Motor Current"),
                        //       terminal!.acd == null
                        //           ? const Text("Connect to Device")
                        //           : Text("${terminal!.acd}"),
                        //     ],
                        //   ),
                        // ),
                        // Card(
                        //   child: Column(
                        //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        //     children: [
                        //       const Text("Motor Voltage"),
                        //       terminal!.aev == null
                        //           ? const Text("Connect to Device")
                        //           : Text("${terminal!.aev}v"),
                        //     ],
                        //   ),
                        // ),
                        // Card(
                        //   child: Column(
                        //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        //     children: [
                        //       const Text("VCU Temperature"),
                        //       terminal!.atm == null
                        //           ? const Text("Connect to Device")
                        //           : Text("${terminal!.atm} C°"),
                        //     ],
                        //   ),
                        // ),
                        // Card(
                        //   child: Column(
                        //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        //     children: [
                        //       const Text("Battery Level"),
                        //       terminal!.ba == null
                        //           ? const Text("Connect to Device")
                        //           : Text("${terminal!.ba}%"),
                        //     ],
                        //   ),
                        // ),
                        // Card(
                        //   child: Column(
                        //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        //     children: [
                        //       const Text("Battery State"),
                        //       terminal!.bst == null
                        //           ? const Text("Connect to Device")
                        //           : Text("${terminal!.bst}"),
                        //     ],
                        //   ),
                        // ),
                        // Card(
                        //   child: Column(
                        //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        //     children: [
                        //       const Text("Battery State"),
                        //       terminal!.bst == null
                        //           ? const Text("Connect to Device")
                        //           : Text("${terminal!.bst}"),
                        //     ],
                        //   ),
                        // ),
                        // Card(
                        //   child: Column(
                        //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        //     children: [
                        //       const Text("Battery Temperature"),
                        //       terminal!.btm == null
                        //           ? const Text("Connect to Device")
                        //           : Text(terminal!.btm!.join(',').toString()),
                        //     ],
                        //   ),
                        // ),
                        // Card(
                        //   child: Column(
                        //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        //     children: [
                        //       const Text("Battery Capacity"),
                        //       terminal!.cap == null
                        //           ? const Text("Connect to Device")
                        //           : Text("${terminal!.cap}"),
                        //     ],
                        //   ),
                        // ),
                        // Card(
                        //   child: Column(
                        //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        //     children: [
                        //       const Text("battery 13 cell voltages"),
                        //       terminal!.clv == null
                        //           ? const Text("Connect to Device")
                        //           : Padding(
                        //               padding: const EdgeInsets.symmetric(
                        //                   horizontal: 10),
                        //               child: Text(terminal!.clv!.join(',')),
                        //             ),
                        //     ],
                        //   ),
                        // ),
                        // Card(
                        //   child: Column(
                        //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        //     children: [
                        //       const Text("Battery Current"),
                        //       terminal!.cur == null
                        //           ? const Text("Connect to Device")
                        //           : Text("${terminal!.cur}"),
                        //     ],
                        //   ),
                        // ),
                        // Card(
                        //   child: Column(
                        //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        //     children: [
                        //       const Text("Location"),
                        //       terminal!.lat == null
                        //           ? const Text("Connect to Device")
                        //           : Text("${terminal!.lat}\n${terminal!.lat}"),
                        //     ],
                        //   ),
                        // ),
                        // Card(
                        //   child: Column(
                        //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        //     children: [
                        //       const Text("Battery Voltage"),
                        //       terminal!.tov == null
                        //           ? const Text("Connect to Device")
                        //           : Text("${terminal!.tov}v"),
                        //     ],
                        //   ),
                        // ),
                        // Card(
                        //   child: Column(
                        //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        //     children: [
                        //       const Text("IMU Pitch"),
                        //       terminal!.pit == null
                        //           ? const Text("Connect to Device")
                        //           : Text("${terminal!.pit}"),
                        //     ],
                        //   ),
                        // ),
                        // Card(
                        //   child: Column(
                        //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        //     children: [
                        //       const Text("IMU Roll"),
                        //       terminal!.rol == null
                        //           ? const Text("Connect to Device")
                        //           : Text("${terminal!.rol}"),
                        //     ],
                        //   ),
                        // ),
                        // Card(
                        //   child: Column(
                        //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        //     children: [
                        //       const Text("TOV"),
                        //       terminal!.tov == null
                        //           ? const Text("Connect to Device")
                        //           : Text("${terminal!.tov}"),
                        //     ],
                        //   ),
                        // ),
                      ],
                    ),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
    );
  }

  void stream() async {
    await widget.device.requestMtu(512);
    int mtu = await widget.device.mtu.first;
    while (mtu != 512) {
      await Future.delayed(const Duration(seconds: 1));
      mtu = await widget.device.mtu.first;
    }
    await Future.forEach(services, (BluetoothService service) async {
      List<BluetoothCharacteristic> characteristics = service.characteristics;
      var data = characteristics.toList();
      for (var i = 0; i < data.length; i++) {
        if (data[i].uuid == Guid(deviceUUID)) {
          await Future.delayed(const Duration(seconds: 1));
          data[i].setNotifyValue(true);
          data[i].value.listen((event) {
            var convert = utf8.decode(event);
            if (convert.isNotEmpty) {
              setState(() {
                terminal = terminalFromJson(convert);
              });
            }
          });
        }
      }
    });
  }

  void _disconnectDevice(BuildContext context) async {
    try {
      // Disconnect the device
      await widget.device.disconnect();
      connectionStatus = 0;
      // Navigate back to the home page
      Navigator.pop(context);
    } catch (e) {
      if (kDebugMode) {
        print('Error disconnecting from device: $e');
      }
    }
  }

  void lock0({String? value}) async {
    services.forEach((service) async {
      var characteristics = service.characteristics;
      for (BluetoothCharacteristic c in characteristics) {
        if (c.uuid == Guid(deviceUUID)) {
          var encoded = utf8.encode('{"lock":0}');
          await c.write(encoded, withoutResponse: true);
        }
      }
    });
    setState(() {
      lock = false;
    });
  }

  void unLock() async {
    services.forEach((service) async {
      var characteristics = service.characteristics;
      for (BluetoothCharacteristic c in characteristics) {
        if (c.uuid == Guid(deviceUUID)) {
          var encoded = utf8.encode('{"lock":1}');
          await c.write(encoded, withoutResponse: true);
        }
      }
    });
    setState(() {
      lock = true;
    });
  }
}
