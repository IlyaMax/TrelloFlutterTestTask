import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:trellotesttask/utils/failure.dart';

class TokenStorage {
  static const _tokenKey = "TOKEN_KEY";

  //obtains and saves token
  static Future<void> obtainToken(String username, String password) async {
    try {
      final response = await http.post("https://trello.backend.tests.nekidaem.ru/api/v1/users/login/", body: {
        "username": username,
        "password": password,
      });
      print("STATUS of obtaining token: ${response.statusCode}");
      if (response.statusCode == 200) {
        final token = json.decode(response.body)["token"];
        final storage = FlutterSecureStorage();
        await storage.write(key: _tokenKey, value: token);
        print("Successfully logged in");
      } else {
        if (response.statusCode == 400 && json.decode(response.body)["non_field_errors"] != null) {
          throw UserFailure("Wrong credentials");
        } else {
          throw UserFailure("Authorization error");
        }
      }
    } on SocketException {
      throw ConnectionFailure();
    } catch (e) {
      print(e.message);
      throw UserFailure("Authorization error");
    }
  }

  //returns refreshed token from server
  static Future<String> obtainRefreshedToken() async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: _tokenKey);
    final response = await http.post("https://trello.backend.tests.nekidaem.ru/api/v1/users/refresh_token/", body: {
      "token": token,
    });
    print("STATUS of obtaining refreshed token: ${response.statusCode}");
    if (response.statusCode == 200) {
      return Future.value(json.decode(response.body)["token"]);
    } else if (response.statusCode == 400) {
      throw TokenExpiredFailure();
    }
    throw ConnectionFailure();
  }
}
