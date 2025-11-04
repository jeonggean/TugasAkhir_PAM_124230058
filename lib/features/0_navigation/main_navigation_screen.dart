import 'package:eventfinder/features/0_navigation/main_navigation_controller.dart';
import 'package:eventfinder/features/1_event/screens/event_list_screen.dart';
import 'package:eventfinder/features/3_favorites/controllers/favorites_controller.dart';
import 'package:eventfinder/features/3_favorites/screens/favorites_screen.dart';
import 'package:eventfinder/features/6_friends/screens/friends_screen.dart';
import 'package:eventfinder/features/6_friends/controllers/friend_controller.dart';
import 'package:eventfinder/features/5_profile/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventfinder/core/utils/app_colors.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  static final List<Widget> _widgetOptions = <Widget>[
    EventListScreen(),
    const FavoritesScreen(),
    const FriendsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => MainNavigationController(),
        ),
        ChangeNotifierProvider(
          create: (context) => FavoritesController()..loadFavorites(),
        ),
        ChangeNotifierProvider(
          create: (context) => FriendsController()..loadInitialData(),
        ),
      ],
    
      child: Consumer<MainNavigationController>(
        builder: (context, controller, child) {
          return Scaffold(
            body: Center(
              child: _widgetOptions.elementAt(controller.selectedIndex),
            ),
            bottomNavigationBar: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Beranda',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite_border),
                  activeIcon: Icon(Icons.favorite),
                  label: 'Favorit',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.group_outlined),
                  activeIcon: Icon(Icons.group),
                  label: 'Teman',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Profil',
                ),
              ],
              // Ambil state dan method dari controller
              currentIndex: controller.selectedIndex,
              onTap: controller.onItemTapped,
              // Style Anda
              selectedItemColor: AppColors.kPrimaryColor,
              unselectedItemColor: Colors.grey,
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              elevation: 8.0,
            ),
          );
        },
      ),
    );
  }
}