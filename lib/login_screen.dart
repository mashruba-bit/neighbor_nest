import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'splash_screen.dart'; // for the shared color palette (SplashConfig)
import 'welcome_screen.dart'; // for the shared HoverScaleButton
import 'signup_screen.dart';
import 'home_screen.dart';

/// ============================================================
/// LOG IN SCREEN CONFIG
/// ------------------------------------------------------------
/// Sizes, colors, and text live here so they're easy to tweak
/// without touching the widget code below.
/// ============================================================
class LoginConfig {
  static const String iconAsset = 'assets/images/icon.png';

  static const Color brandNavy = SplashConfig.neighborColor;
  static const Color brandGreen = SplashConfig.nestColor;
  static const Color primaryColor = SplashConfig.colorBlue;
  static const Color fieldBorderColor = Color(0xFFCBD5E1);
  static const Color hintColor = Color(0xFF94A3B8);
  static const Color subtitleColor = Color(0xFF64748B);

  static const double iconSize = 150;
  static const double brandFontSize = 30;
  static const double subtitleFontSize = 17;
  static const double fieldFontSize = 16;
  static const double fieldHeight = 60;
  static const double fieldRadius = 14;
  static const double buttonHeight = 56;
  static const double buttonRadius = 16;
  static const double buttonFontSize = 18;

  static const double horizontalPadding = 26;
  static const double gapBetweenFields = 18;
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // The whole login flow: 1) check fields locally, 2) ask Firebase to sign
  // in, 3) go to the home screen, 4) handle any error simply.
  Future<void> _logIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Please fill in all fields.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    } on FirebaseAuthException catch (e) {
      _showMessage(e.message ?? 'Login failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Sends a password-reset email using whatever is currently typed in the
  // email field.
  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showMessage('Enter your email above first, then tap "Forgot Password?".');
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showMessage('Password reset email sent to $email.');
    } on FirebaseAuthException catch (e) {
      _showMessage(e.message ?? 'Could not send reset email.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SplashConfig.colorLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: LoginConfig.horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // Back arrow
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back, color: LoginConfig.brandNavy),
              ),

              const SizedBox(height: 8),

              // Icon — no animation here, just the plain image.
              Center(
                child: Image.asset(
                  LoginConfig.iconAsset,
                  width: LoginConfig.iconSize,
                  height: LoginConfig.iconSize,
                ),
              ),
              const SizedBox(height: 16),

              // Brand name, same two-color style as the other screens.
              Center(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: LoginConfig.brandFontSize, fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(text: 'Neighbor', style: TextStyle(color: LoginConfig.brandNavy)),
                      TextSpan(text: 'Nest', style: TextStyle(color: LoginConfig.brandGreen)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Welcome back! Please login to continue',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: LoginConfig.subtitleFontSize, color: LoginConfig.subtitleColor),
                ),
              ),
              const SizedBox(height: 32),

              _AppTextField(
                controller: _emailController,
                hint: 'Email',
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: LoginConfig.gapBetweenFields),

              _AppTextField(
                controller: _passwordController,
                hint: 'Password',
                icon: Icons.lock_outline,
                obscureText: _obscurePassword,
                trailing: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  color: LoginConfig.hintColor,
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: _forgotPassword,
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(color: LoginConfig.primaryColor, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // Log In button — same hover/press "grow slightly" feedback
              // as the other screens' buttons.
              HoverScaleButton(
                onTap: _isLoading ? () {} : _logIn,
                child: Container(
                  width: double.infinity,
                  height: LoginConfig.buttonHeight,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: LoginConfig.primaryColor,
                    borderRadius: BorderRadius.circular(LoginConfig.buttonRadius),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                      : Text(
                    'Log In',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: LoginConfig.buttonFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              Center(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 15, color: LoginConfig.subtitleColor),
                    children: [
                      const TextSpan(text: "Don't have an account? "),
                      TextSpan(
                        text: 'Sign Up',
                        style: const TextStyle(color: LoginConfig.primaryColor, fontWeight: FontWeight.w600),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SignupScreen()));
                          },
                      ),
                    ],
                  ),
                ),
              ),

              // ---- Admin Login section ----
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(child: Divider(color: LoginConfig.fieldBorderColor)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      '',
                      style: TextStyle(color: LoginConfig.hintColor),
                    ),
                  ),
                  Expanded(child: Divider(color: LoginConfig.fieldBorderColor)),
                ],
              ),
              const SizedBox(height: 14),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AdminComingSoonScreen()),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text('🛡️', style: TextStyle(fontSize: 16)),
                      SizedBox(width: 6),
                      Text(
                        'Admin Login',
                        style: TextStyle(
                          color: LoginConfig.subtitleColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// Simple placeholder page shown when someone taps "Admin Login".
/// Solid black background with a centered "coming soon" message.
class AdminComingSoonScreen extends StatelessWidget {
  const AdminComingSoonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Admin features coming soon!',
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

/// Same reusable text field used on the signup screen: rounded border,
/// a leading icon, and an optional trailing widget (used for the
/// password show/hide eye icon).
class _AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final Widget? trailing;
  final TextInputType? keyboardType;

  const _AppTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.trailing,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: LoginConfig.fieldHeight,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: LoginConfig.fieldFontSize),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: LoginConfig.hintColor),
          prefixIcon: Icon(icon, color: LoginConfig.hintColor),
          suffixIcon: trailing,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(LoginConfig.fieldRadius),
            borderSide: const BorderSide(color: LoginConfig.fieldBorderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(LoginConfig.fieldRadius),
            borderSide: const BorderSide(color: LoginConfig.fieldBorderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(LoginConfig.fieldRadius),
            borderSide: const BorderSide(color: LoginConfig.primaryColor, width: 1.5),
          ),
        ),
      ),
    );
  }
}