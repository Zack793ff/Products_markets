import 'dart:convert';

import 'package:product_app/models/auths/auth_error_model.dart';
import 'package:product_app/models/auths/auth_model.dart';
import 'package:product_app/services/auth/api_values_services.dart';
import 'package:http/http.dart' as http;

class AuthServiceResponse {
  int id = 0;
  String username = '';
  String email = '';
  String firstName = '';
  String lastName = '';
  String gender = '';
  String image = '';
  String token = '';
  int statusCode = 0;
  String error = '';
}

class AuthServiceError {
  String message = '';
}


class AuthService {
  static Future<AuthServiceResponse> login() async {
    AuthServiceResponse authServiceResponse = AuthServiceResponse();
    Uri url = Uri.https(ApiServiceValues.authBaseUrl, ApiServiceValues.authBaseUrlPath);

    await http.post(
      url,
      headers: {
        'Connection': 'keep-alive',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': ApiServiceValues.username,
        'password': ApiServiceValues.password,
      }),
    ).then((response) async {
       authServiceResponse.statusCode = response.statusCode;

       if (response.statusCode == 200) {
        final authModel = AuthModel.fromRawJson(response.body);
        authServiceResponse.token = authModel.token;
       }

       if (response.statusCode == 404) {
        authServiceResponse.error = 'Failed to authorize:\n 404 not found';
       } else if (response.statusCode == 400) {
        authServiceResponse.error = AuthErrorModel.fromRawJson(response.body).message;

       } else {
        authServiceResponse.error = 'Failed to authorized:\nUnknown Error';
       }
       return authServiceResponse;
    });


    return authServiceResponse;
  }
}
