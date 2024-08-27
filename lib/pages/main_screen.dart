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
     
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.blue.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: <Widget>[
          const HomePage(),
          const StatsPage(),
          const SettingsPage(),
        ][currentPage],
      ),

     
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: Colors.blue.shade50,
          indicatorColor: Colors.blue.shade200,
          labelTextStyle: MaterialStateProperty.all(
            TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.blue.shade700,
            ),
          ),
        ),
        child: NavigationBar(
          onDestinationSelected: (int index) {
            setState(() {
              currentPage = index;
            });
          },
          selectedIndex: currentPage,
          destinations: const <NavigationDestination>[
            NavigationDestination(
              selectedIcon: Icon(Icons.pets, color: Colors.blue),
              icon: Icon(Icons.pets_outlined, color: Colors.black54),
              label: 'Home',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.query_stats, color: Colors.blue),
              icon: Icon(Icons.query_stats_outlined, color: Colors.black54),
              label: 'Stats',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.manage_accounts, color: Colors.blue),
              icon: Icon(Icons.manage_accounts_outlined, color: Colors.black54),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}