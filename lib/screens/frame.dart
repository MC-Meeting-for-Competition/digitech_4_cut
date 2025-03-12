import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:digitech_four_cut/screens/index.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;

class Frame {
  final int frameIndex;
  final Color backgroundColor;
  final String frameImagePath;

  Frame(this.frameIndex, this.backgroundColor, this.frameImagePath);
}

class FrameScreen extends StatefulWidget {
  const FrameScreen({super.key});

  static const route = "/frame";

  @override
  State<FrameScreen> createState() => _FrameScreenState();
}

class _FrameScreenState extends State<FrameScreen> {
  bool _isUploading = false;

  final List<Frame> frameList = [
    Frame(1, Colors.black, 'assets/images/sdhs.png'),
    Frame(2, Color(0xffFFC0CB), 'assets/images/mc_transparent.png'),
    Frame(
      3,
      const Color(0xffFFFFF0),
      'assets/images/sdhs_symbol_transparent.png',
    ),
    Frame(4, const Color(0xff36454F), 'assets/images/sdhs.png'),
  ];

  Frame selectedFrame = Frame(
    1,
    Colors.black,
    'assets/images/sdhs.png',
  ); // 기본 프레임

  @override
  Widget build(BuildContext context) {
    List<XFile> selectedImages =
        ModalRoute.of(context)?.settings.arguments as List<XFile>;
    selectedImages = selectedImages.sublist(0, 4);

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              width: 700,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(width: 100),
                  Text(
                    '프레임을 골라주세요',
                    style: TextStyle(
                      fontSize: 30,
                      fontFamily: "Pretendard",
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: ElevatedButton(
                      onPressed: () async {
                        File mergedImage = await mergeFrameWithPhotos(
                          selectedImages: selectedImages,
                          frameColor: selectedFrame.backgroundColor,
                          frameImagePath: selectedFrame.frameImagePath,
                        );
                        await uploadImage(mergedImage);
                      },
                      child: Text("완료", style: TextStyle(fontSize: 20)),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 600,
              height: 800,
              decoration: BoxDecoration(color: selectedFrame.backgroundColor),
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                        ),
                        itemCount: selectedImages.length,
                        itemBuilder: (context, idx) {
                          return Padding(
                            padding: const EdgeInsets.all(10),
                            child: Image.file(
                              File(selectedImages[idx].path),
                              width: 260,
                              height: 240,
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 70),
                    child: Image.asset(
                      selectedFrame.frameImagePath,
                      width: 500,
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:
                  frameList.map((frame) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedFrame = frame;
                          });
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: frame.backgroundColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                                  selectedFrame == frame
                                      ? Colors.white
                                      : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Future<File> mergeFrameWithPhotos({
    required List<XFile> selectedImages,
    required Color frameColor,
    required String frameImagePath,
  }) async {
    const double imageWidth = 1200; // 고해상도 이미지 크기 (기존 600에서 2배로 증가)
    const double imageHeight = 1600;
    const double padding = 20;
    const double gridSize = (imageWidth - (padding * 3)) / 2;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.save();
    canvas.translate(0, imageHeight);
    canvas.scale(1, -1);

    // 배경 (프레임 색상)
    final paint = Paint()..color = frameColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, imageWidth, imageHeight), paint);

    // 이미지 배치 (그리드 형태)
    for (int i = 0; i < selectedImages.length; i++) {
      final imageFile = File(selectedImages[i].path);
      final ui.Image image = await decodeImageFromList(
        await imageFile.readAsBytes(),
      );

      final double dx = (i % 2) * (gridSize + padding) + padding;
      final double dy = (i ~/ 2) * (gridSize + padding) + padding;

      final src = Rect.fromLTWH(
        0,
        0,
        image.width.toDouble(),
        image.height.toDouble(),
      );
      final dst = Rect.fromLTWH(dx, dy, gridSize, gridSize);

      final paint = Paint();
      canvas.drawImageRect(image, src, dst, paint);
    }

    // 하단 프레임 이미지 추가
    final ByteData frameImageData = await rootBundle.load(frameImagePath);
    final Uint8List frameImageBytes = frameImageData.buffer.asUint8List();
    final ui.Image frameImage = await decodeImageFromList(frameImageBytes);

    // 하단 프레임 이미지 중앙 정렬 및 크기 조정
    double frameWidth = 480; // 고해상도 크기
    double frameHeight = 280; // 고해상도 크기

    double dx = (imageWidth - frameWidth) / 2; // 중앙에 배치

    final frameDst = Rect.fromLTWH(dx, 1300, frameWidth, frameHeight);
    canvas.drawImageRect(
      frameImage,
      Rect.fromLTWH(
        0,
        0,
        frameImage.width.toDouble(),
        frameImage.height.toDouble(),
      ),
      frameDst,
      Paint(),
    );

    canvas.restore();

    // 최종 이미지 생성
    final ui.Image finalImage = await recorder.endRecording().toImage(
      imageWidth.toInt(),
      imageHeight.toInt(),
    );

    final ByteData? byteData = await finalImage.toByteData(
      format: ui.ImageByteFormat.png,
    );
    final Uint8List pngBytes = byteData!.buffer.asUint8List();

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/final_four_cut_high_quality.png';
    final file = File(filePath);
    await file.writeAsBytes(pngBytes);

    return file;
  }

  Future<void> uploadImage(File imageFile) async {
    print("업로드 시작");
    if (_isUploading) return;
    setState(() {
      _isUploading = true;
    });

    try {
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("http://api.yunjisang.me:8888/upload"),
      );
      request.files.add(
        await http.MultipartFile.fromPath("file", imageFile.path),
      );

      var response = await request.send();

      if (response.statusCode == 201) {
        print('파일 업로드 성공');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('파일 업로드 성공!')));

          Navigator.pushNamed(
            context,
            QRCodeScreen.route,
            arguments: response.stream.bytesToString(),
          );
        }
      } else {
        print('파일 업로드 실패');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '사진 저장에 실패했어요. 지속적으로 문제가 발생한다면 3학년 4반 (309호) 로 찾아와주세요.',
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('에러 발생: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '사진 저장에 실패했어요. 지속적으로 문제가 발생한다면 3학년 4반 (309호) 로 찾아와주세요.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }
}
