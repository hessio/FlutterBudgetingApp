// import 'package:dart_openai/openai.dart';
import 'package:dart_openai/openai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tryagain/Screens/EmailVerificationScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tryagain/util/constants.dart';
import 'Screens/LoginScreen.dart';
import 'Screens/RegisterScreen.dart';
import 'Screens/SplashScreen.dart';
import 'Screens/StartScreen.dart';
import 'Screens/TopNavigationScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final envFile = File('.env');
  print(envFile);
  await dotenv.load(fileName: envFile.path);

  OpenAI.apiKey = dotenv.env['OPENAI_SECRET_KEY']!; // Initialize the package with that API key
  OpenAI.organization = dotenv.env['ORG_ID']!; // Initialize the package with that API key
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(color: Colors.black),
          color: Colors.deepPurpleAccent,
          foregroundColor: Colors.black,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarBrightness: Brightness.light,
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: SplashScreen.id,
      routes: {
        SplashScreen.id: (context) => SplashScreen(),
        StartScreen.id: (context) => StartScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        RegisterScreen.id: (context) => RegisterScreen(),
        EmailVerificationScreen.id: (context) => const EmailVerificationScreen(),
        TopNavigationScreen.id: (context) => TopNavigationScreen(),
      },
    );
  }
}

