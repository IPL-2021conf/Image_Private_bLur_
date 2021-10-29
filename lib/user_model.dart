class LoginResponseModel {
  final String token;
  final String error;

  LoginResponseModel({this.token = '', this.error = ''});

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      token: json["access"] != null ? json["access"] : "",
      error: json["error"] != null ? json["error"] : "",
    );
  }
}

class LoginRequesetModel {
  String email = "";
  String password = "";

  LoginRequesetModel({
    this.email = "",
    this.password = "",
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'email': email.trim(),
      'password': password.trim(),
    };

    return map;
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
