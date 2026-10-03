import 'package:flutter/material.dart';
import 'package:btth1/pages/homePage/homePage.dart';

void main() {
  runApp(const StudyDocumentApp());
}

class StudyDocumentApp extends StatelessWidget {
  const StudyDocumentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản lý Tài liệu Học tập',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E3C72)),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
