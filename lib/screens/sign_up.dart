import 'package:flutter/material.dart';

class sign_up extends StatefulWidget {

  @override
  _sign_up createState() => _sign_up();
}
class _sign_up extends State<sign_up> {
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
            SizedBox(height: 50,),
            Container(
              width: 350,
              child: Row(
                children: [
                  SizedBox(width: 10,),
                  Text("회원가입", style: const TextStyle(
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
                            decoration: InputDecoration(labelText: '이름'),
                            keyboardType: TextInputType.text,
                          ),
                          SizedBox(height:10),
                          TextField(
                            decoration: InputDecoration(labelText: '비밀번호'),
                            keyboardType: TextInputType.text,
                            obscureText: true,
                          ),
                          SizedBox(height:10),
                          TextField(
                            decoration: InputDecoration(labelText: '이메일'),
                            keyboardType: TextInputType.text,
                            obscureText: true,
                          ),
                          SizedBox(height: 50),
                          ElevatedButton(
                            style:ElevatedButton.styleFrom(
                              primary: Color(0xff9fc4ac), 
                              minimumSize: Size(250, 55),  ),
                              child: const Text('회원가입',style: TextStyle(fontSize: 20,)),
                              onPressed: () {},
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