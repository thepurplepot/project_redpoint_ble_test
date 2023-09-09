import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_bluetooth_app/exeptions.dart';
import 'package:flutter_bluetooth_app/global.dart';
import 'package:flutter_bluetooth_app/widgets/widgets.dart';

class DeviceScreen extends StatelessWidget {
  final BluetoothDevice device;
  final scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  DeviceScreen({Key? key, required this.device}) : super(key: key);

  List<int> _getRandomBytes() {
    final math = Random();
    return [
      math.nextInt(255),
      math.nextInt(255),
      math.nextInt(255),
      math.nextInt(255)
    ];
  }

  List<Widget> _buildServiceTiles(
      BuildContext context, List<BluetoothService> services) {
    return services
        .map(
          (s) => ServiceTile(
            service: s,
            characteristicTiles: s.characteristics
                .map(
                  (c) => CharacteristicTile(
                    characteristic: c,
                    onReadPressed: () async {
                      try {
                        await c.read();
                        final snackBar = snackBarGood("Read: Success");
                        scaffoldKey.currentState?.removeCurrentSnackBar();
                        scaffoldKey.currentState?.showSnackBar(snackBar);
                      } catch (e) {
                        final snackBar =
                            snackBarFail(prettyException("Read Error:", e));
                        scaffoldKey.currentState?.removeCurrentSnackBar();
                        scaffoldKey.currentState?.showSnackBar(snackBar);
                      }
                    },
                    onWritePressed: () async {
                      try {
                        await c.write(_getRandomBytes(),
                            withoutResponse: c.properties.writeWithoutResponse);
                        final snackBar = snackBarGood("Write: Success");
                        scaffoldKey.currentState?.removeCurrentSnackBar();
                        scaffoldKey.currentState?.showSnackBar(snackBar);
                        if (c.properties.read) {
                          await c.read();
                        }
                      } catch (e) {
                        final snackBar =
                            snackBarFail(prettyException("Write Error:", e));
                        scaffoldKey.currentState?.removeCurrentSnackBar();
                        scaffoldKey.currentState?.showSnackBar(snackBar);
                      }
                    },
                    onNotificationPressed: () async {
                      try {
                        String op =
                            c.isNotifying == false ? "Subscribe" : "Unubscribe";
                        await c.setNotifyValue(c.isNotifying == false);
                        final snackBar = snackBarGood("$op : Success");
                        scaffoldKey.currentState?.removeCurrentSnackBar();
                        scaffoldKey.currentState?.showSnackBar(snackBar);
                        if (c.properties.read) {
                          await c.read();
                        }
                      } catch (e) {
                        final snackBar = snackBarFail(
                            prettyException("Subscribe Error:", e));
                        scaffoldKey.currentState?.removeCurrentSnackBar();
                        scaffoldKey.currentState?.showSnackBar(snackBar);
                      }
                    },
                    descriptorTiles: c.descriptors
                        .map(
                          (d) => DescriptorTile(
                            descriptor: d,
                            onReadPressed: () async {
                              try {
                                await d.read();
                                final snackBar = snackBarGood("Read: Success");
                                scaffoldKey.currentState
                                    ?.removeCurrentSnackBar();
                                scaffoldKey.currentState
                                    ?.showSnackBar(snackBar);
                              } catch (e) {
                                final snackBar = snackBarFail(
                                    prettyException("Read Error:", e));
                                scaffoldKey.currentState
                                    ?.removeCurrentSnackBar();
                                scaffoldKey.currentState
                                    ?.showSnackBar(snackBar);
                              }
                            },
                            onWritePressed: () async {
                              try {
                                await d.write(_getRandomBytes());
                                final snackBar = snackBarGood("Write: Success");
                                scaffoldKey.currentState
                                    ?.removeCurrentSnackBar();
                                scaffoldKey.currentState
                                    ?.showSnackBar(snackBar);
                              } catch (e) {
                                final snackBar = snackBarFail(
                                    prettyException("Write Error:", e));
                                scaffoldKey.currentState
                                    ?.removeCurrentSnackBar();
                                scaffoldKey.currentState
                                    ?.showSnackBar(snackBar);
                              }
                            },
                          ),
                        )
                        .toList(),
                  ),
                )
                .toList(),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: scaffoldKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text(device.localName),
          actions: <Widget>[
            StreamBuilder<BluetoothConnectionState>(
              stream: device.connectionState,
              initialData: BluetoothConnectionState.connecting,
              builder: (c, snapshot) {
                VoidCallback? onPressed;
                String text;
                switch (snapshot.data) {
                  case BluetoothConnectionState.connected:
                    onPressed = () async {
                      isConnectingOrDisconnecting[device.remoteId] ??=
                          ValueNotifier(true);
                      isConnectingOrDisconnecting[device.remoteId]!.value =
                          true;
                      try {
                        await device.disconnect();
                        final snackBar = snackBarGood("Disconnect: Success");
                        scaffoldKey.currentState?.removeCurrentSnackBar();
                        scaffoldKey.currentState?.showSnackBar(snackBar);
                      } catch (e) {
                        final snackBar = snackBarFail(
                            prettyException("Disconnect Error:", e));
                        scaffoldKey.currentState?.removeCurrentSnackBar();
                        scaffoldKey.currentState?.showSnackBar(snackBar);
                      }
                      isConnectingOrDisconnecting[device.remoteId] ??=
                          ValueNotifier(false);
                      isConnectingOrDisconnecting[device.remoteId]!.value =
                          false;
                    };
                    text = 'DISCONNECT';
                    break;
                  case BluetoothConnectionState.disconnected:
                    onPressed = () async {
                      isConnectingOrDisconnecting[device.remoteId] ??=
                          ValueNotifier(true);
                      isConnectingOrDisconnecting[device.remoteId]!.value =
                          true;
                      try {
                        await device.connect(
                            timeout: const Duration(seconds: 35));
                        final snackBar = snackBarGood("Connect: Success");
                        scaffoldKey.currentState?.removeCurrentSnackBar();
                        scaffoldKey.currentState?.showSnackBar(snackBar);
                      } catch (e) {
                        final snackBar =
                            snackBarFail(prettyException("Connect Error:", e));
                        scaffoldKey.currentState?.removeCurrentSnackBar();
                        scaffoldKey.currentState?.showSnackBar(snackBar);
                      }
                      isConnectingOrDisconnecting[device.remoteId] ??=
                          ValueNotifier(false);
                      isConnectingOrDisconnecting[device.remoteId]!.value =
                          false;
                    };
                    text = 'CONNECT';
                    break;
                  default:
                    onPressed = null;
                    text =
                        snapshot.data.toString().split(".").last.toUpperCase();
                    break;
                }
                return ValueListenableBuilder<bool>(
                    valueListenable:
                        isConnectingOrDisconnecting[device.remoteId]!,
                    builder: (context, value, child) {
                      isConnectingOrDisconnecting[device.remoteId] ??=
                          ValueNotifier(false);
                      if (isConnectingOrDisconnecting[device.remoteId]!.value ==
                          true) {
                        // Show spinner when connecting or disconnecting
                        return const Padding(
                          padding: EdgeInsets.all(14.0),
                          child: AspectRatio(
                            aspectRatio: 1.0,
                            child: CircularProgressIndicator(
                              backgroundColor: Colors.black12,
                              color: Colors.black26,
                            ),
                          ),
                        );
                      } else {
                        return TextButton(
                            onPressed: onPressed,
                            child: Text(
                              text,
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .labelLarge
                                  ?.copyWith(color: Colors.white),
                            ));
                      }
                    });
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              StreamBuilder<BluetoothConnectionState>(
                stream: device.connectionState,
                initialData: BluetoothConnectionState.connecting,
                builder: (c, snapshot) => Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('${device.remoteId}'),
                    ),
                    ListTile(
                      leading: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          snapshot.data == BluetoothConnectionState.connected
                              ? const Icon(Icons.bluetooth_connected)
                              : const Icon(Icons.bluetooth_disabled),
                          snapshot.data == BluetoothConnectionState.connected
                              ? StreamBuilder<int>(
                                  stream: rssiStream(maxItems: 1),
                                  builder: (context, snapshot) {
                                    return Text(
                                        snapshot.hasData
                                            ? '${snapshot.data}dBm'
                                            : '',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall);
                                  })
                              : Text('',
                                  style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                      title: Text(
                          'Device is ${snapshot.data.toString().split('.')[1]}.'),
                      trailing: StreamBuilder<bool>(
                        stream: device.isDiscoveringServices,
                        initialData: false,
                        builder: (c, snapshot) => IndexedStack(
                          index: (snapshot.data ?? false) ? 1 : 0,
                          children: <Widget>[
                            TextButton(
                              child: const Text("Get Services"),
                              onPressed: () async {
                                try {
                                  await device.discoverServices();
                                  final snackBar = snackBarGood(
                                      "Discover Services: Success");
                                  scaffoldKey.currentState
                                      ?.removeCurrentSnackBar();
                                  scaffoldKey.currentState
                                      ?.showSnackBar(snackBar);
                                } catch (e) {
                                  final snackBar = snackBarFail(prettyException(
                                      "Discover Services Error:", e));
                                  scaffoldKey.currentState
                                      ?.removeCurrentSnackBar();
                                  scaffoldKey.currentState
                                      ?.showSnackBar(snackBar);
                                }
                              },
                            ),
                            const IconButton(
                              icon: SizedBox(
                                width: 18.0,
                                height: 18.0,
                                child: CircularProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.grey),
                                ),
                              ),
                              onPressed: null,
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              StreamBuilder<int>(
                stream: device.mtu,
                initialData: 0,
                builder: (c, snapshot) => ListTile(
                  title: const Text('MTU Size'),
                  subtitle: Text('${snapshot.data} bytes'),
                  trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        try {
                          await device.requestMtu(223);
                          final snackBar = snackBarGood("Request Mtu: Success");
                          scaffoldKey.currentState?.removeCurrentSnackBar();
                          scaffoldKey.currentState?.showSnackBar(snackBar);
                        } catch (e) {
                          final snackBar = snackBarFail(
                              prettyException("Change Mtu Error:", e));
                          scaffoldKey.currentState?.removeCurrentSnackBar();
                          scaffoldKey.currentState?.showSnackBar(snackBar);
                        }
                      }),
                ),
              ),
              StreamBuilder<List<BluetoothService>>(
                stream: device.servicesStream,
                initialData: const [],
                builder: (c, snapshot) {
                  return Column(
                    children: _buildServiceTiles(context, snapshot.data ?? []),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Stream<int> rssiStream(
      {Duration frequency = const Duration(seconds: 5), int? maxItems}) async* {
    var isConnected = true;
    final subscription = device.connectionState.listen((v) {
      isConnected = v == BluetoothConnectionState.connected;
    });
    int i = 0;
    while (isConnected && (maxItems == null || i < maxItems)) {
      try {
        yield await device.readRssi();
      } catch (e) {
        if (kDebugMode) {
          print("Error reading RSSI: $e");
        }
        break;
      }
      await Future.delayed(frequency);
      i++;
    }
    // Device disconnected, stopping RSSI stream
    subscription.cancel();
  }
}
