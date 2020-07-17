import 'dart:io';

import 'package:flutter/material.dart';
import 'package:trellotesttask/utils/failure.dart';
import 'package:trellotesttask/utils/shared_preferences.dart';
import 'package:trellotesttask/utils/token_storage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _tfUsernameController = TextEditingController();
  final _tfPasswordController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ThemeData theme;
  var loading = false;

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    final widgetsWidth = 300.0;
    return Scaffold(
      key: _scaffoldKey,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: widgetsWidth,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
                controller: _tfUsernameController,
                decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.person_outline,
                      color: theme.primaryColor,
                    ),
                    hintText: "Username"),
              ),
            ),
            Container(
              width: widgetsWidth,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
                controller: _tfPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: theme.primaryColor,
                    ),
                    hintText: "Password"),
              ),
            ),
            (loading)
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  )
                : Container(
                    width: widgetsWidth,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: RaisedButton(
                      onPressed: () => _loginPressed(_tfUsernameController.text, _tfPasswordController.text),
                      color: theme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Text("Login", style: theme.textTheme.button.copyWith(color: Colors.white)),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  _loginPressed(String username, String password) async {
    if (_tfUsernameController.text == "") {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Username field is blank"),
        duration: Duration(seconds: 1),
        backgroundColor: theme.primaryColorDark,
      ));
      return;
    } else if (_tfPasswordController.text == "") {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Password field is blank"),
        duration: Duration(seconds: 1),
        backgroundColor: theme.primaryColorDark,
      ));
      return;
    }
    setState(() {
      loading = true;
    });
    try {
      await TokenStorage.obtainToken(username, password);
      final sPref = SharedPreferencesData();
      await sPref.setAppStatusInfo(AppStatus.LOGGED_IN);
      Navigator.pushReplacementNamed(context, "/main");
    } on UserFailure catch (e) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(e.message),
        duration: Duration(seconds: 1),
        backgroundColor: theme.primaryColorDark,
      ));
    } catch (e) {
      print(e.message);
    }
    setState(() {
      loading = false;
    });
  }
}
