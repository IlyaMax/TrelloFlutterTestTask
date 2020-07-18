import 'package:flutter/material.dart';
import 'package:trellotesttask/views/login.dart';
import 'package:trellotesttask/views/main.dart';
import 'package:trellotesttask/views/splash.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trello Test Task',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        primaryColorDark: Colors.teal[800],
        accentColor: Colors.teal[200],
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: SplashPage.routeName,
      routes: {
        SplashPage.routeName: (context) => SplashPage(),
        LoginPage.routeName: (context) => LoginPage(),
        MainPage.routeName: (context) => MainPage(),
      },
    );
  }
}
