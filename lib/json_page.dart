// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'terminal_model.dart';

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({Key? key, required this.device}) : super(key: key);

  final BluetoothDevice device;

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  bool lock = true;
  BluetoothCharacteristic? characteristic;
  StreamController<String> streamController = StreamController();

  Stream<List<int>>? value;

  String? espData;

  String? deviceUUID;
  Terminal? terminal;

  List<BluetoothService> services = [];

  // List<int> _getRandomBytes() {
  //   final math = Random();
  //   return [
  //     math.nextInt(255),
  //     math.nextInt(255),
  //     math.nextInt(255),
  //     math.nextInt(255)
  //   ];
  // }

  // List<Widget> _buildServiceTiles(List<BluetoothService> services) {
  //   return services
  //       .map(
  //         (s) => ServiceTile(
  //           service: s,
  //           characteristicTiles: s.characteristics
  //               .map(
  //                 (c) => CharacteristicTile(
  //                   characteristic: c,
  //                   onReadPressed: () async {
  //                     var encoded = utf8.encode('{"LEDStatus":1}');
  //                     await c.write(encoded, withoutResponse: true);
  //                     c.read();
  //                   },
  //                   onWritePressed: () async {
  //                     var encoded = utf8.encode('{"LEDStatus":0}');
  //                     await c.write(encoded, withoutResponse: true);
  //                     await c.read();
  //                   },
  //                   onNotificationPressed: () async {
  //                     await c.setNotifyValue(!c.isNotifying);
  //                     await c.read();
  //                   },
  //                   descriptorTiles: c.descriptors
  //                       .map(
  //                         (d) => DescriptorTile(
  //                           descriptor: d,
  //                           onReadPressed: () => d.read(),
  //                           onWritePressed: () => d.write(_getRandomBytes()),
  //                         ),
  //                       )
  //                       .toList(),
  //                 ),
  //               )
  //               .toList(),
  //         ),
  //       )
  //       .toList();
  // }
  Future<String?> getDeviceUUID() async {
    List<BluetoothService> services = await widget.device.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.isNotifying) {
          return characteristic.uuid.toString();
        }
      }
    }
    return null;
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await widget.device.connect();
      deviceUUID = await getDeviceUUID();
      services = await widget.device.discoverServices();
      stream();
      // Fetch data and update terminal
      fetchDataAndUpdateTerminal();
    });

    super.initState();
  }

  Future<void> fetchDataAndUpdateTerminal() async {
    // Fetch data using the characteristic UUID
    if (deviceUUID != null) {
      BluetoothService service = services.firstWhere(
        (service) => service.uuid.toString() == deviceUUID,
        // orElse: () => null, // Default value when no match is found
      );
      if (service != null) {
        BluetoothCharacteristic characteristic =
            service.characteristics.firstWhere(
          (characteristic) => characteristic.isNotifying,
          // orElse: () => null, // Default value when no match is found
        );
        if (characteristic != null) {
          characteristic.value.listen((value) {
            setState(() {
              // Parse and update terminal with the fetched data
              terminal = Terminal.fromJson(json.decode(utf8.decode(value)));
            });
          });
        }
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
        title: Text(widget.device.name),
        actions: <Widget>[
          StreamBuilder<BluetoothDeviceState>(
            stream: widget.device.state,
            initialData: BluetoothDeviceState.connecting,
            builder: (c, snapshot) {
              VoidCallback? onPressed;
              String text;
              switch (snapshot.data) {
                case BluetoothDeviceState.connected:
                  onPressed = () => widget.device.disconnect();
                  text = 'DISCONNECT';
                  break;
                case BluetoothDeviceState.disconnected:
                  onPressed = () => widget.device.connect();
                  text = 'CONNECT';
                  break;
                default:
                  onPressed = null;
                  text = snapshot.data.toString().substring(21).toUpperCase();
                  break;
              }
              return TextButton(
                  onPressed: onPressed,
                  child: Text(
                    text,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .labelLarge
                        ?.copyWith(color: Colors.white),
                  ));
            },
          )
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Center(
            child: ElevatedButton(
                onPressed: lock == true ? lock0 : unLock,
                style: ElevatedButton.styleFrom(
                    backgroundColor: lock == true ? Colors.red : Colors.green,
                    fixedSize: const Size(120, 60)),
                child: Text(
                  lock == true ? "Lock" : "Unlock",
                  style: const TextStyle(fontSize: 22),
                )),
          ),
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
                        const Text("Backup Battery Voltage"),
                        terminal!.abv == null
                            ? const Text("Connect to Device")
                            : Text("${terminal!.abv}v"),
                      ],
                    ),
                  ),
                  Card(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Text("Motor Current"),
                        terminal!.acd == null
                            ? const Text("Connect to Device")
                            : Text("${terminal!.acd}"),
                      ],
                    ),
                  ),
                  Card(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Text("Motor Voltage"),
                        terminal!.aev == null
                            ? const Text("Connect to Device")
                            : Text("${terminal!.aev}v"),
                      ],
                    ),
                  ),
                  Card(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Text("VCU Temperature"),
                        terminal!.atm == null
                            ? const Text("Connect to Device")
                            : Text("${terminal!.atm} C°"),
                      ],
                    ),
                  ),
                  Card(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Text("Battery Level"),
                        terminal!.ba == null
                            ? const Text("Connect to Device")
                            : Text("${terminal!.ba}%"),
                      ],
                    ),
                  ),
                  Card(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Text("Battery State"),
                        terminal!.bst == null
                            ? const Text("Connect to Device")
                            : Text("${terminal!.bst}"),
                      ],
                    ),
                  ),
                  Card(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Text("Battery State"),
                        terminal!.bst == null
                            ? const Text("Connect to Device")
                            : Text("${terminal!.bst}"),
                      ],
                    ),
                  ),
                  Card(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Text("Battery Temperature"),
                        terminal!.btm == null
                            ? const Text("Connect to Device")
                            : Text(terminal!.btm!.join(',').toString()),
                      ],
                    ),
                  ),
                  Card(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Text("Battery Capacity"),
                        terminal!.cap == null
                            ? const Text("Connect to Device")
                            : Text("${terminal!.cap}"),
                      ],
                    ),
                  ),
                  Card(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Text("battery 13 cell voltages"),
                        terminal!.clv == null
                            ? const Text("Connect to Device")
                            : Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10),
                          child: Text(terminal!.clv!.join(',')),
                        ),
                      ],
                    ),
                  ),
                  Card(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Text("Battery Current"),
                        terminal!.cur == null
                            ? const Text("Connect to Device")
                            : Text("${terminal!.cur}"),
                      ],
                    ),
                  ),
                  Card(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Text("Location"),
                        terminal!.lat == null
                            ? const Text("Connect to Device")
                            : Text("${terminal!.lat}\n${terminal!.lat}"),
                      ],
                    ),
                  ),
                  Card(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Text("Battery Voltage"),
                        terminal!.tov == null
                            ? const Text("Connect to Device")
                            : Text("${terminal!.tov}v"),
                      ],
                    ),
                  ),
                  Card(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Text("IMU Pitch"),
                        terminal!.pit == null
                            ? const Text("Connect to Device")
                            : Text("${terminal!.pit}"),
                      ],
                    ),
                  ),
                  Card(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Text("IMU Roll"),
                        terminal!.rol == null
                            ? const Text("Connect to Device")
                            : Text("${terminal!.rol}"),
                      ],
                    ),
                  ),
                  Card(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Text("TOV"),
                        terminal!.tov == null
                            ? const Text("Connect to Device")
                            : Text("${terminal!.tov}"),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 120),
              //   terminal!.abv == null
              //       ? Container()
              //       : Text("abv: ${terminal!.abv}"),
              //   const SizedBox(height: 5),
              //   terminal!.acd == null
              //       ? Container()
              //       : Text("acd: ${terminal!.acd}"),
              //   const SizedBox(height: 5),
              //   terminal!.aev == null
              //       ? Container()
              //       : Text("aev: ${terminal!.aev}"),
              //   const SizedBox(height: 5),
              //   terminal!.atm == null
              //       ? Container()
              //       : Text("atm: ${terminal!.atm}"),
              //   const SizedBox(height: 5),
              //   terminal!.ba == null
              //       ? Container()
              //       : Text("ba: ${terminal!.ba}"),
              //   const SizedBox(height: 5),
              //   terminal!.bst == null
              //       ? Container()
              //       : Text("bst: ${terminal!.bst}"),
              //   const SizedBox(height: 5),
              //   terminal!.btm == null
              //       ? Container()
              //       : Text("btm: ${terminal!.btm}"),
              //   const SizedBox(height: 5),
              //   terminal!.cap == null
              //       ? Container()
              //       : Text("cap: ${terminal!.cap}"),
              //   const SizedBox(height: 5),
              //   terminal!.clv == null
              //       ? Container()
              //       : Text("clv: ${terminal!.clv}"),
              //   const SizedBox(height: 5),
              //   terminal!.cur == null
              //       ? Container()
              //       : Text("cur: ${terminal!.cur}"),
              //   const SizedBox(height: 5),
              //   terminal!.lat == null
              //       ? Container()
              //       : Text("lat: ${terminal!.lat}"),
              //   const SizedBox(height: 5),
              //   terminal!.lon == null
              //       ? Container()
              //       : Text("lon: ${terminal!.lon}"),
              //   const SizedBox(height: 5),
              //   terminal!.pit == null
              //       ? Container()
              //       : Text("pit: ${terminal!.pit}"),
              //   const SizedBox(height: 5),
              //   terminal!.rol == null
              //       ? Container()
              //       : Text("rol: ${terminal!.rol}"),
              //   const SizedBox(height: 5),
              //   terminal!.tov == null
              //       ? Container()
              //       : Text("tov: ${terminal!.tov}"),
            ],
          ),
        ),
      ),
      // body: SingleChildScrollView(
      //   child: Column(
      //     children: <Widget>[
      //       StreamBuilder<BluetoothDeviceState>(
      //         stream: widget.device.state,
      //         initialData: BluetoothDeviceState.connecting,
      //         builder: (c, snapshot) => ListTile(
      //           leading: (snapshot.data == BluetoothDeviceState.connected)
      //               ? const Icon(Icons.bluetooth_connected)
      //               : const Icon(Icons.bluetooth_disabled),
      //           title: Text(
      //               'Device is ${snapshot.data.toString().split('.')[1]}.'),
      //           subtitle: Text('${widget.device.id}'),
      //           trailing: StreamBuilder<bool>(
      //             stream: widget.device.isDiscoveringServices,
      //             initialData: false,
      //             builder: (c, snapshot) => IndexedStack(
      //               index: snapshot.data! ? 1 : 0,
      //               children: <Widget>[
      //                 IconButton(
      //                   icon: const Icon(Icons.refresh),
      //                   onPressed: () => widget.device.discoverServices(),
      //                 ),
      //                 const IconButton(
      //                   icon: SizedBox(
      //                     width: 18.0,
      //                     height: 18.0,
      //                     child: CircularProgressIndicator(
      //                       valueColor: AlwaysStoppedAnimation(Colors.grey),
      //                     ),
      //                   ),
      //                   onPressed: null,
      //                 )
      //               ],
      //             ),
      //           ),
      //         ),
      //       ),
      //       StreamBuilder<int>(
      //         stream: widget.device.mtu,
      //         initialData: 0,
      //         builder: (c, snapshot) => ListTile(
      //           title: const Text('MTU Size'),
      //           subtitle: Text('${snapshot.data} bytes'),
      //           trailing: IconButton(
      //             icon: const Icon(Icons.edit),
      //             onPressed: () => widget.device.requestMtu(223),
      //           ),
      //         ),
      //       ),
      //       StreamBuilder<List<BluetoothService>>(
      //         stream: widget.device.services,
      //         initialData: const [],
      //         builder: (c, snapshot) {
      //           return Column(
      //             children: [
      //               Column(
      //                 children: _buildServiceTiles(snapshot.data!),
      //               ),
      //             ],
      //           );
      //         },
      //       ),
      //     ],
      //   ),
      // ),
    );
  }

  // Future _services() async {
  //   List<BluetoothService> services = await widget.device.discoverServices();
  //   services.forEach((service) async {
  //     var characteristics = service.characteristics.map((c) {
  //       print("Value $c");
  //     });
  //     // for (BluetoothCharacteristic c in characteristics) {
  //     //   value = c.value;
  //     // }
  //     // setState(() {
  //
  //     // });
  //   });
  // }
  // void data() {
  //   // List<BluetoothService> services = await widget.device.discoverServices();
  //   var data = services();
  //   // services.forEach((service) async {
  //   //   var characteristics = service.characteristics;
  //   //   return characteristics;
  //   //   // for (BluetoothCharacteristic c in characteristics) {
  //   //   //   return c.value;
  //   //   //   // StreamBuilder<List<int>>(
  //   //   //   //   stream: c.value,
  //   //   //   //   initialData: const [],
  //   //   //   //   builder: (c, snapshot) {
  //   //   //   //     print('Value = ${String.fromCharCodes(snapshot.data!)}');
  //   //   //   //     return Text(String.fromCharCodes(snapshot.data!));
  //   //   //   //   },
  //   //   //   // );
  //   //   // }
  //   // });
  // }
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
        if (data[i].uuid == Guid("beb5483e-36e1-4688-b7f5-ea07361b26a8")) {
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
    // for (BluetoothService service in services) {
    //   List<BluetoothCharacteristic> characteristics = service.characteristics;
    //   var data = characteristics.toList();
    //   for (var i = 0; i < data.length; i++) {
    //     await Future.delayed(const Duration(seconds: 1));
    //     data[i].setNotifyValue(true);
    //     data[i].value.listen((event) {
    //       var convert = utf8.decode(event);
    //       if (convert.isNotEmpty) {
    //         setState(() {
    //           terminal = terminalFromJson(convert);
    //         });
    //       }
    //     });
    //   }
    // }
  }

  void lock0({String? value}) async {
    services.forEach((service) async {
      var characteristics = service.characteristics;
      for (BluetoothCharacteristic c in characteristics) {
        if (c.uuid == Guid("beb5483e-36e1-4688-b7f5-ea07361b26a8")) {
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
        if (c.uuid == Guid("beb5483e-36e1-4688-b7f5-ea07361b26a8")) {
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
