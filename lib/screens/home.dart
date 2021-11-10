import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:core';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_downloader/image_downloader.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_private_blur/cameras/camera.dart';
import 'package:image_private_blur/cameras/image_screen.dart';
import 'package:image_private_blur/cameras/video_screen.dart';
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
  get jsonmap => null;
  List<Map<String, dynamic>> file_list = [];

  Future<List<Map<String, dynamic>>?> fetchPost() async {
    var headers = {
      'Authorization':
          'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNjM2NTU2Njg5LCJpYXQiOjE2MzYyOTc0ODksImp0aSI6IjBhMzk4OWI3ODZjOTQ3MDZiMDFiOGY4ZTljMjE4YmZjIiwidXNlcl9pZCI6MSwiZW1haWwiOiJhZG1pbkBhZG1pbi5jb20ifQ.6G5Hh-pe1Spinhj27T6XsT-tsZDvZ47iD4HXUYVqIQQ',
      'Content-Type': 'application/json'
    };
    var request = http.MultipartRequest(
        'GET',
        Uri.parse(
            'http://ec2-15-164-234-49.ap-northeast-2.compute.amazonaws.com:8000/data/images/'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print("이미지성공");
      var jsonstr = await response.stream.bytesToString();
      print(jsonstr);

      var jsonmap = jsonDecode(jsonstr);

      for (var data in jsonmap) {
        file_list.add(data);
      }
      print(file_list);
      //file_list.sort((a, b) => a['date'].compareTo(b['date']));
      //file_list.reversed;
      print(file_list);
      return file_list;
    } else {
      print("실패");
      print(response.reasonPhrase);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  Widget makePost(AsyncSnapshot snapshot, int index, BuildContext context) {
    //file_list.sort((a, b) => a['date'].compareTo(b['date']));
    //file_list.reversed;
    return Column(children: [
      new Padding(
        padding: new EdgeInsets.symmetric(vertical: .0, horizontal: 8.0),
        child: new Card(
          shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(16.0),
          ),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              new Padding(
                padding: new EdgeInsets.fromLTRB(10.0, 16.0, 0, 0),
                child: new Text(
                  snapshot.data[index]['username'],
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
                ),
              ),
              new Padding(
                padding: new EdgeInsets.fromLTRB(10.0, 0, 0, 0),
                child: new Text(
                  snapshot.data[index]['date'],
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 20.0, color: Colors.grey[600]),
                ),
              ),
              GestureDetector(
                child: new ClipRRect(
                  child: new Image.network(
                    snapshot.data[index]['link'],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: new Radius.circular(16.0),
                    topRight: new Radius.circular(16.0),
                    bottomLeft: new Radius.circular(16.0),
                    bottomRight: new Radius.circular(16.0),
                  ),
                ),
                onTap: () {
                  print(snapshot.data[index]['link']);

                  showAlertDialog(context, snapshot.data[index]['link']);
                },
              ),
            ],
          ),
        ),
      ),
      SizedBox(
        height: 20,
      ),
      new Container(
        height: 1.0,
        width: 380.0,
        color: Colors.grey,
      )
    ]);
  }

  File? image;
  File? video;

  Future getImage(int now) async {
    if (now == 0) {
      try {
        final image =
            await ImagePicker().pickImage(source: ImageSource.gallery);
        if (image == null) {
          return;
        } else {
          final imagePermanent = await saveImagePermanently(image.path);

          setState(() => this.image = imagePermanent);
        }
      } on PlatformException catch (e) {
        print('Failed to pick image: $e');
      }
    } else {
      try {
        final video =
            await ImagePicker().pickVideo(source: ImageSource.gallery);

        if (video == null) {
          return;
        } else {
          final videoPermanent = await saveImagePermanently(video.path);

          setState(() => this.video = videoPermanent);
        }
      } on PlatformException catch (e) {
        print('Failed to pick image: $e');
      }
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
    int now = 0;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Image.asset('images/logo1.png'),
          toolbarHeight: 70,
          actions: <Widget>[
            IconButton(
                icon: Icon(
                  Icons.camera_alt,
                  color: Colors.blueGrey,
                  size: 40,
                ),
                onPressed: () async {
                  // Obtain a list of the available cameras on the device.
                  final cameras = await availableCameras();

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              TakePictureScreen(camera: cameras)));
                }),
            SizedBox(
              width: 10,
            )
          ]),

      body: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<List<Map<String, dynamic>>?>(
            future: fetchPost(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: file_list.length,
                    itemBuilder: (context, index) {
                      return makePost(snapshot, index, context);
                    });
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }

              // 기본적으로 로딩 Spinner를 보여줍니다.
              return CircularProgressIndicator();
            },
          )),
      //업로드 버튼
      //업로드 버튼
      floatingActionButton:
          Column(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
        new FloatingActionButton(
            child: Icon(Icons.image_outlined),
            heroTag: 'image',
            onPressed: () async {
              print("이미지갤러리");
              now = 0;
              await getImage(now);
              print(image!.path);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewImage(
                    path: image!.path,
                  ),
                ),
              );
            }),
        SizedBox(
          height: 5,
        ),
        new FloatingActionButton(
          child: Icon(Icons.video_library),
          heroTag: 'video',
          onPressed: () async {
            print("비디오갤러리");
            now = 1;
            await getImage(now);
            print(video!.path);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ViewVideo(
                  path: video!.path,
                ),
              ),
            );
          },
        ),
        SizedBox(
          height: 5,
        ),
        //업로드 버튼
      ]),
    );
  }

  Future<void> _refresh() async {
    await Future.delayed(Duration(seconds: 2));
    file_list.clear();
    setState(() {});
  }

  void showAlertDialog(BuildContext context, dynamic url) async {
    var result = await showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('SAVE'),
          content: Text("저장하시겠습니까?"),
          actions: <Widget>[
            TextButton(
              child: Text('저장'),
              onPressed: () async {
                try {
                  // Saved with this method.
                  var imageId = await ImageDownloader.downloadImage(url);
                  if (imageId == null) {
                    return;
                  }
                } on PlatformException catch (error) {
                  print(error);
                }
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('뒤로가기'),
              onPressed: () {
                Navigator.pop(context, "Cancel");
              },
            ),
          ],
        );
      },
    );
  }
}
