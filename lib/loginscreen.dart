import 'dart:convert';
import 'package:dashboardapp/adminscreen.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'userscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'globals.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var registrationToken;
  late Map<String, dynamic> tokenData;
  final TextEditingController emailController = TextEditingController();
  var credential;
  static final TextEditingController passwordController =
      TextEditingController();
  var headers = {'Content-Type': 'application/json'};

  Future<void> registerDevice() async {
    registrationToken = await FirebaseMessaging.instance.getToken();
    tokenData = {"token": registrationToken};
    var request = http.Request('POST',
        Uri.parse('https://mobilon-backend.onrender.com/registerDevice'));
    request.body = json.encode(tokenData);
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
  }

  void _handleLogin() async {
    String email = emailController.text;
    String password = passwordController.text;
    GlobalVars.globalPassword = password;

    try {
      credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid email or password."),
          duration: Duration(seconds: 2),
        ),
      );
    }
    try {
      final user = credential.user;
      if (user != null) {
        await registerDevice();

        if (password.contains("core")) {
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const userDashBoard()),
          );
        } else if (password.contains("head")) {
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const adminDashBoard()),
          );
        } else {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Invalid email or password."),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (NoSuchMethodError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid email or password."),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(child: Image.asset('assets/Mobilonv2.png')),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
              ),
              const SizedBox(height: 20.0),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _handleLogin,
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
