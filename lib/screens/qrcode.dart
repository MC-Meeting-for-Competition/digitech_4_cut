import 'package:digitech_four_cut/screens/main.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCodeScreen extends StatelessWidget {
  static const route = "/qrcode";

  const QRCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future<String> url =
        ModalRoute.of(context)?.settings.arguments as Future<String>;

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: url,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(); // 로딩 중 표시
            } else if (snapshot.hasError) {
              return Text('에러 발생: ${snapshot.error}'); // 에러 처리
            } else if (snapshot.hasData) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            '네컷사진이 저장되었어요!',
                            style: TextStyle(
                              fontSize: 30,
                              fontFamily: "Pretendard",
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '사진은 1시간 후 삭제돼요',
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: "Pretendard",
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            "사진 저장하기",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Pretendard",
                            ),
                          ),
                          QrImageView(
                            data: snapshot.data!, // URL을 QR 코드로 생성
                            size: 400.0,
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, MainScreen.route);
                        },
                        style: ElevatedButton.styleFrom(
                          fixedSize: Size(320, 120),
                          backgroundColor: Color(0xff8c52ff),
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          "메인으로",
                          style: TextStyle(
                            fontFamily: "Pretendard",
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            } else {
              return Text('데이터 없음');
            }
          },
        ),
      ),
    );
  }
}
