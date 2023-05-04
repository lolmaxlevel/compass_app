import 'dart:async';
import 'dart:convert';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:background_location/background_location.dart';
import 'package:compass_app/widgets/AnimatedHeart.dart';
import 'package:compass_app/widgets/base_button.dart';
import 'package:compass_app/widgets/copy_code_widget.dart';
import 'package:compass_app/widgets/paste_code_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:compass_app/pages/settings.dart';
import '../models/server_io.dart';
import 'package:mutex/mutex.dart';
import 'package:web_socket_client/web_socket_client.dart';

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
  final lock = Mutex();
  bool heartClicked = false;
  bool isServerConnected = false;
  late StreamSubscription channelSubscription;
  String host = "";
  String id = "";
  String location = "";
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late final WebSocket socket;

  @override
  void initState() {
    _prefs.then((SharedPreferences prefs) {
      host = prefs.getString('host') ?? "localhost:9000";
      id = prefs.getString('id')??"";
      if (id == ""){
        id = (UniqueKey().hashCode % 1000000).toString();
      }
      prefs.setString('id', id);
    });
    socket = WebSocket(
        Uri.parse('ws://192.168.0.106:9000'),
        timeout: const Duration(seconds: 5),
        backoff: const ConstantBackoff(Duration(seconds: 5))
    );
    socket.connection.listen((state) {
      if (state == const Connecting() || state == const Reconnecting()){
        if (kDebugMode) {
          print("connecting");
        }
        setState(() {
          isServerConnected = false;
        });

      }
      if (state == const Connected() || state == const Reconnected()){
        if (kDebugMode) {
          print("connected");
        }
        setState(() {
          isServerConnected = true;
        });
      }
      if (state == const Disconnected()){
        if (kDebugMode) {
          print("disconnected");
        }
        setState(() {
          isServerConnected = false;
        });
      }
    });
    super.initState();
  }

  void sendMessage(Request request) {
    if (isServerConnected) {
      if (kDebugMode) {
        print("sending ${jsonEncode(request)}");
      }
      socket.send(jsonEncode(request));
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return AnimatedTheme(
      duration: const Duration(seconds: 1),
        data: Theme.of(context),
        child: Stack(
          children: [
            //Background Image
            Positioned.fill(
                 child: SizedBox(
                     child: Container(
                       decoration: BoxDecoration(color: Theme.of(context).colorScheme.background),
                       child: AnimatedOpacity(
                         opacity:  AdaptiveTheme.of(context).mode.isDark? 0.2 : 1,
                         duration: const Duration(milliseconds: 700),
                         child: Image.asset("assets/background.png", fit: BoxFit.fill),
                 ),
                     ),
                 )
            ),
            Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                child: Center(
                  child: Column(
                    children: [
                      Padding(padding: EdgeInsets.symmetric(vertical: height*0.05)),
                      AnimatedHeart(onPressed: toggleLocation),
                      Text(heartClicked?"sharing":"not sharing",
                        style: Theme.of(context).textTheme.bodyLarge,),
                      Padding(padding: EdgeInsets.only(top: height*0.1)),
                      const BaseButton(data: 'copy the code', child: CopyCode()),
                      const Padding(padding: EdgeInsets.only(top: 10)),
                      const Text('or', style: TextStyle(fontSize: 20),),
                      const Padding(padding: EdgeInsets.only(top: 10)),
                      const BaseButton(data: "paste the code", child: PasteCode()),
                      Text(location),
                      ElevatedButton(
                        onPressed: toggleTheme,
                        style: ElevatedButton.styleFrom(
                          visualDensity:
                          const VisualDensity(horizontal: 4, vertical: 2),
                        ),
                        child: const Text('Toggle Theme Mode'),
                      ),
                      GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Settings())),
                          child: Image.asset(
                              'assets/icons/settings.png',
                              width: width * 0.12,
                              height: width * 0.12,
                              color: Theme.of(context).textTheme.bodyLarge!.color,
                              semanticLabel: 'settings'
                          )
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  isServerConnected ? '' : 'Server disconnected',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
          ],
        )
    );
  }

  void toggleLocation(){
    heartClicked ? stopLocation() : startLocationService();
    setState(() {
      heartClicked = !heartClicked;
    });
  }

  void toggleTheme(){
    AdaptiveTheme.of(context).mode.isDark
        ? AdaptiveTheme.of(context).setLight()
        : AdaptiveTheme.of(context).setDark();
  }
  void startLocationService() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    BackgroundLocation.setAndroidNotification(
      title: 'Background service is running',
      message: 'Background location in progress',
      icon: '@mipmap-hdpi/ic_monochrome.png',
    );

    await BackgroundLocation.setAndroidConfiguration(1000);
    await BackgroundLocation.startLocationService();

    BackgroundLocation.getLocationUpdates((location) {
      if (lock.isLocked) return;
      lock.protect(() {
        if (kDebugMode) {
          print('''\n
                        Latitude:  ${location.latitude.toString()}
                        Longitude: ${location.longitude.toString()}
                        Altitude: ${location.altitude.toString()}
                        Accuracy: ${location.accuracy.toString()}
                        Speed: ${location.speed.toString()}
                        Time: ${DateTime.now().toString()}
                      ''');
        }

        sendMessage(
            LocationRequest(
              "location",
              prefs.getString('id')??"",
              prefs.getString('partner_id')??"",
              location.latitude.toString(),
              location.longitude.toString(),
              location.altitude.toString(),
              location.accuracy.toString(),
              location.bearing.toString(),
              location.speed.toString(),
              DateTime.now().microsecondsSinceEpoch.toString(),)
        );

        return Future.delayed(const Duration(milliseconds: 100));
      });
    });
  }
  void stopLocation(){
    BackgroundLocation.stopLocationService();
  }

  @override
  void dispose() {
    BackgroundLocation.stopLocationService();
    super.dispose();
  }
}