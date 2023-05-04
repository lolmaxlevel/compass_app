import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/icons/themeChangeIcon.png",
                    height: width * 0.21,
                    width: width * 0.21,
                    color: Theme.of(context).primaryColor,
                  ),
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
    AdaptiveTheme.of(context).mode.isDark
        ? AdaptiveTheme.of(context).setLight()
        : AdaptiveTheme.of(context).setDark();
  }
}
