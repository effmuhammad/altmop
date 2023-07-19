import 'package:altmop/ui/home/main_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:device_preview/device_preview.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((value) async {
    await Future.delayed(Duration(seconds: 1));
    runApp(
      DevicePreview(
        enabled: false,
        builder: (context) => const MainPage(),
      ),
    );
  });

  // WidgetsFlutterBinding.ensureInitialized();
  // await Future.delayed(Duration(seconds: 1));
  // runApp(
  //   DevicePreview(
  //     enabled: false,
  //     builder: (context) => const MainPage(),
  //   ),
  // );
}
