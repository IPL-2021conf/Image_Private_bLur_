import 'package:http/http.dart' as http;
import 'package:image_private_blur/screens/sign_up.dart';
import 'dart:convert';
import 'package:image_private_blur/user_model.dart';

class APIService {
  Future<LoginResponseModel> login(LoginRequesetModel requesetModel) async {
    String uri = "https://ipl-main.herokuapp.com/account/login/";

    final response =
        await http.post(Uri.parse(uri), body: requesetModel.toJson());

    if (response.statusCode == 200 || response.statusCode == 400) {
      return LoginResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception("Failed to load Data");
    }
  }

  Future<String> signUp(SignUpRequesetModel requesetModel) async {
    String uri = "https://ipl-main.herokuapp.com/account/signup";

    final response =
        await http.post(Uri.parse(uri), body: requesetModel.toJson());

    if (response.statusCode == 201) {
    } else {
      throw Exception("Failed to load Data");
    }
    return 'hello';
  }
}

class SignUpRequesetModel {
  String user = "";
  String email = "";
  String password = "";

  SignUpRequesetModel({
    this.user = "",
    this.email = "",
    this.password = "",
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'user': user.trim(),
      'email': email.trim(),
      'password': password.trim(),
    };

    return map;
  }
}
