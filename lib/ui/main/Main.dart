import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../discovery/Discovery.dart';
import '../home/Home.dart';
import '../settings/Settings.dart';
import '../user/User.dart';

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
      ),
      home: MusicHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MusicHomePage extends StatefulWidget {
  const MusicHomePage({super.key});

  @override
  State<MusicHomePage> createState() => _MusicHomePageState();
}

class _MusicHomePageState extends State<MusicHomePage> {
  final List<Widget> tabs = [
    HomeTab(),
    DiscoveryTab(),
    UserTab(),
    SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('Music App'),
        ),
        child: CupertinoTabScaffold(
            tabBar: CupertinoTabBar(backgroundColor: Theme.of(context).colorScheme.onPrimary, items: [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.album), label: 'Discovery'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
              BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
            ]),
            tabBuilder: (context, index) {
              return tabs[index];
            }));
  }
}
