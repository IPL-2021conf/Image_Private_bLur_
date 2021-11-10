import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:image_private_blur/screens/login.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:android_path_provider/android_path_provider.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';

const debug = true;

class Photo {
  var urlImage;

  Photo({required this.urlImage});

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(urlImage: json['urlImage']);
  }
}

class ViewImage extends StatefulWidget {
  const ViewImage({Key? key, required this.path}) : super(key: key);
  final String path;

  @override
  State<ViewImage> createState() => _ViewImage();
}

class _ViewImage extends State<ViewImage> {
  File? editImage;
  String? origin;
  List<bool> isPressed = [];
  List<Color> basicColor = [];
  List<String> images = [];
  int counts = 0;
  var list;
  var activePath;

  // late String _localPath;
  // ReceivePort _port = ReceivePort();
  @override
  void initState() {
    activePath = widget.path;

    super.initState();
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    // _unbindBackgroundIsolate();
    super.dispose();
  }

// ============================================
  // void _bindBackgroundIsolate() {
  //   bool isSuccess = IsolateNameServer.registerPortWithName(
  //       _port.sendPort, 'downloader_send_port');
  //   if (!isSuccess) {
  //     _unbindBackgroundIsolate();
  //     _bindBackgroundIsolate();
  //     return;
  //   }
  //   _port.listen((dynamic data) {
  //     if (debug) {
  //       print('UI Isolate Callback: $data');
  //     }
  //     String? id = data[0];
  //     DownloadTaskStatus? status = data[1];
  //     int? progress = data[2];
  //     setState(() {});
  //     // if (_tasks != null && _tasks!.isNotEmpty) {
  //     //   final task = _tasks!.firstWhere((task) => task.taskId == id);
  //     //   setState(() {
  //     //     task.status = status;
  //     //     task.progress = progress;
  //     //   });
  //     // }

  //   });
  // }

  // void _unbindBackgroundIsolate() {
  //   IsolateNameServer.removePortNameMapping('downloader_send_port');
  // }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    if (debug) {
      print(
          'Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');
    }
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, progress]);
  }
// ============================================

  void getImageFromServer(String path) async {
    Fluttertoast.showToast(
        msg: "인물 추출중입니다.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.black,
        fontSize: 16.0);
    var request = makePost(
        'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNjM2NTU2Njg5LCJpYXQiOjE2MzYyOTc0ODksImp0aSI6IjBhMzk4OWI3ODZjOTQ3MDZiMDFiOGY4ZTljMjE4YmZjIiwidXNlcl9pZCI6MSwiZW1haWwiOiJhZG1pbkBhZG1pbi5jb20ifQ.6G5Hh-pe1Spinhj27T6XsT-tsZDvZ47iD4HXUYVqIQQ',
        'http://ec2-15-164-234-49.ap-northeast-2.compute.amazonaws.com:8000/processing/image/');

    request.files.add(await http.MultipartFile.fromPath('image', path));
    // http.StreamedResponse response = await request.send();
    http.StreamedResponse response = await request.send();
    var a = await response.stream.bytesToString();
    print(a);

    var dec = jsonDecode(a);
    for (var img in dec['img_links']) {
      images.add(img);
    }
    origin = images[0];
    images.removeAt(0);
    for (int i = 0; i < images.length; i++) {
      isPressed.add(false);
      basicColor.add(Colors.transparent);
    }
    Fluttertoast.showToast(
        msg: "인물 추출이 완료되었습니다. 새로고침을 해주세요.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.black,
        fontSize: 16.0);

    // await _prepareSaveDir();
  }

  void sendPerson() async {
    Fluttertoast.showToast(
        msg: "선택된 인물 모자이크 처리중.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.black,
        fontSize: 16.0);
    List<int> number = [];
    for (int i = 0; i < isPressed.length; i++) {
      if (isPressed[i] == true) number.add(i);
    }
    print(number);
    var request = makePost('${mytoken}',
        'http://ec2-15-164-234-49.ap-northeast-2.compute.amazonaws.com:8000/processing/image/mosaic/');
    request.fields.addAll({
      'img_url': '$origin',
      'human_list': '$number',
    });
    http.StreamedResponse response = await request.send();

    var mosaic = await response.stream.bytesToString();

    print(mosaic);

    //이미지 저장
    try {
      var imageId = await ImageDownloader.downloadImage('${origin}');
      if (imageId == null) return;
      activePath = await ImageDownloader.findPath(imageId);
    } catch (e) {
      print(e);
    }

    Directory d = await getApplicationDocumentsDirectory();

    // await _prepareSaveDir();
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

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    editImage = File(widget.path);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Container(
            child: Stack(
              children: [
                Container(
                  width: screenSize.width,
                  height: screenSize.height,
                ),
                //촬영한 이미지
                Positioned(
                    child: Container(
                  child: Image.file(File('$activePath')),
                )),
                //하단 이미지 선택바
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
                      //수정
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
                      //저장
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
                      //업로드
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
    Fluttertoast.showToast(
        msg: "업로드 중입니다.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.black,
        fontSize: 16.0);
    var request = makePost('${mytoken}',
        'http://ec2-15-164-234-49.ap-northeast-2.compute.amazonaws.com:8000/data/images/');
    request.fields.addAll(
        {'useremail': 'admin@admin.com', 'username': myName, 'desc': 'image'});
    request.files.add(await http.MultipartFile.fromPath('image', activePath));
    print('============================');
    print(path);

    http.StreamedResponse response = await request.send();
    print(response.statusCode);

    if (response.statusCode == 201) {
      print(await response.stream.bytesToString());
      Fluttertoast.showToast(
          msg: "업로드가 완료되었습니다.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.black,
          fontSize: 16.0);
    } else {
      print(response.reasonPhrase);
    }
  }

  // Future<void> _prepareSaveDir() async {
  //   _localPath = (await _findLocalPath())!;
  //   final savedDir = Directory(_localPath);
  //   bool hasExisted = await savedDir.exists();
  //   if (!hasExisted) {
  //     savedDir.create();
  //   }
  // }

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
