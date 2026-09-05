import 'dart:ui';
import 'package:flutter/material.dart';
import 'splash_screen.dart'; // reused for SplashConfig color palette
import 'login_screen.dart';
import 'signup_screen.dart';

/// ============================================================
/// WELCOME SCREEN CONFIG
/// ------------------------------------------------------------
/// All sizes, colors, spacing, wording, and timings live here.
/// Tweak anything below — the widget code never needs touching.
/// ============================================================
class WelcomeConfig {
  // ---- Asset paths ----
  static const String iconAsset = 'assets/images/icon.png';
  static const String bgAsset = 'assets/images/bg_blur.png';

  // ---- Colors (reusing the same palette as the splash screen) ----
  static const Color brandNavy = SplashConfig.neighborColor; // "Neighbor"
  static const Color brandGreen = SplashConfig.nestColor; // "Nest"
  static const Color primaryButtonColor = SplashConfig.colorBlue;
  static const Color subtitleColor = Color(0xFF64748B);
  static const Color eyebrowColor = Color(0xFF334155);

  // ---- Wording (edit freely) ----
  static const String eyebrowText = 'Welcome to';
  static const String brandPart1 = 'Neighbor'; // navy
  static const String brandPart2 = 'Nest'; // green
  static const String taglineLine =
      'Connecting neighbors. Helping each other.\nGrowing stronger communities together.';
  static const String primaryButtonText = 'Get Started';
  static const String secondaryButtonText = 'I already have an account';

  // ---- Sizes ----
  // Icon size — this is the one to bump up if you want it bigger/smaller.
  static const double iconSize = 180;
  static const double eyebrowFontSize = 18; // "Welcome to"
  static const double brandFontSize = 38; // "NeighborNest"
  static const double taglineFontSize = 15.5; // "Connecting neighbors..." lines
  static const double buttonHeight = 56;
  static const double buttonRadius = 30;
  static const double buttonFontSize = 17; // "Get Started" / "I already have an account"

  // ---- Spacing ----
  static const double iconTopSpacing = 0.14; // fraction of screen height
  static const double gapIconToEyebrow = 30;
  static const double gapEyebrowToBrand = 4;
  static const double gapBrandToTagline = 16;
  static const double horizontalPadding = 28;
  static const double gapBetweenButtons = 14;
  static const double bottomPadding = 48;

  // ---- Hover / press feedback ----
  static const double hoverScale = 1.04; // desktop/web mouse-over
  static const double pressScale = 0.96; // mobile tap-down feedback
  static const Duration hoverPressDuration = Duration(milliseconds: 150);

  // ---- Animation timings ----
  static const Duration startDelay = Duration(milliseconds: 200);

  // Icon reveal: rises from below into place (bottom -> top) while
  // blurring from soft to sharp and fading in. Increase iconRevealDuration
  // for a slower/more gradual rise; increase iconRiseDistance to make it
  // travel further (start lower) before settling.
  static const Duration iconRevealDuration = Duration(milliseconds: 1600);
  static const Curve iconRevealCurve = Curves.easeOutQuint; // slow, smooth finish
  static const double iconBlurStart = 22;
  static const double iconScaleStart = 1.12;
  static const double iconRiseDistance = 130; // px it travels upward into place

  // Heading (eyebrow + brand name) fade/slide up.
  static const Duration textRevealDuration = Duration(milliseconds: 700);

  // Tagline fades slightly after the heading (staggered within the same
  // controller via Interval — see build()).
  static const double taglineStaggerStart = 0.35;

  // Buttons fade/slide up, primary button slightly before secondary.
  static const Duration buttonsRevealDuration = Duration(milliseconds: 650);
  static const double secondaryButtonStagger = 0.3;
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin {
  late final AnimationController _iconController;
  late final AnimationController _textController;
  late final AnimationController _buttonsController;

  @override
  void initState() {
    super.initState();

    _iconController = AnimationController(vsync: this, duration: WelcomeConfig.iconRevealDuration);
    _textController = AnimationController(vsync: this, duration: WelcomeConfig.textRevealDuration);
    _buttonsController = AnimationController(vsync: this, duration: WelcomeConfig.buttonsRevealDuration);

    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(WelcomeConfig.startDelay);
    if (!mounted) return;
    await _iconController.forward();

    if (!mounted) return;
    await _textController.forward();

    if (!mounted) return;
    await _buttonsController.forward();
  }

  @override
  void dispose() {
    _iconController.dispose();
    _textController.dispose();
    _buttonsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage(WelcomeConfig.bgAsset), fit: BoxFit.cover),
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: screenHeight * WelcomeConfig.iconTopSpacing),

              // ---- Step 1: icon blurs into focus ----
              _BlurInIcon(controller: _iconController),

              SizedBox(height: WelcomeConfig.gapIconToEyebrow),

              // ---- Step 2: heading + tagline fade/slide up ----
              _RevealText(controller: _textController),

              const Spacer(),

