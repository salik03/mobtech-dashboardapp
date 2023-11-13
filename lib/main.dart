import 'package:dashboardapp/adminscreen.dart';
import 'package:dashboardapp/globals.dart';
import 'package:dashboardapp/loginscreen.dart';
import 'package:dashboardapp/userscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  bool loggedIn = false;
  String email = "";
  if (FirebaseAuth.instance.currentUser != null) {
    loggedIn = true;
    email = FirebaseAuth.instance.currentUser!.email!;
    if (email.contains("chair")) {
      GlobalVars.globalPassword = "chair";
    } else if (email.contains("vicechair")) {
      GlobalVars.globalPassword = "vicechair";
    } else if (email.contains("tech")) {
      GlobalVars.globalPassword = "technical";
    } else if (email.contains("project")) {
      GlobalVars.globalPassword = "project";
    } else if (email.contains("content")) {
      GlobalVars.globalPassword = "content";
    } else if (email.contains("marketing")) {
      GlobalVars.globalPassword = "marketing";
    } else if (email.contains("design")) {
      GlobalVars.globalPassword = "design";
    }
  }
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: false,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  runApp(LoginApp(
    loggedIn: loggedIn,
    email: email,
  ));
}

void _handleMessage(RemoteMessage message) {
  // Handle the message when the app is opened from the background
  main();
}

class LoginApp extends StatelessWidget {
  final bool loggedIn;
  final String email;
  const LoginApp({super.key, required this.loggedIn, required this.email});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: AnimatedSplashScreen(
        splash: 'assets/Mobilonv1.png',
        splashIconSize: double.infinity,
        nextScreen: !loggedIn
            ? const LoginScreen()
            : email.contains("junior")
                ? const userDashBoard()
                : const adminDashBoard(),
        splashTransition: SplashTransition.scaleTransition,
      ),
    );
  }
}
