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
    return AdaptiveTheme(
      light: ThemeData(
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color.fromARGB(255, 152, 152, 152),  fontSize: 20),
          bodyMedium: TextStyle(color: Color.fromARGB(255, 95, 95, 95))
        ),
        fontFamily: 'Lexend',
        primaryColor: const Color.fromARGB(255, 152, 152, 152),
        colorScheme:
        const ColorScheme.light(
          background: Color.fromARGB(255, 242, 242, 242),
      ),

      ),
      dark: ThemeData(
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color.fromARGB(255, 119, 119, 119), fontSize: 20),
          bodyMedium: TextStyle(color: Color.fromARGB(255, 242, 242, 242))
        ),
        fontFamily: 'Lexend',
        primaryColor: const Color.fromARGB(255, 119, 119, 119),
        colorScheme:
        const ColorScheme.dark(
          background: Color.fromARGB(255, 39, 39, 39),
        ),
      ),
      initial: savedThemeMode ?? AdaptiveThemeMode.light,
      builder: (theme, darkTheme) => MaterialApp(
        theme: theme,
        darkTheme: darkTheme,
        home: const MainScreen(),
      ),
    );
  }
}