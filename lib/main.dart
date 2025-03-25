import 'package:flutter/material.dart';
import 'image_picker_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'إزالة العلامة المائية',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      home: const ImagePickerScreen(),
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar', 'SA'), // لدعم اللغة العربية
    );
  }
}