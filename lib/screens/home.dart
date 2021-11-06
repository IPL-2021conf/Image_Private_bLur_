import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

//Map을 객체로 변환
class Post {
  String useremail;
  String username;
  String date;
  String desc;
  String link;

  Post(
      {required this.useremail,
      required this.username,
      required this.date,
      required this.desc,
      required this.link});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      useremail: json['useremail'],
      username: json['username'],
      date: json['date'],
      desc: json['desc'],
      link: json['link'],
    );
  }
}

class home extends StatefulWidget {
  home({Key? key}) : super(key: key);
  @override
  _home createState() => _home();
}

class _home extends State<home> {
  Future<Post?> fetchPost() async {
    var headers = {
      'Authorization':
          'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNjM2Mzc3ODQ3LCJpYXQiOjE2MzU2OTM3NjUsImp0aSI6IjUzMGE3Y2NlZTVjZDRiOWM5Y2UyMTU0NGE2MGY3YzYxIiwidXNlcl9pZCI6MSwiZW1haWwiOiJhZG1pbkBhZG1pbi5jb20ifQ.yKAQMHB9nDbVClTJPAzfGZa3Emjf3PMy98mbLjhK_Vw',
      'Content-Type': 'application/json'
    };
    var request = http.MultipartRequest(
        'GET', Uri.parse('https://ipl-main.herokuapp.com/data/images/'));

    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print("성공");
      var jsonstr = await response.stream.bytesToString();
      print(jsonstr);
      var str1 = jsonstr.split("},");
      print(str1.elementAt(0));

      List<dynamic> list = jsonDecode(jsonstr);
      print(list[0]['link']);
      print(list[1]['username']);

      List userlist = [];
      // for(int i = 0; i<str1.length; i++){
      var jsonmap = jsonDecode(jsonstr)[0];
      Post post = Post.fromJson(Map<String, dynamic>.from(jsonmap));
      print(jsonmap);

      return post;

      //return
    } else {
      print("실패");
      print(response.reasonPhrase);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPost();
  }

  File? image;
  Future getImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) {
        return;
      } else {
        final imagePermanent = await saveImagePermanently(image.path);

        setState(() => this.image = imagePermanent);
      }
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future<File> saveImagePermanently(String imagePath) async {
    final directory = await getApplicationDocumentsDirectory();
    print("디렉토리" + directory.toString());
    final name = basename(imagePath);
    print("이름" + name.toString());
    final image = File('${directory.path}/$name');
    print("위치" + image.path);
    return File(imagePath).copy(image.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 1.0,
          toolbarHeight: 70,
          actions: <Widget>[
            Image.asset('images/logo1.png'),
            SizedBox(
              width: 90,
            ),
            IconButton(
                icon: Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.black,
                  size: 40,
                ),
                onPressed: () {}),
            SizedBox(
              width: 10,
            ),
          ]),

      body: SingleChildScrollView(
        child: FutureBuilder<Post?>(
          future: fetchPost(),
          builder: (context, snapshot) {
            print(snapshot.hasData);
            if (snapshot.hasData) {
              return new Padding(
                  padding:
                      new EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                  child: new Card(
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(16.0),
                      ),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          new Padding(
                            padding: new EdgeInsets.fromLTRB(16.0, 16.0, 0, 0),
                            child: new Text(
                              snapshot.data!.username,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 25.0),
                            ),
                          ),
                          new Padding(
                            padding: new EdgeInsets.fromLTRB(16.0, 0, 0, 0),
                            child: new Text(
                              snapshot.data!.date,
                              textAlign: TextAlign.left,
                              style:
                                  TextStyle(fontSize: 20.0, color: Colors.grey),
                            ),
                          ),
                          new ClipRRect(
                            child: new Image.network(snapshot.data!.link),
                            borderRadius: BorderRadius.only(
                              topLeft: new Radius.circular(16.0),
                              topRight: new Radius.circular(
                                16.0,
                              ),
                              bottomLeft: new Radius.circular(16.0),
                              bottomRight: new Radius.circular(16.0),
                            ),
                          ),
                        ],
                      )));
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }

            // 기본적으로 로딩 Spinner를 보여줍니다.
            return CircularProgressIndicator();
          },
        ),
      ),
      //업로드 버튼
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xfffcaa06),
        onPressed: () {
          getImage();
        },
        child: const Icon(Icons.download_rounded),
      ),
    );
  }
}
