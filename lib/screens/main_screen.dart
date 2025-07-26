// lib/screens/main_screen.dart

import 'package:dmp/screens/discover_screen.dart';
import 'package:dmp/screens/home_screen.dart';
import 'package:dmp/screens/profile_screen.dart';
import 'package:dmp/screens/conversations_list_screen.dart'; 
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color bottomNavActiveColor = Color(0xFFE91E63);
const Color bottomNavInactiveColor = Color(0xFF757575);
const Color appBarTitleColor = Colors.black87;

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // *** UPDATE THE WIDGET OPTIONS LIST ***
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    DiscoverScreen(),
    Scaffold(body: Center(child: Text('Likes Screen (Placeholder)'))),
    ConversationsListScreen(),
    ProfileScreen(), // <-- REPLACE THE PLACEHOLDER
  ];

  static const List<String> _widgetTitles = <String>[
    'Home',
    'Discover',
    'Likes',
    'Chats',
    'Profile',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _widgetTitles.elementAt(_selectedIndex),
          style: GoogleFonts.montserrat(
            color: appBarTitleColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: _selectedIndex == 1 // Only show actions for Discover tab
            ? [
                IconButton(
                  icon: const Icon(Icons.tune_rounded, color: appBarTitleColor),
                  onPressed: () { /* Handle filter */ },
                ),
              ]
            : null,
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: false,
      ),
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          // ... your BottomNavigationBarItems remain the same
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search_outlined), activeIcon: Icon(Icons.search), label: 'Discover'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border_outlined), activeIcon: Icon(Icons.favorite), label: 'Likes'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline_rounded), activeIcon: Icon(Icons.chat_bubble_rounded), label: 'Chats'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), activeIcon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: bottomNavActiveColor,
        unselectedItemColor: bottomNavInactiveColor,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 2.0,
        selectedLabelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w500),
        unselectedLabelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w500),
      ),
    );
  }
}