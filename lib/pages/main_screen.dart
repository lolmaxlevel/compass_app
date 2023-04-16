import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:background_location/background_location.dart';
import 'package:compass_app/web_socket_worker.dart';
import 'package:compass_app/widgets/base_button.dart';
import 'package:compass_app/widgets/copy_code_widget.dart';
import 'package:compass_app/widgets/paste_code_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:compass_app/pages/settings.dart';
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
  bool flag = true;
  dynamic ws;
  String host = "";
  String id = "";
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Widget heartImage = Image.asset('assets/heart/heart-crossed.png',
    width: 100, height: 100, color: Theme.of(context).primaryColor,);
  @override
  void initState() {
    _prefs.then((SharedPreferences prefs) {
      host = prefs.getString('host') ?? "";
      id = prefs.getString('id')??"";
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
                      GestureDetector(
                        onTap: () {
                          changeHeart();
                        },
                        child: AnimatedSwitcher(
                          duration: const Duration(seconds: 1),
                          child: heartImage,
                      ),
                      ),
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
                      ElevatedButton(
                          onPressed: startLocationService,
                          child: Text('Start Location Service')),
                      ElevatedButton(
                          onPressed: () {
                            if (ws!=null){
                              ws.close();
                            }
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

  void changeHeart(){
    setState(() {
      flag = !flag;
      heartImage = Image.asset(flag?'assets/heart/heart.png':'assets/heart/heart-crossed.png',
        width: 100, height: 100, color: Theme.of(context).primaryColor,);
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
    host = prefs.getString('host')??"";
    id = prefs.getString('id')??"";
    ws == null ? ws = WebSocketWorker("$host/$id") : ws.open("$host/$id");
    if (kDebugMode) {
      print("trying to connect $host/$id");
    }
    await BackgroundLocation.setAndroidNotification(
      title: 'Background service is running',
      message: 'Background location in progress',
      icon: '@mipmap/ic_launcher',
    );

    await BackgroundLocation.setAndroidConfiguration(1000);
    await BackgroundLocation.startLocationService();
    BackgroundLocation.getLocationUpdates((location) {
      if (lock.isLocked) return;

      lock.protect(() {
        print('''\n
                        Latitude:  ${location.latitude.toString()}
                        Longitude: ${location.longitude.toString()}
                        Altitude: ${location.altitude.toString()}
                        Accuracy: ${location.accuracy.toString()}
                        Speed: ${location.speed.toString()}
                        Time: ${DateTime.now().toString()}
                      ''');

        ws.send(Request(
          prefs.getString('id')??"",
          prefs.getString('partner_id')??"",
          location.latitude.toString(),
          location.longitude.toString(),
          location.altitude.toString(),
          location.accuracy.toString(),
          location.bearing.toString(),
          location.speed.toString(),
          DateTime.now().toLocal().toString(),
        ));

        return Future.delayed(const Duration(milliseconds: 100));
      });
    });
  }

  @override
  void dispose() {
    BackgroundLocation.stopLocationService();
    super.dispose();
  }
}