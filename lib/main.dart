import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'splash_screen.dart';
import 'welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NeighborNest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // Flow: Splash -> Welcome -> (Get Started -> Signup) / (I already have
      // an account -> Login). Signup/Login are blank placeholders for now.
      // revealBackground keeps the slide-up transition visually seamless —
      // it's just a static image, not the animated WelcomeScreen itself.
      home: SplashScreen(
        homeScreen: const WelcomeScreen(),
        revealBackground: Image.asset(WelcomeConfig.bgAsset, fit: BoxFit.cover),
      ),
    );
  }
}