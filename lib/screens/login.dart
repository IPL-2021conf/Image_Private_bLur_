import 'package:flutter/material.dart';

import '../ProgressHUD.dart';
import '../api_service.dart';
import '../user_model.dart';
import 'home.dart';

class login extends StatefulWidget {
  @override
  _login createState() => _login();
}

class _login extends State<login> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> globalFormKey = new GlobalKey<FormState>();
  bool hidePassWord = true;
  late LoginRequesetModel requesetModel;
  bool isApiCallProcess = false;

  @override
  void initState() {
    super.initState();
    requesetModel = new LoginRequesetModel();
  }

  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
      child: _uiLogin(context),
      inAsyncCall: isApiCallProcess,
      opacity: 0.3,
      key: null,
    );
  }

  Widget _uiLogin(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
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
                )
              ]),
            ),
            Center(
              child: Image(
                image: AssetImage('images/logo1.png'),
              ),
            ),
            SizedBox(
              height: 60,
            ),
            Container(
              width: 350,
              child: Row(
                children: [
                  Text(
                    "LOGIN",
                    style: const TextStyle(
                        color: const Color(0xff02171a), fontSize: 20),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              margin: EdgeInsets.only(left: 20, right: 20),
              child: Form(
                key: globalFormKey,
                child: Column(children: <Widget>[
                  new TextFormField(
                    cursorColor: Colors.grey,
                    keyboardType: TextInputType.emailAddress,
                    onSaved: (input) => requesetModel.email = input!,
                    validator: (input) =>
                        !input!.contains("@") ? "이메일 형식으로 적어주세요" : null,
                    decoration: new InputDecoration(
                        hintText: "Email",
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
                        prefixIcon: Icon(
                          Icons.email,
                          color: Color(0xFFE06A6A),
                        )),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  new TextFormField(
                    cursorColor: Colors.grey,
                    keyboardType: TextInputType.text,
                    onSaved: (input) => requesetModel.password = input!,
                    validator: (input) =>
                        input!.length < 3 ? "3자 이상 적어주세요" : null,
                    obscureText: hidePassWord,
                    decoration: new InputDecoration(
                      hintText: "PassWord",
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
                      prefixIcon: Icon(
                        Icons.lock,
                        color: Color(0xFFE06A6A),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            hidePassWord = !hidePassWord;
                          });
                        },
                        color: Color(0xFFE06A6A),
                        icon: Icon(hidePassWord
                            ? Icons.visibility_off
                            : Icons.visibility),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 60,
                  ),
                  Container(
                    child: Column(children: <Widget>[
                      TextButton(
                        child: const Text('로그인',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            )),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 80,
                          ),
                          backgroundColor: Color(0xffec9f9f),
                          minimumSize: Size(250, 55),
                        ),
                        onPressed: () {
                          if (validateAndSave()) {
                            setState(() {
                              isApiCallProcess = true;
                            });

                            APIService apiService = new APIService();
                            apiService.login(requesetModel).then((value) {
                              setState(() {
                                isApiCallProcess = false;
                              });

                              if (value.token.isNotEmpty) {
                                print(value.token);
                                final snackBar = SnackBar(
                                  content: Text("로그인성공!!!!"),
                                );
                                scaffoldKey.currentState!
                                    .showSnackBar(snackBar);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => home()));
                              } else {
                                print(value.error);
                                final snackBar = SnackBar(
                                  content: Text("로그인 실패"),
                                );
                                scaffoldKey.currentState!
                                    .showSnackBar(snackBar);
                              }
                            });
                            print(requesetModel.toJson());
                          }
                        },
                      ),
                    ]),
                  ),
                ]),
              ),
            )
          ]),
        ));
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
