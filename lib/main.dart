import 'package:firebase_core/firebase_core.dart';
import 'package:todo/pages/auth_page.dart';
import 'package:todo/services/theme.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,

      home: const AuthPage(),
    );
  }
}
