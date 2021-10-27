import 'package:flutter/material.dart';
import './home.dart';

class login extends StatefulWidget {

  @override
  _login createState() => _login();
}
class _login extends State<login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 15,),
            Container(
              child: Row(children:[IconButton(
                iconSize: 50,
                icon: Icon(Icons.navigate_before),
            onPressed: () {Navigator.pop(context);})]),),
            Center(
              child: Image(image: AssetImage('images/logo1.png'),),
            ),
            SizedBox(height: 10,),
            Container(
              width: 350,
              child: Row(
                children: [
                  SizedBox(width: 10,),
                  Text("로그인", style: const TextStyle(
                    color: const Color(0xff02171a),
                    fontSize: 20),
                    textAlign: TextAlign.left),
                ],),
            ),
            Form(
              child: Theme(
                data: ThemeData(
                  primaryColor: Color(0xff819395),
                  inputDecorationTheme: InputDecorationTheme(
                    labelStyle:TextStyle(color: Colors.grey, fontSize: 15))),
                    child: Container(
                      padding: EdgeInsets.all(45.0),
                      child: Column(
                        children: <Widget>[
                          TextField(
                            decoration: InputDecoration(labelText: '아이디'),
                            keyboardType: TextInputType.text,
                          ),
                          SizedBox(height: 10),
                          TextField(
                            decoration: InputDecoration(labelText: '비밀번호'),
                            keyboardType: TextInputType.text,
                            obscureText: true,
                          ),
                          SizedBox(height: 80),
                          ElevatedButton(
                            style:ElevatedButton.styleFrom(
                              primary: Color(0xffec9f9f), 
                              minimumSize: Size(250, 55),  ),
                              child: const Text('로그인',style: TextStyle(fontSize: 20,)),
                              onPressed: () {
                                Navigator.push(context,MaterialPageRoute(builder: (context) => home()));
                              },
                              ),
                        ],
                      ),
                    )))
          ],
        ),
      ),
    );
  }
}