              // ---- Step 3: buttons fade/slide up ----
              Padding(
                padding: EdgeInsets.fromLTRB(
                  WelcomeConfig.horizontalPadding,
                  0,
                  WelcomeConfig.horizontalPadding,
                  WelcomeConfig.bottomPadding,
                ),
                child: _RevealButtons(controller: _buttonsController),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ---------------- Icon: blur -> sharp, fade in, settle into place ----------------
class _BlurInIcon extends StatelessWidget {
  final AnimationController controller;
  const _BlurInIcon({required this.controller});

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: controller, curve: WelcomeConfig.iconRevealCurve);

    return AnimatedBuilder(
      animation: curved,
      builder: (context, child) {
        final t = curved.value; // 0 -> 1
        final blurSigma = WelcomeConfig.iconBlurStart * (1 - t);
        final scale = WelcomeConfig.iconScaleStart - (WelcomeConfig.iconScaleStart - 1.0) * t;
        // Positive dy = below its final spot. Starts low, rises to 0 (bottom -> top).
        final dy = WelcomeConfig.iconRiseDistance * (1 - t);

        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, dy),
            child: Transform.scale(
              scale: scale,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                child: child,
              ),
            ),
          ),
        );
      },
      child: Image.asset(
        WelcomeConfig.iconAsset,
        width: WelcomeConfig.iconSize,
        height: WelcomeConfig.iconSize,
      ),
    );
  }
}

/// ---------------- Heading + tagline: staggered fade + slide up ----------------
class _RevealText extends StatelessWidget {
  final AnimationController controller;
  const _RevealText({required this.controller});

  @override
  Widget build(BuildContext context) {
    final headingAnim = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.0, 0.75, curve: Curves.easeOut),
    );
    final taglineAnim = CurvedAnimation(
      parent: controller,
      curve: Interval(WelcomeConfig.taglineStaggerStart, 1.0, curve: Curves.easeOut),
    );

    return Column(
      children: [
        _FadeSlideUp(
          animation: headingAnim,
          child: Column(
            children: [
              Text(
                WelcomeConfig.eyebrowText,
                style: TextStyle(
                  fontSize: WelcomeConfig.eyebrowFontSize,
                  color: WelcomeConfig.eyebrowColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: WelcomeConfig.gapEyebrowToBrand),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: WelcomeConfig.brandFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  children: const [
                    TextSpan(text: WelcomeConfig.brandPart1, style: TextStyle(color: WelcomeConfig.brandNavy)),
                    TextSpan(text: WelcomeConfig.brandPart2, style: TextStyle(color: WelcomeConfig.brandGreen)),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: WelcomeConfig.gapBrandToTagline),
        _FadeSlideUp(
          animation: taglineAnim,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: WelcomeConfig.horizontalPadding),
            child: Text(
              WelcomeConfig.taglineLine,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: WelcomeConfig.taglineFontSize,
                color: WelcomeConfig.subtitleColor,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FadeSlideUp extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  const _FadeSlideUp({required this.animation, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, c) {
        return Opacity(
          opacity: animation.value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - animation.value)),
            child: c,
          ),
        );
      },
      child: child,
    );
  }
}

/// ---------------- Buttons: staggered fade + slide up ----------------
class _RevealButtons extends StatelessWidget {
  final AnimationController controller;
  const _RevealButtons({required this.controller});

  @override
  Widget build(BuildContext context) {
    final primaryAnim = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );
    final secondaryAnim = CurvedAnimation(
      parent: controller,
      curve: Interval(WelcomeConfig.secondaryButtonStagger, 1.0, curve: Curves.easeOut),
    );

    return Column(
      children: [
        _FadeSlideUp(
          animation: primaryAnim,
          child: HoverScaleButton(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SignupScreen()));
            },
            child: Container(
              width: double.infinity,
              height: WelcomeConfig.buttonHeight,
              decoration: BoxDecoration(
                color: WelcomeConfig.primaryButtonColor,
                borderRadius: BorderRadius.circular(WelcomeConfig.buttonRadius),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    WelcomeConfig.primaryButtonText,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: WelcomeConfig.buttonFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: WelcomeConfig.gapBetweenButtons),
        _FadeSlideUp(
          animation: secondaryAnim,
          child: HoverScaleButton(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
            child: Container(
              width: double.infinity,
              height: WelcomeConfig.buttonHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(WelcomeConfig.buttonRadius),
                border: Border.all(color: WelcomeConfig.primaryButtonColor, width: 1.4),
              ),
              alignment: Alignment.center,
              child: Text(
                WelcomeConfig.secondaryButtonText,
                style: TextStyle(
                  color: WelcomeConfig.primaryButtonColor,
                  fontSize: WelcomeConfig.buttonFontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A button wrapper that grows slightly on mouse hover (desktop/web) and
/// shrinks slightly on tap-down (mobile touch feedback), then calls [onTap].
/// Public so other screens (e.g. the signup screen) can reuse it too.
class HoverScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const HoverScaleButton({super.key, required this.child, required this.onTap});

  @override
  State<HoverScaleButton> createState() => _HoverScaleButtonState();
}

class _HoverScaleButtonState extends State<HoverScaleButton> {
  double _scale = 1.0;

  void _setScale(double value) => setState(() => _scale = value);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _setScale(WelcomeConfig.hoverScale),
      onExit: (_) => _setScale(1.0),
      child: GestureDetector(
        onTapDown: (_) => _setScale(WelcomeConfig.pressScale),
        onTapCancel: () => _setScale(1.0),
        onTapUp: (_) {
          _setScale(1.0);
          widget.onTap();
        },
        child: AnimatedScale(
          scale: _scale,
          duration: WelcomeConfig.hoverPressDuration,
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}