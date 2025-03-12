import 'dart:async';
import 'dart:io';

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
  late Timer _timer;
  int _photoCount = 0;
  var _isLoading = true;
  var _remainingTime = 10;

  @override
  void initState() {
    super.initState();
    _capturedPhotos = [];
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
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--; // 남은 시간 1초씩 차감
        });
      } else if (_photoCount < 7) {
        _takePhoto();
      } else {
        _timer.cancel();
        Navigator.pushNamed(
          context,
          SelectScreen.route,
          arguments: _capturedPhotos,
        ); // MainScreen.route 대신 직접 경로를 설정
      }
    });
  }

  void _takePhoto() async {
    if (_photoCount < 7) {
      final XFile photo = await _controller.takePicture();
      setState(() {
        _capturedPhotos.add(photo);
        _photoCount++;
        _remainingTime = 10; // 다음 사진 촬영을 위한 타이머 초기화
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose(); // 카메라 컨트롤러 해제
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
                child: Column(
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
