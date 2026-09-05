import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Placeholder — design this screen later.
/// Reached after a successful login or signup.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NeighborNest'),
        actions: [
          // Handy while testing — lets you log out and go try the login/
          // signup flow again without reinstalling the app.
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: const Center(
        child: Text('Home screen — coming soon'),
      ),
    );
  }
}