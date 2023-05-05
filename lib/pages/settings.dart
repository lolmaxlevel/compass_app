import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:compass_app/widgets/base_button.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

final Uri _url = Uri.parse('vk://vk.com/artbears');

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
    print(height);
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
                        AdaptiveTheme.of(context).mode.isDark
                            ? "assets/icons/darkTheme.png"
                            : "assets/icons/lightTheme.png",
                        height: width * 0.21,
                        width: width * 0.21,
                        color: Theme.of(context).primaryColor,
                        key: ValueKey<bool>(AdaptiveTheme.of(context).mode.isDark),
                      )
                  ),
                  Padding(padding: EdgeInsets.symmetric(vertical: height * 0.06),),
                  BaseButton(data: "change theme", onTap: toggleTheme),
                  const Padding(padding: EdgeInsets.only(top: 20)),
                  BaseButton(data: "how it works", onTap: (){}),
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
