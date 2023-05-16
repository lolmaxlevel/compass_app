import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BTController {
  static BTController? _instance;

  BTController._();

  factory BTController() => _instance ??= BTController._();

  BluetoothConnection? connection;
  ValueNotifier<bool> isConnected = ValueNotifier(false);

  Future<bool> connect() async {
    print(isConnected);
    List<BluetoothDevice> devices = [];
    try {
      devices = await FlutterBluetoothSerial.instance.getBondedDevices();
    } catch (ex) {
      print('Ошибка: $ex');
    }
    for (var device in devices){
      device.isConnected?await connection?.close():"";
      if (device.name == "HC-06" && !isConnected.value) {
        try {
          await BluetoothConnection.toAddress(device.address).then((_connection) {
            _connection.input?.listen((event) {
              if (kDebugMode) {
                print(utf8.decode(event));
              }
            }, onDone: () {
              if (kDebugMode) {
                print('Соединение закрыто');
              }
              isConnected.value = false;
            }, onError: (error) {
              if (kDebugMode) {
                print("Ошибка: $error");
              }
              isConnected.value = false;
              });
            connection = _connection;
            isConnected.value = true;
            return true;
          });
        } catch (ex) {
          if (kDebugMode) {
            print('Ошибка: $ex');
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
        print('Отключено от устройства.');
      }
    }
  }

  void sendMessage(String message) async {
    connection!.output.add(Uint8List.fromList(utf8.encode(message)));
    await connection!.output.allSent;
  }
}