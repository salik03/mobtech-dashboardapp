import 'package:dashboardapp/resourcespage.dart';
import 'package:dashboardapp/roadmapspage.dart';
import 'package:dashboardapp/socialsscreen.dart';
import 'package:dashboardapp/updatesscreen.dart';
import 'package:flutter/material.dart';

class userDashBoard extends StatefulWidget {
  const userDashBoard({super.key});

  @override
  _userDashBoardState createState() => _userDashBoardState();
}

class _userDashBoardState extends State<userDashBoard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const updatesScreen(admin: false),
    const ResourcesPage(),
    const roadMapsPage(
      adminbool: false,
    ),
    const SocialsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Dashboard'),
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
          ],
        ),
      ),
    );
  }
}
