import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'profile_screen.dart';

class HomeConfig {
  static const Color brandNavy = SplashConfig.neighborColor;
  static const Color brandGreen = SplashConfig.nestColor;
  static const Color primaryColor = SplashConfig.colorBlue;
  static const Color hintColor = Color(0xFF94A3B8);
}

const List<String> _tabLabels = [
  'Home',
  'Lost & Found',
  'Donate',
  'Volunteer',
  'Board',
  'Profile',
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const int _homeIndex = 0;
  static const int _profileIndex = 5;

  void _onTabTapped(int index) {
    if (index == _homeIndex) return;

    if (index == _profileIndex) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ComingSoonScreen(title: _tabLabels[index])),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Home',
          style: TextStyle(
            color: HomeConfig.brandNavy,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: const SizedBox.expand(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _homeIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: HomeConfig.primaryColor,
        unselectedItemColor: HomeConfig.hintColor,
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Lost & Found'),
          BottomNavigationBarItem(icon: Icon(Icons.card_giftcard_outlined), label: 'Donate'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Volunteer'),
          BottomNavigationBarItem(icon: Icon(Icons.campaign_outlined), label: 'Board'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

class ComingSoonScreen extends StatelessWidget {
  final String title;

  const ComingSoonScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(title, style: const TextStyle(color: Colors.white)),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Coming soon!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}