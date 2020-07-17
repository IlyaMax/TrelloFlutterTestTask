import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesData {
  static final String _appStatusKey = "APP_STATUS";

  Future<void> setAppStatusInfo(AppStatus appStatus) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setInt(_appStatusKey, appStatus.index);
  }

  Future<AppStatus> getAppStatusInfo() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (!pref.containsKey(_appStatusKey))
      return AppStatus.INIT;
    else
      return AppStatus.values[pref.getInt(_appStatusKey)];
  }
}

enum AppStatus { INIT, LOGGED_IN }
