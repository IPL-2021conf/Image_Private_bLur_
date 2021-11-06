import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'image_screen.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';

Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: TakePictureScreen(
        camera: firstCamera,
      ),
    ),
  );
}

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    Key? key,
    required this.camera,
  }) : super(key: key);

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  double left1 = 78;
  double left2 = 78;
  double right1 = 156;
  bool onRec = false;
  var recording = Icons.circle_outlined;
  final itemKey = GlobalKey();
  int now = 0;

  @override
  void initState() {
    super.initState();
    // 현재 촬영중인 카메라를 보여주기 위해 카메라컨트롤러 생성
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
    );

    // 컨트롤러 초기화
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future scrollToItem() async {
    final scrollContext = itemKey.currentContext!;
    await Scrollable.ensureVisible(scrollContext,
        alignment: 0.5, duration: Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  //카메라 화면 보여주기
                  return CameraPreview(_controller);
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
            Positioned(
                bottom: 26,
                child: Container(
                  height: 80,
                  child: SingleChildScrollView(
                    child: Row(
                      children: [
                        RawMaterialButton(
                          key: itemKey,
                          elevation: 0,
                          onPressed: () => scrollToItem(),
                          child: Icon(
                            Icons.circle,
                            size: 70,
                            color: Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
            Positioned(
              bottom: 30,
              child: RawMaterialButton(
                onPressed: () async {
                  if (now == 0) {
                    try {
                      // 카메라 초기화
                      await _initializeControllerFuture;

                      // 사진을 촬영하여 image에 저장
                      final image = await _controller.takePicture();

                      // 사진을 찍으면 image_screen 페이지 실행
                      // 메모리에 올라간 현재 촬영한 사진의 경로를 보냄
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ViewImage(
                            path: image.path,
                          ),
                        ),
                      );
                    } catch (e) {
                      print(e);
                    }
                  }
                },
                elevation: 2.0,
                fillColor: Colors.transparent,
                child: Icon(
                  recording,
                  size: 80,
                  color: Colors.white,
                ),
                shape: CircleBorder(),
              ),
            ),
          ],
        ),
      ]),
      floatingActionButton: FabCircularMenu(
        ringColor: Color(0xfffcaa06),
        ringDiameter: 200,
        ringWidth: 45,
        fabSize: 50,
        fabColor: Color(0xfffcaa06),
        children: [
          IconButton(
            onPressed: () {
              print("카메라");
              now = 0;
            },
            icon: Icon(
              Icons.camera_alt,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () {
              print("비디오");
              now = 1;
            },
            icon: Icon(
              Icons.video_camera_back,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () {
              print("앨범");
              now = 2;
            },
            icon: Icon(
              Icons.photo_album,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
