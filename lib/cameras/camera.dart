import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_private_blur/cameras/video_screen.dart';
import 'image_screen.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    Key? key,
    required this.camera,
  }) : super(key: key);

  final List<CameraDescription> camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool onRec = false;
  var recording = Icons.circle_outlined;
  final itemKey = GlobalKey();
  int now = 0;
  var buttonColor = Colors.white;
  bool isCameraFront = true;
  double transform = 0;
  Future<void>? cameraValue;
  List<CameraDescription> cameras = [];

  @override
  void initState() {
    super.initState();
    // 현재 촬영중인 카메라를 보여주기 위해 카메라컨트롤러 생성
    _controller = CameraController(
      widget.camera[0],
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
                      // 사진을 촬영하여 image에 저장
                      final image = await _controller.takePicture();

                      Uint8List imageBytes = await image.readAsBytes();
                      Uint8List result =
                          await FlutterImageCompress.compressWithList(
                              imageBytes,
                              quality: 100,
                              rotate: 0);

                      File fixedImage = File(image.path);
                      fixedImage.writeAsBytes(result);

                      // 사진을 찍으면 image_screen 페이지 실행
                      // 메모리에 올라간 현재 촬영한 사진의 경로를 보냄
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ViewImage(
                            path: fixedImage.path,
                          ),
                        ),
                      );
                    } catch (e) {
                      print(e);
                    }
                  } else if (now == 1) {
                    if (!onRec) {
                      await _controller.startVideoRecording();
                      setState(() {
                        recording = Icons.stop_circle_outlined;
                        onRec = true;
                      });
                    } else {
                      XFile videopath = await _controller.stopVideoRecording();
                      print(videopath.path);
                      setState(() {
                        recording = Icons.circle_outlined;
                        onRec = false;
                      });
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (builder) => ViewVideo(
                                    path: videopath.path,
                                  )));
                    }
                    setState(() {});
                  }
                },
                elevation: 2.0,
                fillColor: Colors.transparent,
                child: Icon(
                  recording,
                  size: 80,
                  color: buttonColor,
                ),
                shape: CircleBorder(),
              ),
            ),
            Positioned(
                right: 0,
                top: 0,
                child: IconButton(
                    onPressed: () async {
                      setState(() {
                        isCameraFront = !isCameraFront;
                      });
                      int cameraPos = isCameraFront ? 0 : 1;
                      _controller = CameraController(
                          widget.camera[cameraPos], ResolutionPreset.high);
                      _initializeControllerFuture = _controller.initialize();
                    },
                    icon: Icon(
                      Icons.flip_camera_android_rounded,
                      color: Colors.white,
                      size: 40,
                    )))
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
              if (onRec == true) {
                return;
              }
              print("카메라");
              now = 0;
              buttonColor = Colors.white;
              recording = Icons.circle_outlined;
              setState(() {});
            },
            icon: Icon(
              Icons.camera_alt,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () {
              if (onRec == true) {
                return;
              }
              print("비디오");
              now = 1;
              buttonColor = Colors.red;
              recording = Icons.circle_outlined;
              setState(() {});
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
