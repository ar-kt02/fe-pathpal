import 'home_page.dart';
import 'stats_page.dart';
import 'settings_page.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: Colors.blue.shade100,
          labelTextStyle: MaterialStateProperty.all(
            const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          iconTheme: MaterialStateProperty.all(
            IconThemeData(color: Colors.blue.shade600),
          ),
        ),
        child: NavigationBar(
          onDestinationSelected: (int index) {
            setState(() {
              currentPage = index;
            });
          },
          selectedIndex: currentPage,
          destinations: const <Widget>[
            NavigationDestination(
              selectedIcon: Icon(Icons.pets),
              icon: Icon(Icons.pets_outlined),
              label: 'Home',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.query_stats),
              icon: Icon(Icons.query_stats_outlined),
              label: 'Stats',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.manage_accounts),
              icon: Icon(Icons.manage_accounts_outlined),
              label: 'Settings',
            )
          ],
        ),
      ),
      body: <Widget>[
        const HomePage(),
        const StatsPage(),
        const SettingsPage(),
      ][currentPage],
    );
  }
}