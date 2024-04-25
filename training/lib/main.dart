import 'package:flutter/material.dart';
import 'login.dart'; // Impor kelas Login dari file login.dart

void main() {
  runApp(const MyApp()); // Panggil runApp dengan MyApp sebagai root widget
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Training',
      home: Login(), // Tetapkan kelas Login sebagai home widget
    );
  }
}
