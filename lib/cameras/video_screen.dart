import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_private_blur/screens/login.dart';
import 'package:http/http.dart' as http;
import 'package:android_path_provider/android_path_provider.dart';
import 'package:image_downloader/image_downloader.dart';

class Video {
  var urlImage;

  Video({required this.urlImage});

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(urlImage: json['urlImage']);
  }
}

class ViewVideo extends StatefulWidget {
  const ViewVideo({Key? key, required this.path}) : super(key: key);
  final String path;

  @override
  _ViewVideoState createState() => _ViewVideoState();
}

class _ViewVideoState extends State<ViewVideo> {
  late VideoPlayerController _controller;

  File? editImage;
  String? origin;
  List<bool> isPressed = [];
  List<Color> basicColor = [];
  List<String> images = [];
  int counts = 0;
  var list;
  var activePath;

  late String _localPath;

  @override
  void initState() {
    super.initState();
    activePath = widget.path;
    _controller = VideoPlayerController.file(File(widget.path))
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Container(
            child: Stack(
              children: [
                //촬영한 동영상
                Container(
                  child: _controller.value.isInitialized
                      ? AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        )
                      : Container(),
                ),
                //화면 중앙 동영상 재생 버튼
                Positioned(
                  left: screenSize.width / 2 - 35,
                  top: screenSize.height / 2 - 30,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _controller.value.isPlaying
                            ? _controller.pause()
                            : _controller.play();
                      });
                    },
                    child: CircleAvatar(
                      radius: 33,
                      backgroundColor: Colors.transparent,
                      child: Icon(
                        _controller.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.transparent,
                        size: 50,
                      ),
                    ),
                  ),
                ),
                //하단 이미지 선택 버튼
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Row(
                    children: [
                      SizedBox(
                        height: 100,
                      ),
                      Container(
                        width: screenSize.width,
                        height: 100,
                        color: Color(0x33162859),
                        child: ListView.builder(
                            padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                            scrollDirection: Axis.horizontal,
                            itemCount: images.length,
                            itemBuilder: (context, index) {
                              return makeButton(index);
                            }),
                      ),
                    ],
                  ),
                ),
                //뒤로가기 버튼
                Align(
                  alignment: Alignment.topLeft,
                  child: FloatingActionButton(
                    heroTag: 'back',
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    elevation: 0,
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                    backgroundColor: Colors.transparent,
                  ),
                ),
                //수정,저장,업로드 버튼
                Align(
                  alignment: Alignment.topRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FloatingActionButton(
                        heroTag: 'modify',
                        onPressed: () {
                          print('hello');
                          getImageFromServer(activePath);
                          setState(() {});
                        },
                        elevation: 0,
                        child: Icon(
                          Icons.auto_fix_normal_outlined,
                          color: Colors.white,
                        ),
                        backgroundColor: Colors.transparent,
                      ),
                      FloatingActionButton(
                        heroTag: 'download',
                        onPressed: () async {
                          setState(() {});
                          // _localPath = (await _findLocalPath())!;

                          // final taskId = await FlutterDownloader.enqueue(
                          //     url: '${origin}',
                          //     savedDir: _localPath,
                          //     showNotification: true,
                          //     openFileFromNotification: true,
                          //     saveInPublicStorage: true);
                        },
                        elevation: 0,
                        child: Icon(
                          Icons.refresh,
                          color: Colors.white,
                        ),
                        backgroundColor: Colors.transparent,
                      ),
                      FloatingActionButton(
                        heroTag: 'upload',
                        onPressed: () {
                          uploading(activePath);
                        },
                        elevation: 0,
                        child: Icon(
                          Icons.add_to_photos_outlined,
                          color: Colors.white,
                        ),
                        backgroundColor: Colors.transparent,
                      ),
                    ],
                  ),
                ),
                Positioned(
                    bottom: 100,
                    right: 0,
                    child: ElevatedButton(
                        onPressed: () {
                          sendPerson();
                        },
                        child: Text('send'))),
                Positioned(
                    bottom: 100,
                    right: 70,
                    child: ElevatedButton(
                        onPressed: () {
                          for (int i = 0; i < isPressed.length; i++) {
                            isPressed[i] = true;
                            basicColor[i] = Color(0x93272959);
                          }
                          setState(() {});
                        },
                        child: Text('select all')))
              ],
            ),
          ),
        ],
      ),
    );
  }

  void uploading(String path) async {
    var request =
        makePost('${mytoken}', 'https://ipl-main.herokuapp.com/data/images/');
    request.fields.addAll({
      'useremail': 'admin@admin.com',
      'username': 'admin',
      'desc': 'test upload2'
    });
    request.files.add(await http.MultipartFile.fromPath('image', activePath));
    print('============================');
    print(path);

    http.StreamedResponse response = await request.send();
    print(response.statusCode);

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  void getImageFromServer(String path) async {
    var request = makePost(
        'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNjM2NTU2Njg5LCJpYXQiOjE2MzYyOTc0ODksImp0aSI6IjBhMzk4OWI3ODZjOTQ3MDZiMDFiOGY4ZTljMjE4YmZjIiwidXNlcl9pZCI6MSwiZW1haWwiOiJhZG1pbkBhZG1pbi5jb20ifQ.6G5Hh-pe1Spinhj27T6XsT-tsZDvZ47iD4HXUYVqIQQ',
        'http://ec2-15-164-234-49.ap-northeast-2.compute.amazonaws.com:8000/processing/video/');

    request.files.add(await http.MultipartFile.fromPath('video', path));
    // http.StreamedResponse response = await request.send();
    http.StreamedResponse response = await request.send();
    var a = await response.stream.bytesToString();
    print(a);

    var dec = jsonDecode(a);
    for (var img in dec['vdo_links']) {
      images.add(img);
    }
    origin = images[0];
    images.removeAt(0);
    for (int i = 0; i < images.length; i++) {
      isPressed.add(false);
      basicColor.add(Colors.transparent);
    }

    await _prepareSaveDir();
  }

  void sendPerson() async {
    List<int> number = [];
    for (int i = 0; i < isPressed.length; i++) {
      if (isPressed[i] == true) number.add(i);
    }
    print(number);
    var request = makePost(
        'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNjM2NTU2Njg5LCJpYXQiOjE2MzYyOTc0ODksImp0aSI6IjBhMzk4OWI3ODZjOTQ3MDZiMDFiOGY4ZTljMjE4YmZjIiwidXNlcl9pZCI6MSwiZW1haWwiOiJhZG1pbkBhZG1pbi5jb20ifQ.6G5Hh-pe1Spinhj27T6XsT-tsZDvZ47iD4HXUYVqIQQ',
        'http://ec2-15-164-234-49.ap-northeast-2.compute.amazonaws.com:8000/processing/video/mosaic/');
    request.fields.addAll({
      'vdo_url': '$origin',
      'human_list': '$number',
    });
    http.StreamedResponse response = await request.send();

    var mosaic = await response.stream.bytesToString();

    print(mosaic);

    try {
      var imageId = await ImageDownloader.downloadImage('${origin}');
      if (imageId == null) return;
      activePath = await ImageDownloader.findPath(imageId);
    } catch (e) {
      print(e);
    }

    Directory d = await getApplicationDocumentsDirectory();

    await _prepareSaveDir();
  }

  Widget makeButton(int index) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
      child: CircleAvatar(
          radius: 40,
          backgroundImage: NetworkImage('${images[index]}'),
          child: MaterialButton(
            child: Text(
              '',
              style: TextStyle(fontSize: 80),
            ),
            onPressed: () {
              setState(() {
                isPressed[index] = !isPressed[index];
                basicColor[index] == Colors.transparent
                    ? basicColor[index] = Color(0x93272959)
                    : basicColor[index] = Colors.transparent;
              });
              print(isPressed);
            },
            color: basicColor[index],
            shape: CircleBorder(),
          )),
    );
  }

  Future<void> _prepareSaveDir() async {
    _localPath = (await _findLocalPath())!;
    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
  }

  Future<String?> _findLocalPath() async {
    var externalStorageDirPath;
    if (Platform.isAndroid) {
      try {
        externalStorageDirPath = await AndroidPathProvider.downloadsPath;
      } catch (e) {
        final directory = await getExternalStorageDirectory();
        externalStorageDirPath = directory?.path;
      }
    } else if (Platform.isIOS) {
      externalStorageDirPath =
          (await getApplicationDocumentsDirectory()).absolute.path;
    }
    return externalStorageDirPath;
  }

  http.MultipartRequest makePost(var token, String address) {
    var headers = {
      'Content-Type': 'multipart/form-data',
      'Authorization': 'Bearer $token'
    };
    var request = http.MultipartRequest('POST', Uri.parse('$address'));
    request.headers.addAll(headers);

    return request;
  }
}
