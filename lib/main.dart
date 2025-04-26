import 'package:flutter/material.dart';
import 'package:qrcode/view/homeScreen/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData.light().copyWith(
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xAA82161F),
            foregroundColor: Colors.white,
          ),
          colorScheme: const ColorScheme.light(
            primary: Color(0xAA82161F),
            onPrimary: Colors.white,
            secondary: Color(0xAA82161F),
            onSecondary: Colors.white,
          ),
        ),
        title: 'QR Code Scanner App',
        home: const AnaSayfa());
  }
}
