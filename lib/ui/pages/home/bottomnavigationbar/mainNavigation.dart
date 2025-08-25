import 'package:flutter/material.dart';
import 'package:logosmart/ui/pages/home/bottomnavigationbar/HomePage.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int currentIndex = 0;
  final List<Widget> _pages = [
    HomePage(),
    Scaffold(backgroundColor: Color(0xffd5eef7),),
    Scaffold(),
    Scaffold(),
    Scaffold(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[currentIndex],
      bottomNavigationBar: Container(
        color: Color(0xffd5eef7),
        height: 70,
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
          child: BottomNavigationBar(

          backgroundColor: Color(0xffffffff),
          type: BottomNavigationBarType.fixed,

          onTap: _onItemTapped,
          unselectedItemColor: Color(0xff7895A3),
          unselectedFontSize: 10,
          selectedFontSize: 10,

          selectedItemColor: Color(0xff20B9E8),

          selectedIconTheme: IconThemeData(size: 22, color: Color(0xff20B9E8)),
          unselectedIconTheme: IconThemeData(color: Color(0xff7895A3),size: 22),
          currentIndex: currentIndex,
          showUnselectedLabels: true,
          showSelectedLabels: true,
          items: [
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: ImageIcon( AssetImage('assets/icons/streamline.png',)),
              ),
              label: "Mashg'ulotlar",
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: ImageIcon( AssetImage('assets/icons/game.png',)),
              ),
              label: "O'yinlar",
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: ImageIcon( AssetImage('assets/icons/consultation.png',)),
              ),
              label: "Konsultatsiya",
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: ImageIcon( AssetImage('assets/icons/community.png',)),
              ),
              label: "Jamiyat",
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: ImageIcon( AssetImage('assets/icons/profile.png',)),
              ),
              label: "Profil",
            ),
          ],
                ),
        ),
      )
    );
  }
}
