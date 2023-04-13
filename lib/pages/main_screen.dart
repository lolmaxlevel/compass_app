import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:background_location/background_location.dart';
import 'package:compass_app/web_socket_worker.dart';
import 'package:compass_app/widgets/base_button.dart';
import 'package:compass_app/widgets/first_code.dart';
import 'package:compass_app/widgets/paste_code_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  Widget _animatedButton = const Text("copy the code");
  bool _buttonPressed = false;
  Widget _animatedButton2 = const Text("paste the code");
  bool _button2Pressed = false;
  bool flag = true;
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

  void _onButtonPressed() {
    setState(() {
      _buttonPressed = !_buttonPressed;
      if (_buttonPressed) {
        _animatedButton = const CopyCode();
      } else {
        _animatedButton = const Text("copy the code");
      }
    });
  }
  void _onButton2Pressed() {
    setState(() {
      _button2Pressed = !_button2Pressed;
      if (_button2Pressed) {
        _animatedButton2 = const PasteCode();
      } else {
        _animatedButton2 = const Text("paste the code");
      }
    });
  }

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
        child: Stack(
          children: [
            //Background Image
            Positioned.fill(
                 child: SizedBox(
                     child: AnimatedOpacity(
                       opacity:  AdaptiveTheme.of(context).mode.isDark? 0.15 : 1,
                       duration: const Duration(milliseconds: 700),
                       child: Image.asset("assets/img.png", fit: BoxFit.fill,),
                 )
                 )
            ),
            Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                child: Center(
                  child: Column(
                    children: [
                      Image.asset(flag?'assets/heart.png':'assets/heart2.png'),
                      const BaseButton(data: 'copy the code', child: CopyCode()),
                      const Text('or'),
                     const BaseButton(data: "paste the code", child: PasteCode()),
                      ElevatedButton(
                        onPressed: () => toggleTheme(),
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
                      ElevatedButton(onPressed: (){
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const Settings(),
                          ),
                        );
                      }, child: Text('open settings')),
                    ],
                  ),
                ),
              ),
            ),
          ],
        )
    );
  }

  Widget locationData(String data) {
    return Text(
      data,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
      textAlign: TextAlign.center,
    );
  }
  void flagInvert(){
    setState(() {
      flag = !flag;
    });
  }
  void toggleTheme(){
    if (AdaptiveTheme.of(context).mode.isDark)
    {
      AdaptiveTheme.of(context).setLight();
    }
    else
    {
      AdaptiveTheme.of(context).setDark();
    }
  }
  void startLocationService() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? host = prefs.getString('host');
    ws == null ? ws = WebSocketWorker(host!) : ws.open(host!);
    if (kDebugMode) {
      print("trying to connect $host");

    }await BackgroundLocation.setAndroidNotification(
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
          DateTime.fromMillisecondsSinceEpoch(location.time as int).toString(),
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