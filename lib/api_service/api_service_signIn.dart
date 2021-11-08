import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_private_blur/user_model.dart';

class APIServiceSignIn {
  Future<LoginResponseModel> login(LoginRequestModel requesetModel) async {
    String uri =
        "http://ec2-15-164-234-49.ap-northeast-2.compute.amazonaws.com:8000/account/login/";

    final response = await http.post(
      Uri.parse(uri),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: requesetModel.toJson(),
    );

    if (response.statusCode == 200 || response.statusCode == 400) {
      //print(response.headers);
      print(response.headers);

      return LoginResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception("Failed to load Data");
    }
  }
}
