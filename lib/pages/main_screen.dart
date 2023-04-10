import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:background_location/background_location.dart';
import 'package:compass_app/web_socket_worker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:compass_app/pages/settings.dart';

import '../models/server_io.dart';


class MainScreen extends StatefulWidget {
  final AdaptiveThemeMode? savedThemeMode;

  const MainScreen({
    super.key,
    this.savedThemeMode
  });

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  dynamic ws;
  String host = "";
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String latitude = 'waiting...';
  String longitude = 'waiting...';
  String altitude = 'waiting...';
  String accuracy = 'waiting...';
  String bearing = 'waiting...';
  String speed = 'waiting...';
  String time = 'waiting...';

  @override
  void initState() {
    _prefs.then((SharedPreferences prefs) {
      host = prefs.getString('host') ?? "";
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedTheme(
      duration: const Duration(seconds: 1),
        data: Theme.of(context),
        child: Container(
          constraints: const BoxConstraints.expand(),
          decoration: BoxDecoration(
            image: DecorationImage(
                image: const AssetImage("assets/img.png"),
                opacity:
                AdaptiveTheme.of(context).mode.modeName.toUpperCase() == "DARK"
                    ? 1
                    : 0.1,
                fit: BoxFit.cover
            )
          ),
          // #TODO добавить нормальный свитч темы(только на черную и белую, что бы избежать бага с системной)
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: ListView(
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () => AdaptiveTheme.of(context).toggleThemeMode(),
                    style: ElevatedButton.styleFrom(
                      visualDensity:
                      const VisualDensity(horizontal: 4, vertical: 2),
                    ),
                    child: const Text('Toggle Theme Mode'),
                  ),
                  locationData('Latitude: $latitude'),
                  locationData('Longitude: $longitude'),
                  locationData('Altitude: $altitude'),
                  locationData('Accuracy: $accuracy'),
                  locationData('Bearing: $bearing'),
                  locationData('Speed: $speed'),
                  locationData('Time: $time'),
                  ElevatedButton(
                      onPressed: startLocationService,
                      child: Text('Start Location Service')),
                  ElevatedButton(
                      onPressed: () {
                        ws.close();
                        BackgroundLocation.stopLocationService();
                      },
                      child: Text('Stop Location Service')),
                  ElevatedButton(
                      onPressed: () {
                        getCurrentLocation();
                      },
                      child: Text('Get Current Location')),
                  ElevatedButton(onPressed: (){
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const Settings(),
                      ),
                    );
                  }, child: Text('open settings'))
                ],
              ),
            ),
          ),
        )
    );
  }

  Widget locationData(String data) {
    return Text(
      data,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
      textAlign: TextAlign.center,
    );
  }
  void getCurrentLocation() {
    BackgroundLocation().getCurrentLocation().then((location) {
      print('This is current Location ' + location.toMap().toString());
    });
  }
  void startLocationService() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? host = prefs.getString('host');
    ws == null ? ws = WebSocketWorker(host!) : ws.open(host!);
    print("ws://$host");
    await BackgroundLocation.setAndroidNotification(
      title: 'Background service is running',
      message: 'Background location in progress',
      icon: '@mipmap/ic_launcher',
    );
    await BackgroundLocation.setAndroidConfiguration(1000);
    await BackgroundLocation.startLocationService();
    BackgroundLocation.getLocationUpdates((location) {
      ws.send(Request(
          '123',
          location.latitude.toString(),
          location.longitude.toString(),
          location.altitude.toString(),
          location.accuracy.toString(),
          location.bearing.toString(),
          location.speed.toString(),
          location.time.toString()
      ));
      setState(() {
        latitude = location.latitude.toString();
        longitude = location.longitude.toString();
        accuracy = location.accuracy.toString();
        altitude = location.altitude.toString();
        bearing = location.bearing.toString();
        speed = location.speed.toString();
        time = DateTime.fromMillisecondsSinceEpoch(
            location.time!.toInt())
            .toString();
      });
      print('''\n
                        Latitude:  $latitude
                        Longitude: $longitude
                        Altitude: $altitude
                        Accuracy: $accuracy
                        Bearing:  $bearing
                        Speed: $speed
                        Time: $time
                      ''');
    });
  }
  @override
  void dispose() {
    BackgroundLocation.stopLocationService();
    super.dispose();
  }
}