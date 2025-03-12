import 'package:digitech_four_cut/screens/camera.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  static const route = '/';

  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flex(
              direction: Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Image.asset("assets/images/logo.png", height: 320, width: 320),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed:
                          () => {
                            Navigator.pushNamed(context, CameraScreen.route),
                          },
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(320, 120),
                        backgroundColor: Color(0xff8c52ff),
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        "사진찍기",
                        style: TextStyle(
                          fontFamily: "Pretendard",
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 60),
                    Column(
                      children: [
                        Image.asset(
                          "assets/images/mc_transparent.png",
                          height: 80,
                        ),
                        Text(
                          "Copyright 2025. MC All rights reserved.",
                          style: TextStyle(
                            fontFamily: "Pretendard",
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
