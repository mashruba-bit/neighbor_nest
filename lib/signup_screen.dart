import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'splash_screen.dart'; // for the shared color palette (SplashConfig)
import 'welcome_screen.dart'; // for the shared HoverScaleButton
import 'login_screen.dart';

/// ============================================================
/// SIGN UP SCREEN CONFIG
/// ------------------------------------------------------------
/// Sizes, colors, and text live here so they're easy to tweak
/// without touching the widget code below.
/// ============================================================
class SignupConfig {
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

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // This is the whole signup flow. Straightforward top-to-bottom:
  // 1) check the fields locally, 2) ask Firebase to create the account,
  // 3) save the full name on that account, 4) handle any error simply.
  Future<void> _signUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showMessage('Please fill in all fields.');
      return;
    }
    if (password != confirmPassword) {
      _showMessage('Passwords do not match.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName(name);

      if (!mounted) return;
      _showMessage('Account created! Welcome, $name.');
      // TODO: once you have a home/dashboard screen, navigate there instead.
    } on FirebaseAuthException catch (e) {
      _showMessage(e.message ?? 'Sign up failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SplashConfig.colorLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: SignupConfig.horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // Back arrow
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back, color: SignupConfig.brandNavy),
              ),

              // Icon — no animation here, just the plain image.
              Center(
                child: Image.asset(
                  SignupConfig.iconAsset,
                  width: SignupConfig.iconSize,
                  height: SignupConfig.iconSize,
                ),
              ),
              const SizedBox(height: 16),

              // Brand name, same two-color style as the splash/welcome screens.
              Center(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: SignupConfig.brandFontSize, fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(text: 'Neighbor', style: TextStyle(color: SignupConfig.brandNavy)),
                      TextSpan(text: 'Nest', style: TextStyle(color: SignupConfig.brandGreen)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Create your account',
                  style: TextStyle(fontSize: SignupConfig.subtitleFontSize, color: SignupConfig.subtitleColor),
                ),
              ),
              const SizedBox(height: 32),

              _AppTextField(
                controller: _nameController,
                hint: 'Full Name',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: SignupConfig.gapBetweenFields),

              _AppTextField(
                controller: _emailController,
                hint: 'Email',
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: SignupConfig.gapBetweenFields),

              _AppTextField(
                controller: _passwordController,
                hint: 'Password',
                icon: Icons.lock_outline,
                obscureText: _obscurePassword,
                trailing: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  color: SignupConfig.hintColor,
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: SignupConfig.gapBetweenFields),

              _AppTextField(
                controller: _confirmController,
                hint: 'Confirm Password',
                icon: Icons.lock_outline,
                obscureText: _obscureConfirm,
                trailing: IconButton(
                  icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  color: SignupConfig.hintColor,
                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              const SizedBox(height: 28),

              // Sign Up button — same hover/press "grow slightly" feedback
              // as the Welcome screen buttons.
              HoverScaleButton(
                onTap: _isLoading ? () {} : _signUp,
                child: Container(
                  width: double.infinity,
                  height: SignupConfig.buttonHeight,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: SignupConfig.primaryColor,
                    borderRadius: BorderRadius.circular(SignupConfig.buttonRadius),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                      : Text(
                    'Sign Up',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: SignupConfig.buttonFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              Center(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 15, color: SignupConfig.subtitleColor),
                    children: [
                      const TextSpan(text: 'Already have an account? '),
                      TextSpan(
                        text: 'Sign In',
                        style: const TextStyle(color: SignupConfig.primaryColor, fontWeight: FontWeight.w600),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
                          },
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

/// One reusable text field styled to match the design: rounded border,
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
      height: SignupConfig.fieldHeight,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: SignupConfig.fieldFontSize),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: SignupConfig.hintColor),
          prefixIcon: Icon(icon, color: SignupConfig.hintColor),
          suffixIcon: trailing,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SignupConfig.fieldRadius),
            borderSide: const BorderSide(color: SignupConfig.fieldBorderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SignupConfig.fieldRadius),
            borderSide: const BorderSide(color: SignupConfig.fieldBorderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SignupConfig.fieldRadius),
            borderSide: const BorderSide(color: SignupConfig.primaryColor, width: 1.5),
          ),
        ),
      ),
    );
  }
}