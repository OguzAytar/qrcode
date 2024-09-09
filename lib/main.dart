import 'package:flutter/material.dart';
import 'package:qrcode/view/homeScreen/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: 'QR Code Scanner App', home: AnaSayfa());
  }
}
