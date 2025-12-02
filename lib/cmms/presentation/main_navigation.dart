import 'package:flutter/material.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';


import '../../utils/constants.dart';
import 'screens/home/home_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/settings/setting_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const WorkingInstructionsScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }


  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final appBarTitle = _selectedIndex == 0
        ? localizations.cmms
        : _selectedIndex == 1
        ? localizations.listInstructions
        : localizations.profile;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _selectedIndex == 3
          ? null
          : AppBar(
              backgroundColor: Colors.white10,
              automaticallyImplyLeading: false,
              surfaceTintColor: Colors.transparent, // 👈 Ngăn đổi màu khi cuộn
              elevation: 0, // 👈 Bỏ hiệu ứng đổ bóng khi cuộn
              titleSpacing: 0,
              title: Padding(
                padding: const EdgeInsets.only(top: 30.0, bottom: 20),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Logo bên trái
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 24),
                        child: Image.asset(
                          'assets/images/acumenIcon.png',
                          height: 30,
                        ),
                      ),
                    ),
                    // Tiêu đề căn giữa tuyệt đối
                    Text(
                      appBarTitle,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: white,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: localizations.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.checklist),
            label: localizations.instructions,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: localizations.profile,
          ),
        ],
      ),
    );
  }
}
