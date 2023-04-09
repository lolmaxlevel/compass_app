import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:background_location/background_location.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:compass_app/pages/settings.dart';


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
  String latitude = 'waiting...';
  String longitude = 'waiting...';
  String altitude = 'waiting...';
  String accuracy = 'waiting...';
  String bearing = 'waiting...';
  String speed = 'waiting...';
  String time = 'waiting...';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedTheme(
      duration: const Duration(seconds: 1),
        data: Theme.of(context),
        child: Scaffold(
          appBar: AppBar(
            title: Text(AdaptiveTheme.of(context).mode.modeName.toUpperCase()),
          ),
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
    final channel = WebSocketChannel.connect(
      Uri.parse('ws://192.168.0.105:9000'),
    );
    await BackgroundLocation.setAndroidNotification(
      title: 'Background service is running',
      message: 'Background location in progress',
      icon: '@mipmap/ic_launcher',
    );
    await BackgroundLocation.setAndroidConfiguration(1000);
    await BackgroundLocation.startLocationService();
    BackgroundLocation.getLocationUpdates((location) {
      channel.sink.add("lat:${location.latitude} alt:${location.altitude} time:${location.time.toString()}");
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