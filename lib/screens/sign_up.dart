import 'package:flutter/material.dart';
import '../api_service.dart';
import '../user_model.dart';

class sign_up extends StatefulWidget {
  @override
  _sign_up createState() => _sign_up();
}

class _sign_up extends State<sign_up> {
  GlobalKey<FormState> globalFormKey = new GlobalKey<FormState>();
  bool hidePassWord = true;
  String userName = '', email = '', password = '';
  bool isApiCallProcess = false;
  late SignUpRequesetModel requesetModel;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(children: [
          SizedBox(
            height: 15,
          ),
          Container(
            child: Row(children: [
              IconButton(
                iconSize: 50,
                icon: Icon(Icons.navigate_before),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ]),
          ),
          Center(
            child: Image(
              image: AssetImage('images/logo1.png'),
            ),
          ),
          SizedBox(
            height: 40,
          ),
          Container(
            width: 350,
            child: Row(
              children: [
                SizedBox(
                  width: 25,
                ),
                Text("회원가입",
                    style: const TextStyle(
                        color: const Color(0xff02171a), fontSize: 20),
                    textAlign: TextAlign.left),
              ],
            ),
          ),
          Form(
            key: globalFormKey,
            child: Theme(
              data: ThemeData(
                primaryColor: Color(0xff819395),
                inputDecorationTheme: InputDecorationTheme(
                  labelStyle: TextStyle(color: Colors.grey, fontSize: 15),
                ),
              ),
              child: Container(
                padding: EdgeInsets.only(left: 45, right: 45),
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      cursorColor: Colors.grey,
                      keyboardType: TextInputType.text,
                      onSaved: (input) => requesetModel.user = input!,
                      validator: (input) =>
                          input!.length < 2 ? "2자 이상 적어주세요" : null,
                      decoration: new InputDecoration(
                        hintText: " 이름",
                        hintStyle: TextStyle(color: Colors.blueGrey),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      cursorColor: Colors.grey,
                      keyboardType: TextInputType.text,
                      onSaved: (input) => requesetModel.email = input!,
                      validator: (input) =>
                          !input!.contains("@") ? "이메일 형식으로 적어주세요" : null,
                      decoration: new InputDecoration(
                        hintText: " 이메일",
                        hintStyle: TextStyle(color: Colors.blueGrey),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      cursorColor: Colors.grey,
                      keyboardType: TextInputType.text,
                      onSaved: (input) => requesetModel.password = input!,
                      validator: (input) =>
                          input!.length < 2 ? "3자 이상 적어주세요" : null,
                      obscureText: hidePassWord,
                      decoration: new InputDecoration(
                        hintText: " 비밀번호",
                        hintStyle: TextStyle(color: Colors.blueGrey),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black,
                          ),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            if (validateAndSave()) {
                              setState(() {
                                isApiCallProcess = true;
                              });

                              APIService apiService = new APIService();
                              apiService.signUp(requesetModel).then((value) {
                                setState(() {
                                  isApiCallProcess = false;
                                });
                              });
                              print(requesetModel.toJson());
                            }
                          },
                          color: Color(0xff819395),
                          icon: Icon(hidePassWord
                              ? Icons.visibility_off
                              : Icons.visibility),
                        ),
                      ),
                    ),
                    SizedBox(height: 50),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xff9fc4ac),
                          minimumSize: Size(250, 55),
                        ),
                        child: const Text(
                          '회원가입',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        onPressed: () {
                          if (validateAndSave()) {}
                        }),
                  ],
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  bool validateAndSave() {
    final form = globalFormKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }
}
