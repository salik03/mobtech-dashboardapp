import 'package:dashboardapp/loginscreen.dart';
import 'package:dashboardapp/updatesscreen.dart';
import 'package:dashboardapp/resourcespage.dart';
import 'package:dashboardapp/roadmapspage.dart';
import 'package:dashboardapp/socialsscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class adminDashBoard extends StatefulWidget {
  final String? filter;
  const adminDashBoard({Key? key, this.filter}) : super(key: key);

  @override
  _adminDashBoardState createState() => _adminDashBoardState();
}

class _adminDashBoardState extends State<adminDashBoard> {
  int _selectedIndex = 0;
  var registrationToken;
  late Map<String, dynamic> tokenData;
  var headers = {'Content-Type': 'application/json'};
  late final List<Widget> _pages;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _handleMessage(RemoteMessage message) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const adminDashBoard()),
    );
  }

  void _showNotification(RemoteMessage message) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("New Updates Recieved!"),
      ),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const adminDashBoard()),
    );
  }

  Future<void> deleteAccount() async {
    registrationToken = await FirebaseMessaging.instance.getToken();
    tokenData = {"token": registrationToken};
    var request = http.Request('POST',
        Uri.parse('https://mobilon-backend.onrender.com/deleteAccount'));
    request.body = json.encode(tokenData);
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
  }

  void _logout() async {
    await deleteAccount();
    await FirebaseAuth.instance.signOut();
  }

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showNotification(message);
    });
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
    _pages = [
      updatesScreen(
        admin: false,
        filter: widget.filter,
      ),
      ResourcesPage(),
      roadMapsPage(
        adminbool: false,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: _pages[_selectedIndex],
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'MOBILON',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: const Text('Latest Updates'),
              onTap: () {
                _onItemTapped(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Resources'),
              onTap: () {
                _onItemTapped(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Developer Roadmaps'),
              onTap: () {
                _onItemTapped(2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Social Links'),
              onTap: () {
                _onItemTapped(3);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Logout'),
              onTap: () {
                _logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
