import 'package:flutter/material.dart';

class home extends StatefulWidget {

  @override
  _home createState() => _home();
}
class _home extends State<home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 15,),
            
            Center(
              child: Image(image: AssetImage('images/logo1.png'),),
            ),
            
          ],
        ),
      ),
    );
  }
}