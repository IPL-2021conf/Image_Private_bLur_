import 'package:flutter/material.dart';
import 'screens/sign_up.dart';
import 'screens/login.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IPL',
      home: Splash(),
    );
  }
}

class Splash extends StatefulWidget {
  @override
  _Splash createState() => _Splash();
}

class _Splash extends State<Splash> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(
      children: [
        SizedBox(height: 100),
        Container(
          width: 180,
          height: 150,
          child: Image.asset("images/logo1.png", fit: BoxFit.fill),
        ),
        Text("Image Private bLur",
            style: TextStyle(
              fontSize: 20,
            )),
        SizedBox(height: 160),

        //로그인 버튼
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Color(0xffec9f9f),
            minimumSize: Size(250, 55),
          ),
          child: const Text('로그인',
              style: TextStyle(
                fontSize: 20,
              )),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => login()));
          },
        ),
        SizedBox(height: 20),

        //회원가입 버튼
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Color(0xff9fc4ac),
            minimumSize: Size(250, 55),
          ),
          child: const Text('회원가입',
              style: TextStyle(
                fontSize: 20,
              )),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => sign_up()),
            );
          },
        ),
      ],
    )));
  }
}
