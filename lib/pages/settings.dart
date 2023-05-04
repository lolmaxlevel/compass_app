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
                      duration: const Duration(milliseconds: 500),
                      child: Image.asset("assets/background.png", fit: BoxFit.fill),
                    ),
                  ),
                )
            ),
          ],
        )
    );
  }
}
