import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:scan_qr_attendance/const_value.dart' as constValue;

Future<http.Response> checkAuthState(String userAuthKey) async {
  final response = await http.post(
    Uri.parse("https://neura-ai-backend.vercel.app/auth/app/signin/"),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'app_user_auth_key': userAuthKey,
    }),
  );
  return response;
}

Future<http.Response> scanCode(String jwtQr, String userAuthKey) async {
  final response = await http.post(
    Uri.parse("https://neura-ai-backend.vercel.app/event/check_qr/"),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'app_user_auth_key': userAuthKey,
      'jwt_qr': jwtQr,
    }),
  );
  return response;
}

Future<http.Response> checkCode(String code, String vendorAuthKey) async {
  final response =
      await http.post(Uri.parse("${constValue.apiUri}/api/vendor/check"),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'vendorAuthKey': vendorAuthKey,
            'code': code,
          }));
  return response;
}
