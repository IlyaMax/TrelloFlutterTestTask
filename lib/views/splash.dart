import 'package:flutter/material.dart';
import 'package:trellotesttask/utils/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    final sPref = SharedPreferencesData();
    sPref.getAppStatusInfo().then((value) {
      print(value);
      switch (value) {
        case AppStatus.INIT:
          Navigator.pushReplacementNamed(context, "/login");
          break;
        case AppStatus.LOGGED_IN:
          Navigator.pushReplacementNamed(context, "/main");
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SizedBox.shrink(),
    );
  }
}
