import 'package:http/http.dart' as http;
import 'package:image_private_blur/screens/login.dart';
import 'dart:convert';
import 'package:image_private_blur/user_model.dart';

class APIServiceLogout {
  Future<SignUpRequestModel> LogOut(SignUpRequestModel requesetModel) async {
    String uri =
        "http://ec2-15-164-234-49.ap-northeast-2.compute.amazonaws.com:8000/account/logout/";

    final response = await http.post(
      Uri.parse(uri),
      body: {}, // refresh??
      headers: {
        "Content-type": "application/x-www-form-urlencoded",
        "Authorization": mytoken
      },
    );

    if (response.statusCode == 201) {
      print(response.statusCode);

      return SignUpRequestModel.fromJson(json.decode(response.body));
    } else {
      return SignUpRequestModel.fromJson(json.decode(response.body));
    }
  }
}
