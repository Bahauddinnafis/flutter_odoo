import 'package:flutter/material.dart';
import 'login.dart'; // Impor kelas Login dari file login.dart
import 'package:provider/provider.dart';

// import 'package:hive/hive.dart';
// import 'package:path_provider/path_provider.dart' as path_provider;
import 'session_manager.dart'; // import class yang sudah dibuat

void main() {
  // WidgetsFlutterBinding
  //     .ensureInitialized(); // Untuk memastikan bahwa plugin telah diinisialisasi
  // final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  // Hive.init(appDocumentDir.path);
  // await Hive.openBox('odoo'); // Pastikan untuk membuka kotak 'odoo' di sini
  runApp(
    ChangeNotifierProvider(
      create: (context) => SessionManager(),
      child: const MyApp(),
    ),
  );
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
