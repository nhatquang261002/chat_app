import 'package:chatapp_firebase/firebase_options.dart';
import 'package:chatapp_firebase/references/references.dart';
import 'package:chatapp_firebase/screens/chat_screen.dart';
import 'package:chatapp_firebase/services/cloud_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/home_screen.dart';
import 'screens/login/login_screen.dart';

// https://www.youtube.com/watch?v=Qwk5oIAkgnY&t
// https://github.com/backslashflutter/group_chatapp_flutter_firebase

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isSignedIn = false;

  getUserLoggedInStatus() async {
    await References.getUserLoggedInStatus().then((value) {
      if (value != null) {
        setState(() {
          _isSignedIn = value;
        });
      }
    });
  }

  @override
  void initState() {
    getUserLoggedInStatus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CloudStorage(),
      child: MaterialApp(
        theme: ThemeData(
            primaryColor: const Color(0xFFee7b64),
            scaffoldBackgroundColor: Colors.white),
        debugShowCheckedModeBanner: false,
        home: _isSignedIn ? const HomeScreen() : const LoginScreen(),
        initialRoute: '/',
        routes: {
          '/HomeScreen': (context) => const HomeScreen(),
        },
      ),
    );
  }
}
