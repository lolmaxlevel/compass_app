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
import 'package:page_transition/page_transition.dart';
import 'package:http/http.dart' as http;

class MainScreen extends StatefulWidget {
  final AdaptiveThemeMode? savedThemeMode;

  const MainScreen({
    super.key,
    this.savedThemeMode
  });

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  final lock = Mutex();
  bool heartClicked = false;
  bool isServerConnected = true;
  String id = "";
  String location = "";
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late final WebSocket socket;
  bool compassConnected = false;
  late Future<String> futureHost;
  late String host;

  @override
  void initState() {
    super.initState();
    _prefs.then((SharedPreferences prefs) {
      id = prefs.getString('id')??"";
      if (id == ""){
        id = (UniqueKey().hashCode % 1000000).toString();
      }
      prefs.setString('id', id);
    });
    futureHost = fetchHost();
    futureHost.then((value) => host = value);
    futureHost.whenComplete(
            () => connectToServer()
    );
  }

  void connectToServer(){
    socket = WebSocket(
        Uri.parse("ws://$host"),
        timeout: const Duration(seconds: 5),
        backoff: const ConstantBackoff(Duration(seconds: 5))
    );
    socket.messages.listen((message) {
      print("new nessage: $message");
    });
    socket.connection.listen((state) {
      if (state == const Connecting() || state == const Reconnecting()){
        if (kDebugMode) {
          print("connecting");
        }
        // use provider right here
        // if (heartClicked){
        //   toggleLocation();
        // }
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
        sendMessage(HandShakeRequest(id));
      }
      if (state == const Disconnected()){
        if (kDebugMode) {
          print("disconnected");
        }
        if (heartClicked){
          toggleLocation();
        }
        setState(() {
          isServerConnected = false;
        });
      }
    });
  }

  void sendMessage(Request request) {
    if (isServerConnected) {
      if (kDebugMode) {
        print("sending message");
      }
      socket.send(jsonEncode(request));
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
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
                      Padding(padding: EdgeInsets.symmetric(vertical: height*0.10)),
                      AnimatedHeart(onPressed: toggleLocation, isServerConnected: isServerConnected, isCompassConnected: compassConnected),
                      AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return FadeTransition(
                                opacity: animation,
                                child: child
                            );},
                          child: Text(
                            heartClicked
                                ? (!compassConnected
                                ? "sharing":"the compass points at your love")
                                : (!compassConnected
                                ? "not sharing":"the compass is stopped"),
                            key: ValueKey(heartClicked),
                            style: Theme.of(context).textTheme.bodyLarge,
                          )
                      ),
                      Padding(padding: EdgeInsets.only(top: height*0.1)),
                      const BaseButton(data: 'copy the code', child: CopyCode()),
                      const Padding(padding: EdgeInsets.only(top: 10)),
                      const Text('or', style: TextStyle(fontSize: 20),),
                      const Padding(padding: EdgeInsets.only(top: 10)),
                      const BaseButton(data: "paste the code", child: PasteCode()),
                      ElevatedButton(onPressed:
                          () => {setState(() {
                          compassConnected = !compassConnected;}),
                          },
                          child: Text(compassConnected?"disconnect compass":"connect compass")),
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: EdgeInsets.only(bottom: height*0.09),
                            child: GestureDetector(
                                onTap: () => Navigator.push(context,
                                    PageTransition(
                                        type: PageTransitionType.fade,
                                        child: const Settings()
                                    )
                                ),
                                child: Tooltip(
                                  message: 'open settings',
                                  child: Image.asset(
                                      'assets/icons/settings.png',
                                      width: width * 0.12,
                                      height: width * 0.12,
                                      color: Theme.of(context).textTheme.bodyLarge!.color,
                                      semanticLabel: 'settings'
                                  ),
                                )
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            isServerConnected ? '' : 'Server disconnected',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        )
    );
  }

  void toggleLocation() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (compassConnected) {
        sendMessage(
            CompassRequest(
                id: id,
                partnerId: prefs.getString('partner_id')??"",
                status: heartClicked ? "stop" : "start"
            ));
      }
    else {
      heartClicked ? stopLocation() : startLocationService();
    }
    setState(() {
      heartClicked = !heartClicked;
    });
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

  Future<String> fetchHost() async {
    final response =
    await http.get(Uri.parse('https://pastebin.com/raw/UK7tXhnn'));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return response.body;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  @override
  void dispose() {
    BackgroundLocation.stopLocationService();
    super.dispose();
  }
}