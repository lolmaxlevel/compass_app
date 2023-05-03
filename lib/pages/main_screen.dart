import 'dart:async';

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
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/server_io.dart';
import 'package:mutex/mutex.dart';

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
  late WebSocketChannel channel;
  bool isServerConnected = false;
  late StreamSubscription channelSubscription;
  String host = "";
  String id = "";
  String location = "";
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    _prefs.then((SharedPreferences prefs) {
      host = prefs.getString('host') ?? "localhost:9000";
      id = prefs.getString('id')??"";
      print(id);
    });
    connect();
    super.initState();
  }

  void connect() async {
    _prefs.then((SharedPreferences prefs) {
      host = prefs.getString('host') ?? "localhost:9000";
    });
    if (host == " ") {
      reconnect();
      return;
    }
    // #TODO add "handshake"
    channel = WebSocketChannel.connect(Uri.parse('ws://$host'));
    var prefs = await SharedPreferences.getInstance();
    sendMessage(HandShakeRequest(id, prefs.getString('partner_id')??""));
    channelSubscription = channel.stream.listen((message) {
      if (kDebugMode) {
        print('Received: $message');
      }
    }, onError: (error) {
      if (kDebugMode) {
        print('Error while receiving');
      }
      reconnect();
    }, onDone: () {
      if (kDebugMode) {
        print('Done');
      }
    });
    setState(() {
      isServerConnected = true;
    });
  }

  void reconnect() {
    if (kDebugMode) {
      print('Reconnecting...');
    }
    setState(() {
      isServerConnected = false;
    });
    Timer(const Duration(seconds: 5), () {
      connect();
    });
  }
  void sendMessage(Request request) {
    if (isServerConnected) {
      channel.sink.add(request);
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
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
                       child: Image.asset("assets/background.png", fit: BoxFit.fill,),
                 )
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
                      ElevatedButton(onPressed: (){
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const Settings(),
                          ),
                        );
                        }, child: const Text('open settings')),
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