import 'package:flutter/material.dart';
import '../1_event/screens/event_list_screen.dart';
import '../3_favorites/screens/favorites_screen.dart';
import '../5_profile/screens/profile_screen.dart';
import 'package:eventfinder/core/utils/app_colors.dart';


class MainNavigationScreen extends StatefulWidget {
  MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return EventListScreen();
      case 1:
        return FavoritesScreen(
          key: ValueKey('favorites_${DateTime.now().millisecondsSinceEpoch}'),
        );
      case 2:
        return const ProfileScreen();
      default:
        return EventListScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getCurrentScreen(), // Panggil fungsi di sini
      bottomNavigationBar: _buildFloatingNavBar(),
    );
  }

  Widget _buildFloatingNavBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, 
        borderRadius: BorderRadius.circular(30.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2), 
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30.0),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent, 
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false, 
          showUnselectedLabels: false, 
          selectedItemColor: Theme.of(context).colorScheme.primary, 
          unselectedItemColor: AppColors.kSecondaryTextColor, 
          elevation: 0, 

          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_filled),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border_outlined),
              activeIcon: Icon(Icons.favorite),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}