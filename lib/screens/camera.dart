import 'package:flutter/material.dart';

class CameraScreen extends StatelessWidget {
  static const route = '/camera';

  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: Text("camera")));
  }
}
