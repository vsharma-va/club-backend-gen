import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:scan_qr_attendance/HomePage/home_page.dart';
import 'package:scan_qr_attendance/LoginPage/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scan_qr_attendance/comm/communicate.dart' as comm;

class CheckPage extends StatefulWidget {
  const CheckPage({super.key});

  @override
  State<CheckPage> createState() => _CheckPageState();
}

class _CheckPageState extends State<CheckPage> {
  @override
  void initState() {
    _checkAuthStatus();
    super.initState();
  }

  void _checkAuthStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // final response =
    //     comm.checkAuthState("accessToken", "refreshToken", "supabaseId");
    // response.then((value) {
    //   if (value.statusCode == 422) {
    //     final Map parsed = jsonDecode(value.body);
    //     log(parsed.toString());
    //     // Navigator.push(context,
    //     //     MaterialPageRoute(builder: (context) => const LoginPage()));
    //   } else if (value.statusCode == 200) {
    //     final Map parsed = jsonDecode(value.body);
    //   }
    // });

    String? userAuthKey = prefs.getString("userAuthKey");
    if (userAuthKey != null) {
      final response = comm.checkAuthState(userAuthKey);
      response.then((value) {
        var jsonValue = json.decode(value.body);
        if (jsonValue['status'] == 200) {
          String? userName = prefs.getString("userName");
          if (userName != null) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => HomePage(
                          userAuthKey: userAuthKey,
                          userName: userName,
                        )));
          } else {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const LoginPage()));
          }
        } else if (jsonValue['status'] == '401') {
          prefs.remove("userAuthKey");
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const LoginPage()));
        }
      });
    } else {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const LoginPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
