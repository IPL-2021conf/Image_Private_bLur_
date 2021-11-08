import 'package:http/http.dart' as http;
import 'package:image_private_blur/screens/login.dart';

class APIServiceAccess {
  Future<String> Token() async {
    String uri =
        "http://ec2-15-164-234-49.ap-northeast-2.compute.amazonaws.com:8000/account/login/refresh/";

    final response = await http.post(
      Uri.parse(uri),
      headers: {
        'Content-type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer $mytoken'
      },
    );

    if (response.statusCode == 201) {
      print(response.statusCode);
      return response.body;
    } else {
      print(response.statusCode);
      return "";
    }
  }

  Future<String> reToken(String token) async {
    token = Token() as String;
    return "";
  }
}
