import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

class BTController {
  static BTController? _instance;

  BTController._();

  factory BTController() => _instance ??= BTController._();

  BluetoothConnection? connection;
  ValueNotifier<bool> isConnected = ValueNotifier(false);

  Future<bool> connect() async {
    var status = await Permission.bluetoothConnect.status;
    var status2 = await Permission.bluetoothScan.status;
    if (status.isDenied) {
      await Permission.bluetoothConnect.request();
    }
    if (status2.isDenied) {
      await Permission.bluetoothScan.request();
    }

    List<BluetoothDevice> devices = [];
    try {
      devices = await FlutterBluetoothSerial.instance.getBondedDevices();
    } catch (ex) {
      if (kDebugMode) {
        print('BT Ошибка: $ex');
      }
    }
    for (var device in devices){
      device.isConnected?await connection?.close():"";
      if (device.name == "HC-06" && !isConnected.value) {
        try {
          await BluetoothConnection.toAddress(device.address).then((_connection) {
            _connection.input?.listen((event) {
              if (kDebugMode) {
                print(event);
                print(utf8.decode(event));
              }
            }, onDone: () {
              if (kDebugMode) {
                print('BT Соединение закрыто');
              }
              isConnected.value = false;
            }, onError: (error) {
              if (kDebugMode) {
                print("BT Ошибка: $error");
              }
              isConnected.value = false;
              });
            connection = _connection;
            isConnected.value = true;
            return true;
          });
        } catch (ex) {
          if (kDebugMode) {
            print('BT Ошибка: $ex');
          }
        }
      }
    }
    return false;
  }

  void disconnect() async {
    if (connection != null) {
      await connection!.close();
      connection = null;
      isConnected.value = false;
      if (kDebugMode) {
        print('BT Отключено от устройства.');
      }
    }
  }

  void sendMessage(String message) async {
    if (kDebugMode) {
      print("bt message $message");
    }
    connection!.output.add(Uint8List.fromList(utf8.encode(message)));
    await connection!.output.allSent;
  }
}