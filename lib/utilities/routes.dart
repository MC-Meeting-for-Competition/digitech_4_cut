import 'package:digitech_four_cut/screens/index.dart';
import 'package:flutter/material.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    try {
      switch (routeSettings.name) {
        case MainScreen.route:
          return MaterialPageRoute(
            settings: routeSettings,
            builder: (_) => MainScreen(),
          );
        case CameraScreen.route:
          return MaterialPageRoute(
            settings: routeSettings,
            builder: (_) => CameraScreen(),
          );
        case SelectScreen.route:
          return MaterialPageRoute(
            settings: routeSettings,
            builder: (_) => SelectScreen(),
          );
        case FrameScreen.route:
          return MaterialPageRoute(
            settings: routeSettings,
            builder: (_) => FrameScreen(),
          );
        case QRCodeScreen.route:
          return MaterialPageRoute(
            settings: routeSettings,
            builder: (_) => QRCodeScreen(),
          );
        default:
          return errorRoute(routeSettings);
      }
    } catch (_) {
      return errorRoute(routeSettings);
    }
  }

  static Route<dynamic> errorRoute(RouteSettings routeSettings) {
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => ErrorScreen(),
    );
  }
}
