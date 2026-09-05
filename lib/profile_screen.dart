import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'splash_screen.dart';
import 'login_screen.dart';

class ProfileConfig {
  static const Color brandNavy = SplashConfig.neighborColor;
  static const Color brandGreen = SplashConfig.nestColor;
  static const Color primaryColor = SplashConfig.colorBlue;
  static const Color subtitleColor = Color(0xFF64748B);
  static const Color avatarBg = Color(0xFFE2E8F0);
  static const Color logoutRed = Color(0xFFEF4444);

  static const Duration logoutLoadingDuration = Duration(seconds: 2);

  static const Color logoutOverlayColor = Color(0x99000000);
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _neighborhood = '';
  bool _loadingNeighborhood = true;

  @override
  void initState() {
    super.initState();
    _loadNeighborhood();
  }

  Future<void> _loadNeighborhood() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _loadingNeighborhood = false);
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      setState(() {
        _neighborhood = (doc.data()?['neighborhood'] as String?) ?? 'Not set';
        _loadingNeighborhood = false;
      });
    } catch (_) {
      setState(() {
        _neighborhood = 'Not set';
        _loadingNeighborhood = false;
      });
    }
  }

  Future<void> _logOut() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: ProfileConfig.logoutOverlayColor,
      builder: (_) => PopScope(
        canPop: false,
        child: Center(
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            elevation: 8,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                  SizedBox(width: 16),
                  Text(
                    'Logging out...',
                    style: TextStyle(fontSize: 15, color: ProfileConfig.brandNavy),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    await Future.wait([
      FirebaseAuth.instance.signOut(),
      Future.delayed(ProfileConfig.logoutLoadingDuration),
    ]);

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = (user?.displayName != null && user!.displayName!.isNotEmpty)
        ? user.displayName!
        : 'User';
    final email = user?.email ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: ProfileConfig.brandNavy),
        centerTitle: true,
        title: const Text(
          'User Profile',
          style: TextStyle(color: ProfileConfig.brandNavy, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Column(
          children: [
            const SizedBox(height: 12),

            Container(
              width: 110,
              height: 110,
              decoration: const BoxDecoration(
                color: ProfileConfig.avatarBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, size: 58, color: ProfileConfig.primaryColor),
            ),
            const SizedBox(height: 16),

            Text(
              name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: ProfileConfig.brandNavy,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Community Member',
              style: TextStyle(color: ProfileConfig.subtitleColor, fontSize: 15),
            ),
            const SizedBox(height: 28),

            _ProfileTile(
              icon: Icons.person_outline,
              iconColor: ProfileConfig.primaryColor,
              label: 'Full Name',
              value: name,
            ),
            const SizedBox(height: 14),

            _ProfileTile(
              icon: Icons.mail_outline,
              iconColor: ProfileConfig.brandGreen,
              label: 'Email',
              value: email,
            ),
            const SizedBox(height: 14),

            _ProfileTile(
              icon: Icons.location_on_outlined,
              iconColor: ProfileConfig.primaryColor,
              label: 'Neighborhood / Area',
              value: _loadingNeighborhood ? 'Loading...' : _neighborhood,
            ),
            const SizedBox(height: 14),

            _ProfileTile(
              icon: Icons.logout,
              iconColor: ProfileConfig.logoutRed,
              label: 'Log Out',
              labelColor: ProfileConfig.logoutRed,
              value: 'Sign out from your account',
              onTap: _logOut,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final Color? labelColor;
  final String value;
  final VoidCallback? onTap;

  const _ProfileTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.labelColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: labelColor ?? ProfileConfig.brandNavy,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: const TextStyle(fontSize: 13.5, color: ProfileConfig.subtitleColor),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: ProfileConfig.subtitleColor),
            ],
          ),
        ),
      ),
    );
  }
}