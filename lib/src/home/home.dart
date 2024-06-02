import 'package:flutter/material.dart';
import 'package:pfe2024/src/home/screens/splash.dart';
import 'util/const.dart';

class Start extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<Start> {
  late ThemeData _theme;
  late ThemeData _darkTheme;

  @override
  void initState() {
    super.initState();
    // Initialize theme and dark theme here
    _theme = ThemeData.light();
    _darkTheme = ThemeData.dark();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: GlobalKey<NavigatorState>(),
      debugShowCheckedModeBanner: false,
      title: Constants.appName,
      theme: _theme,
      darkTheme: _darkTheme,
      home: SplashScreen(),
    );
  }
}
