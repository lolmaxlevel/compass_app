import 'dart:math';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:compass_app/pages/swiper.dart';
import 'package:compass_app/widgets/base_button.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:random_color_scheme/random_color_scheme.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/bluetooth_сontroller.dart';

final Uri _url = Uri.parse('vk://vk.com/artbears');

class Settings extends StatefulWidget {

  const Settings({
    Key? key,
  }) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

ValueNotifier isCompassConnectedListener = BTController().isConnected;

class _SettingsState extends State<Settings> {
  bool isCompassConnected = BTController().isConnected.value;
  bool isRandomTheme = false;
  var blueToothController = BTController();
  @override
  void initState() {
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    isCompassConnectedListener.addListener(() {
      setState(() {isCompassConnected = isCompassConnectedListener.value;});
    });
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return AnimatedTheme(
      data: Theme.of(context),
      duration: const Duration(milliseconds: 700),
      child: Stack(
        children: [
          //Background Image
          Positioned.fill(
              child: SizedBox(
                  child: Container(
                    decoration:
                    BoxDecoration(color: Theme.of(context).colorScheme.background),
                    child: AnimatedOpacity(
                      opacity: AdaptiveTheme.of(context).mode.isDark ? 0.2 : 1,
                      duration: const Duration(milliseconds: 700),
                      child: Image.asset("assets/background.png", fit: BoxFit.fill),
                    ),
                  )
              )
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: Center(
              child: Column(
                children: [
                  Padding(padding: EdgeInsets.symmetric(vertical: height * 0.065)),
                  GestureDetector(
                    onLongPress: toggleRandomTheme,
                    onTap: toggleTheme,
                    child: AnimatedSwitcher(
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return RotationTransition(
                              turns: animation,
                              child: child
                          );
                        },
                        layoutBuilder: (currentChild, previousChildren) {
                          return currentChild!;
                        },
                        switchInCurve: Curves.elasticOut,
                        duration: const Duration(milliseconds: 2000),
                        child: Image.asset(
                          AdaptiveTheme.of(context).mode.isDark
                              ? "assets/icons/darkTheme.png"
                              : "assets/icons/lightTheme.png",
                          height: width * 0.21,
                          width: width * 0.21,
                          color: Theme.of(context).primaryColor,
                          key: ValueKey<bool>(AdaptiveTheme.of(context).mode.isDark),
                        )
                    ),
                  ),
                  Padding(padding: EdgeInsets.symmetric(vertical: height * 0.06),),
                  AnimatedSwitcher(
                    duration: const Duration(seconds: 1),
                    key: ValueKey<bool>(isCompassConnected),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return ScaleTransition(
                          scale: animation,
                          child: child
                      );
                    },
                    child: BaseButton(
                        data: isCompassConnected
                            ? "disconnect compass"
                            : "connect compass",
                        onTap:isCompassConnected
                            ? disconnectCompass
                            : connectCompass)
                  ),
                  // ElevatedButton(onPressed:() => BTController().sendMessage("aboba"), child: Text("send")),
                  const Padding(padding: EdgeInsets.only(top: 20)),
                  BaseButton(data: "how it works", onTap: (){Navigator.push(context,
                      PageTransition(
                          type: PageTransitionType.fade,
                          child: const MySwiper()
                      )
                  );}),
                  const Padding(padding: EdgeInsets.only(top: 100)),
                  BaseButton(data: "visit our VK", onTap: (){_launchUrl();}),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void connectCompass() async {
    blueToothController.connect();
  }
  void disconnectCompass() async {
    blueToothController.disconnect();
  }

  void toggleRandomTheme() {
    if (isRandomTheme){
      AdaptiveTheme.of(context).reset();
      isRandomTheme = false;
    } else {
      isRandomTheme = true;
      AdaptiveTheme.of(context).setTheme(
        light: ThemeData(colorScheme: randomColorSchemeLight(), primaryColor: Colors.primaries[Random().nextInt(Colors.primaries.length)]),
        dark: ThemeData(colorScheme: randomColorSchemeDark(), primaryColor: Colors.primaries[Random().nextInt(Colors.primaries.length)]),
      );
    }
  }

  void toggleTheme() {
    AdaptiveTheme.of(context).mode.isDark
        ? AdaptiveTheme.of(context).setLight()
        : AdaptiveTheme.of(context).setDark();
    }

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }
  }
