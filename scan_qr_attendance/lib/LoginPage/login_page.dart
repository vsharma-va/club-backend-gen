import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:scan_qr_attendance/HomePage/home_page.dart';
import 'package:scan_qr_attendance/comm/communicate.dart';
import 'package:scan_qr_attendance/components/common_button.dart';
import 'package:scan_qr_attendance/components/common_gradient_text.dart';
import 'package:scan_qr_attendance/components/common_snack_bar.dart';
import 'package:scan_qr_attendance/components/common_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var userAuthKeyController = TextEditingController();

  void attemptLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (userAuthKeyController.text == "") {
      context.showCommonSnackBar(message: "Please enter a valid auth code");
    } else {
      var response = checkAuthState(userAuthKeyController.text.toUpperCase());
      response.then((value) {
        var jsonValue = json.decode(value.body);
        if (jsonValue['status'] == 200) {
          prefs.setString(
              "userName", "${jsonValue['detail']['user_state']['user_name']}");
          prefs.setString("userAuthKey",
              "${jsonValue['detail']['user_state']['auth_key']}");
          context.showCommonSnackBar(
              message: "Login Success!",
              backgroundColor: const Color.fromRGBO(102, 187, 106, 1));
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => HomePage(
                        userAuthKey: jsonValue['detail']['user_state']
                            ['auth_key'],
                        userName: jsonValue['detail']['user_state']
                            ['user_name'],
                      )));
        } else if (jsonValue['status'] == 401) {
          context.showCommonSnackBar(
              message:
                  "(${jsonValue['status']}) ${jsonValue['detail']['msg']}");
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: Center(
            child: Container(
              alignment: Alignment.center,
              width: double.infinity,
              padding: const EdgeInsets.only(left: 15.0, right: 15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 50),
                    child: GradientText(
                      "LOGIN",
                      50,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: SizedBox(
                      width: double.infinity,
                      child: CommonTextField(
                        textInputType: TextInputType.emailAddress,
                        controller: userAuthKeyController,
                        labelText: "User Authorization Key",
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: CommonButton(
                      onPressed: attemptLogin,
                      child: const Text(
                        "Continue",
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // TextField(
              //   decoration: InputDecoration(
              //     border: OutlineInputBorder(),
              //     labelText: "Vendor Authorization Code",
              //   ),
              // ),
            ),
          ),
        ),
      ),
    );
  }
}
