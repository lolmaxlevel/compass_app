import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:compass_app/pages/main_screen.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_){
        runApp(MyApp(savedThemeMode: savedThemeMode));
  });
}

class MyApp extends StatelessWidget {
  final AdaptiveThemeMode? savedThemeMode;
  const MyApp({
    super.key,
    this.savedThemeMode
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(seconds: 1),
      child: AdaptiveTheme(
        light: ThemeData(
          colorScheme:
          const ColorScheme.light(),
          primaryColor: const Color.fromARGB(255, 152, 152, 152),
        ),
        dark: ThemeData(
          colorScheme:
          const ColorScheme.dark(),
          primaryColor: const Color.fromARGB(255, 119, 119, 119),
        ),
        initial: savedThemeMode ?? AdaptiveThemeMode.light,
        builder: (theme, darkTheme) => MaterialApp(
          theme: theme,
          darkTheme: darkTheme,
          home: const MainScreen(),
        ),
      )
    );
  }
}