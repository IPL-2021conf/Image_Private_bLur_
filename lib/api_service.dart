import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_private_blur/user_model.dart';

class APIService {
  Future<LoginResponseModel> login(LoginRequesetModel requesetModel) async {
    String uri = "https://reqres.in/api/login";

    final response =
        await http.post(Uri.parse(uri), body: requesetModel.toJson());

    if (response.statusCode == 200 || response.statusCode == 400) {
      return LoginResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception("Failed to load Data");
    }
  }
}
