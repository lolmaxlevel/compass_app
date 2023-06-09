import 'dart:async';
import 'dart:convert';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:compass_app/widgets/AnimatedHeart.dart';
import 'package:compass_app/widgets/base_button.dart';
import 'package:compass_app/widgets/copy_code_widget.dart';
import 'package:compass_app/widgets/paste_code_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:compass_app/pages/settings.dart';
import '../controllers/bluetooth_controller.dart';
import '../models/server_io.dart';
import 'package:web_socket_client/web_socket_client.dart';
import 'package:page_transition/page_transition.dart';
import 'package:http/http.dart' as http;
import '../utils/location_utils.dart';
import 'package:geolocator/geolocator.dart';

// #TODO refactor all of this trash code, remove all logic from the UI
// #TODO add some kind of state management
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
  bool heartClicked = false;
  bool isServerConnected = true;
  String id = "";
  late Position location;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late final WebSocket socket;

  ValueNotifier<bool> isCompassConnected = BTController().isConnected;

  late Future<String> futureHost;
  late String host;

  bool ledState = false;

  BluetoothConnection? connection;

  late StreamSubscription<Position> positionStream;

  @override
  void initState() {
    super.initState();
    _prefs.then((SharedPreferences prefs) {
      id = prefs.getString('id')??"";
      if (id.length < 6){
        while (id.length < 6) {
          id = (UniqueKey().hashCode % 1000000).toString();
        }
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
      // parse location into location object
      // get azimuth
      // send azimuth via bluetooth
      var locationJson = jsonDecode(message);
      var bearing = LocationUtils().getBearing(
          location.latitude,
          location.longitude,
          double.parse(locationJson["lat"]),
          double.parse(locationJson["long"]),
      );
      if (isCompassConnected.value && heartClicked) {
        BTController().sendMessage((bearing+(bearing < 0 ? 360 : 0)).toString());
      }
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
                      AnimatedHeart(
                          onPressed: toggleLocation,
                          isServerConnected: isServerConnected,
                          isCompassConnected: isCompassConnected.value,
                      ),
                      AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return FadeTransition(
                                opacity: animation,
                                child: child
                            );},
                          child: ValueListenableBuilder(
                            valueListenable: isCompassConnected,
                            builder: (BuildContext context, bool value, Widget? child) { return Text(
                              heartClicked
                                  ? (!isCompassConnected.value
                                  ? "sharing":"the compass points at your love")
                                  : (!isCompassConnected.value
                                  ? "not sharing":"the compass is stopped"),
                              key: ValueKey(heartClicked),
                              style: Theme.of(context).textTheme.bodyLarge,
                            );},
                          )
                      ),
                      Padding(padding: EdgeInsets.only(top: height*0.1)),
                      const BaseButton(data: 'copy the code', child: CopyCode()),
                      const Padding(padding: EdgeInsets.only(top: 10)),
                      const Text('or', style: TextStyle(fontSize: 20),),
                      const Padding(padding: EdgeInsets.only(top: 10)),
                      const BaseButton(data: "paste the code", child: PasteCode()),
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
    //remove !
    if (isCompassConnected.value) {
        sendMessage(
            CompassRequest(
                id: id,
                partnerId: prefs.getString('partner_id')??"",
                status: heartClicked ? "stop" : "start"
            ));
      }

    heartClicked ? stopLocation() : startLocationService();

    setState(() {
      heartClicked = !heartClicked;
    });
  }

  void startLocationService() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    /// Determine the current position of the device.
    ///
    /// When the location services are not enabled or permissions
    /// are denied the `Future` will return an error.
      bool serviceEnabled;
      LocationPermission permission;
      // #TODO this should be handled better
      // Test if location services are enabled.
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled don't continue
        // accessing the position and request users of the
        // App to enable the location services.
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions are denied, next time you could try
          // requesting permissions again (this is also where
          // Android's shouldShowRequestPermissionRationale
          // returned true. According to Android guidelines
          // your App should show an explanatory UI now.
          return Future.error('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever, handle appropriately.
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 0,
    );

    positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
            (Position? position) {
              if (kDebugMode) {
                print(position == null ? 'Unknown' : '${position.latitude.toString()}, ${position.longitude.toString()}');
              }
              if (position != null) {
                location = position;
                if (!isCompassConnected.value) {
                  location = position;
                  sendMessage(
                      LocationRequest(
                          "location",
                          prefs.getString('id') ?? "",
                          position.latitude.toString(),
                          position.longitude.toString(),
                          position.altitude.toString(),
                          position.accuracy.toString(),
                          position.heading.toString(),
                          position.speed.toString(),
                          DateTime
                              .now()
                              .microsecondsSinceEpoch
                              .toString()));
                }
              }
            }
    );
  }
  
  void stopLocation(){
    positionStream.cancel();
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

  void setConnection(BluetoothConnection connection){
    setState(() {
      this.connection = connection;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

}