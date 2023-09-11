import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:scan_qr_attendance/LoginPage/login_page.dart';
import 'package:scan_qr_attendance/components/common_button.dart';
import 'package:scan_qr_attendance/components/common_gradient_text.dart';
import 'package:scan/scan.dart';
import 'package:scan_qr_attendance/components/common_snack_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scan_qr_attendance/comm/communicate.dart' as comm;

class HomePage extends StatefulWidget {
  final String userName;
  final String userAuthKey;
  const HomePage(
      {super.key, required this.userAuthKey, required this.userName});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ScanController scanController = ScanController();
  String qrcode = 'Unknown';
  bool scanIntent = false;

  @override
  void initState() {
    scanController.pause();
    super.initState();
  }

  void attemptScan(String scannedString) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userAuthKey = prefs.getString("userAuthKey");
    if (userAuthKey != null) {
      final response = await comm.scanCode(scannedString, userAuthKey);
      var jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == 422) {
        context.showCommonSnackBar(
            message:
                "(${(jsonResponse['status'])}) ${jsonResponse['detail']['msg']}");
      } else if (jsonResponse['status'] == 409) {
        context.showCommonSnackBar(
            message:
                "(${jsonResponse['status']}) ${jsonResponse['detail']['msg']}");
      } else if (jsonResponse['status'] == 200) {
        context.showCommonSnackBar(
            message:
                "(${jsonResponse['status']}) ${jsonResponse['detail']['msg']} the fuck",
            backgroundColor: const Color.fromRGBO(102, 187, 106, 1));
      } else if (jsonResponse['status'] == 401) {
        context.showCommonSnackBar(
            message:
                "(${jsonResponse['status']}) ${jsonResponse['detail']['msg']}");
      }
    } else {
      prefs.remove("userAuthKey");
      context.showCommonSnackBar(message: "Auth State Lost");
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const LoginPage()));
    }
  }

  void logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("userAuthKey");
    prefs.remove("userName");
    context.showCommonSnackBar(message: "Logged Out");
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: SizedBox.expand(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox.expand(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      alignment: Alignment.topLeft,
                      child: FittedBox(
                        child: GradientText(
                          "Hi ${widget.userName}!",
                          40,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.height *
                                0.55, // custom wrap size
                            height: MediaQuery.of(context).size.width * 0.75,
                            child: ScanView(
                              controller: scanController,
                              // custom scan area, if set to 1.0, will scan full area
                              scanAreaScale: .9,
                              scanLineColor: Colors.green.shade400,
                              onCapture: (data) {
                                attemptScan(data);
                              },
                            ),
                          ),
                          const SizedBox(height: 45),
                          Container(
                            alignment: Alignment.bottomCenter,
                            child: CommonButton(
                              onPressed: () {
                                if (scanIntent) {
                                  scanController.resume();
                                } else {
                                  scanController.pause();
                                }
                                scanIntent = !scanIntent;
                              },
                              child: const Text(
                                "Scan",
                                style: TextStyle(
                                    fontSize: 24, color: Colors.white),
                              ),
                            ),
                          ),
                          Container(
                              alignment: Alignment.bottomRight,
                              child: ElevatedButton(
                                onPressed: logout,
                                child: const Text("Refresh"),
                              ))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
