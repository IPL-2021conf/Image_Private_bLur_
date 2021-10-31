import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_private_blur/user_model.dart';

class APIServiceSignUp {
  Future<SignUpRequestModel> signUp(SignUpRequestModel requesetModel) async {
    String uri = "https://ipl-main.herokuapp.com/account/signup/";

    final response =
        await http.post(Uri.parse(uri), body: requesetModel.toJson());

    if (response.statusCode == 201) {
      print(response.statusCode);

      return SignUpRequestModel.fromJson(json.decode(response.body));
    } else {
      return SignUpRequestModel.fromJson(json.decode(response.body));
    }
  }
}
