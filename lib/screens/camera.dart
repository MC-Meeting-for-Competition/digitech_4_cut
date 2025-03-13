import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:digitech_four_cut/screens/select.dart';
import 'package:flutter/material.dart';

class CameraScreen extends StatefulWidget {
  static const route = '/camera';

  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late List<XFile> _capturedPhotos;
  late AudioPlayer _audioPlayer;
  late Timer _timer;
  int _photoCount = 0;
  var _isLoading = true;
  var _remainingTime = 5;

  @override
  void initState() {
    super.initState();
    _capturedPhotos = [];
    _audioPlayer = AudioPlayer();
    _initializeCamera();
  }

  void _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (!mounted) return; // mounted 상태 체크
      _controller = CameraController(cameras.last, ResolutionPreset.max);
      await _controller.initialize();
      if (!mounted) return; // mounted 상태 체크
      setState(() {
        _isLoading = false;
      });
      _startAutoCapture();
    } catch (e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    }
  }

  void _startAutoCapture() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime > 0 && _capturedPhotos.length < 8) {
        setState(() {
          _remainingTime--; // 남은 시간 1초씩 차감
        });
      } else if (_capturedPhotos.length == 8) {
        _timer.cancel();
        _audioPlayer.dispose();
        _controller.dispose();
        Navigator.pushNamed(
          context,
          SelectScreen.route,
          arguments: _capturedPhotos,
        );
      } else {
        _takePhoto();
      }
    });
  }

  void _takePhoto() async {
    if (_capturedPhotos.length <= 8) {
      _playShutterSound();
      final XFile photo = await _controller.takePicture();
      setState(() {
        _capturedPhotos.add(photo);
        _photoCount++;
        _remainingTime = 5; // 다음 사진 촬영을 위한 타이머 초기화
      });
    }
  }

  void _playShutterSound() async {
    await _audioPlayer.play(
      AssetSource('audios/camera-shutter.mp3'),
    ); // 셔터음 파일 재생
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose(); // 카메라 컨트롤러 해제
    _audioPlayer.dispose(); // 오디오 플레이어 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || !_controller.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flex(
            direction: Axis.vertical,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                width: 600,
                height: 800,
                child: CameraPreview(_controller),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 600,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _remainingTime += 5;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(20),
                          backgroundColor: Colors.blue, // <-- Button color
                          foregroundColor: Colors.red, // <-- Splash color
                        ),
                        child: Icon(
                          Icons.timelapse_rounded,
                          color: Colors.white,
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            '$_photoCount / 8',
                            style: TextStyle(
                              fontFamily: "Pretendard",
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '$_remainingTime',
                            style: TextStyle(
                              fontFamily: "Pretendard",
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _takePhoto();
                        },
                        style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(20),
                          backgroundColor: Colors.blue, // <-- Button color
                          foregroundColor: Colors.red, // <-- Splash color
                        ),
                        child: Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 600,
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal, // 가로로 스크롤 가능하게 설정
                  itemCount: _capturedPhotos.length,
                  itemBuilder: (context, idx) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Image.file(
                        File(_capturedPhotos[idx].path),
                        width: 80, // 각 사진의 크기
                        height: 80, // 각 사진의 크기
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
