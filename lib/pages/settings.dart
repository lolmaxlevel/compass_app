import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:compass_app/widgets/base_button.dart';
import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late String themeIcon;

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    AdaptiveTheme.of(context).mode.isDark
        ? themeIcon = "assets/icons/darkTheme.png"
        : themeIcon = "assets/icons/lightTheme.png";
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return AnimatedTheme(
      data: Theme.of(context),
      duration: const Duration(seconds: 1),
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
                      duration: const Duration(milliseconds: 500),
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedSwitcher(
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
                        themeIcon,
                        height: width * 0.21,
                        width: width * 0.21,
                        color: Theme.of(context).primaryColor,
                        key: ValueKey<String>(themeIcon),
                      )
                  ),
                  BaseButton(data: "toggle Theme", onTap: toggleTheme),
                  BaseButton(data: "how it works", onTap: (){}),
                  ElevatedButton(
                    onPressed: toggleTheme,
                    child: const Text("Toggle Theme"),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void toggleTheme() {
    if(AdaptiveTheme.of(context).mode.isDark){
      AdaptiveTheme.of(context).setLight();
      setState(() {
        themeIcon = "assets/icons/lightTheme.png";
      });
    }
    else {
      AdaptiveTheme.of(context).setDark();
      setState(() {
        themeIcon = "assets/icons/darkTheme.png";
      });
    }
  }
}
