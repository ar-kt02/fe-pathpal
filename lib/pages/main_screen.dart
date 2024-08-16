import 'package:fe_pathpal/pages/home_page.dart';
import 'package:fe_pathpal/pages/stats_page.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentPage = 0;

  @override
  Widget build(BuildContext build) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPage = index;
          });
        },
        indicatorColor: Colors.blue.shade100,
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
      body: <Widget>[const HomePage(), const StatsPage()][currentPage],
    );
  }
}
