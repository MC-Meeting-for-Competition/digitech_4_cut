import 'dart:io';

import 'package:camera/camera.dart';
import 'package:digitech_four_cut/screens/index.dart';
import 'package:flutter/material.dart';

class SelectScreen extends StatefulWidget {
  static const route = '/select';

  const SelectScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SelectScreenState();
}

class _SelectScreenState extends State<SelectScreen> {
  List<int> selectedImages = [];
  List<XFile> selectedImageFiles = [];

  @override
  Widget build(BuildContext context) {
    // 전달된 데이터를 받기
    final List<XFile> capturedPhotos =
        ModalRoute.of(context)?.settings.arguments as List<XFile>;

    return Scaffold(
      body: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: 700,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: 100),
                      Text(
                        "사진을 4장 골라주세요",
                        style: TextStyle(
                          fontSize: 30,
                          fontFamily: "Pretendard",
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: ElevatedButton(
                          onPressed: () {
                            if (selectedImages.length < 4) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('4개의 사진을 선택해주세요.')),
                              );
                            } else {
                              for (var idx in selectedImages) {
                                if (selectedImageFiles.length > 4) break;
                                selectedImageFiles.add(capturedPhotos[idx]);
                              }

                              Navigator.pushNamed(
                                context,
                                FrameScreen.route,
                                arguments: selectedImageFiles,
                              );
                            }
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
                  decoration: BoxDecoration(color: Colors.black),
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
                            File(capturedPhotos[selectedImages[idx]].path),
                            width: 260,
                            height: 240,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(
                  width: 700,
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal, // 가로로 스크롤 가능하게 설정
                    itemCount: capturedPhotos.length,
                    itemBuilder: (context, idx) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              if (selectedImages.length >= 4) return;
                              if (selectedImages.contains(idx)) {
                                selectedImages.remove(idx);
                              } else {
                                selectedImages.add(idx);
                              }
                            });
                          },
                          child: Image.file(
                            File(capturedPhotos[idx].path),
                            width: 100, // 각 사진의 크기
                            height: 100, // 각 사진의 크기
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
