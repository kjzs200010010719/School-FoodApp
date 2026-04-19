import 'package:flutter/material.dart';
import 'package:my_app/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

// 
// StatelessWidget(無狀態元件），本身不需要管理任何動態資料
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '膳解人意',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4E8D57),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F9F4),
      ),
      home: const HomeScreen(),
    );
  }
}