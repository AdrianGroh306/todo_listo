import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'pages/auth_page.dart';
import 'services/theme.dart';
import 'package:provider/provider.dart';
import 'states/auth_state.dart';
import 'states/list_state.dart';
import 'states/todo_state.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthState()),
        ChangeNotifierProvider(create: (_) => ListState()),
        ChangeNotifierProvider(create: (_) => TodoState()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.system,
        home: const AuthPage(),
        builder: FlutterSmartDialog.init(),
      ),
    );
  }
}
