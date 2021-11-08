class LoginResponseModel {
  final String access;
  final String username;

  LoginResponseModel({this.access = '', this.username = ''});

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      access: json["access"] != null ? json["access"] : "",
      username: json["username"] != null ? json["username"] : "",
    );
  }
}

class LoginRequestModel {
  String email = '';
  String password = '';

  LoginRequestModel({
    this.email = '',
    this.password = '',
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'email': email.trim(),
      'password': password.trim(),
    };
    return map;
  }
}

class SignUpRequestModel {
  String email = "";
  String password = "";
  String username = "";

  SignUpRequestModel({
    this.email = "",
    this.password = "",
    this.username = "",
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'email': email.trim(),
      'password': password.trim(),
      'username': username.trim(),
    };

    return map;
  }

  factory SignUpRequestModel.fromJson(Map<String, dynamic> json) {
    SignUpRequestModel s = SignUpRequestModel(
      email: json["email"] != null ? json["email"] : "",
      password: json["password"] != null ? json["password"] : "",
      username: json["username"] != null ? json["username"] : "",
    );

    print(s.email);
    print(s.password);
    print(s.username);
    return s;
  }
}
