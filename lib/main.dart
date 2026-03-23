import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_app/app/smart_home_app.dart';

void main() {
  // Ensures plugin/services are ready before UI startup.
  WidgetsFlutterBinding.ensureInitialized();
  // Configures status bar style for the app theme.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Launches the root widget.
  runApp(const SmartHomeApp());
}
