import 'package:flutter/material.dart';

/// ============================================================
/// SPLASH SCREEN CONFIG
/// ------------------------------------------------------------
/// Every size, color, spacing, and timing value used by the
/// splash screen lives here. Tweak anything in this class and
/// the whole screen updates — you never need to touch the
/// widget code below just to resize/recolor/retime something.
/// ============================================================
class SplashConfig {
  // ---- Asset paths ----
  // Put the two files here: assets/images/icon.png and assets/images/bg.png
  static const String iconAsset = 'assets/images/icon.png';
  static const String bgAsset = 'assets/images/bg.png';

  // ---- Colors (from your palette) ----
  static const Color colorBlue = Color(0xFF2563EB);
  static const Color colorGreen = Color(0xFF22C55E);
  static const Color colorOrange = Color(0xFFF59E0B);
  static const Color colorRed = Color(0xFFEF4444);
  static const Color colorLight = Color(0xFFF1F5F9);
  static const Color colorNavy = Color(0xFF1E293B);

  // "Neighbor" = same color as sample's "Community" (navy)
  static const Color neighborColor = colorNavy;
  // "Nest" = same color as sample's "Connect" (green)
  static const Color nestColor = colorGreen;

  // Tagline separator dots -> first two palette colors
  static const Color taglineDot1Color = colorBlue;
  static const Color taglineDot2Color = colorGreen;

  // Bottom loading dots -> first three palette colors
  static const List<Color> loadingDotColors = [colorBlue, colorGreen, colorOrange];

  static const Color taglineTextColor = Color(0xFF64748B); // soft gray-navy
  static const Color connectingTextColor = Color(0xFF475569);

  // ---- Sizes ----
  static const double iconSize = 200 ;
  static const double appNameFontSize = 34;
  static const double taglineFontSize = 17;
  static const double taglineDotSize = 6;
  static const double loadingDotSize = 10;
  static const double connectingTextFontSize = 15;

  // ---- Spacing / positions (tweak to nudge things up/down) ----
  static const double iconTopSpacing = 0.16; // fraction of screen height above icon
  static const double gapIconToName = 28;
  static const double gapNameToTagline = 10;
  static const double bottomSectionOffset = 90; // distance of dots/text from bottom

  // ---- Animation durations ----
  static const Duration iconPopDelay = Duration(milliseconds: 150);
  static const Duration iconPopDuration = Duration(milliseconds: 800);

  static const Duration textFadeDuration = Duration(milliseconds: 650);

  static const Duration loadingFadeDuration = Duration(milliseconds: 500);
  static const Duration dotPulseCycleDuration = Duration(milliseconds: 550);
  static const Duration dotPulseStagger = Duration(milliseconds: 160);

  // How long the "Connecting our community..." stage stays on screen
  // before the reveal transition starts.
  static const Duration holdBeforeReveal = Duration(milliseconds: 3500);

  // The "splash slides up and reveals home screen" transition.
  static const Duration revealDuration = Duration(milliseconds: 750);
  static const Curve revealCurve = Curves.easeInOutCubic;
}

class SplashScreen extends StatefulWidget {
  /// Pass the widget that should be revealed underneath the splash.
  final Widget homeScreen;

  const SplashScreen({super.key, required this.homeScreen});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _iconController;
  late final Animation<double> _iconScale;

  late final AnimationController _textController; // app name + tagline fade
  late final Animation<double> _textFade;

  late final AnimationController _loadingController; // dots row + "Connecting..." fade
  late final Animation<double> _loadingFade;

  late final AnimationController _dotsPulseController; // repeating blink for the 3 dots

  late final AnimationController _revealController; // final slide-up transition
  late final Animation<double> _revealOffset;

  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _iconController = AnimationController(vsync: this, duration: SplashConfig.iconPopDuration);
    _iconScale = CurvedAnimation(parent: _iconController, curve: Curves.elasticOut);

    _textController = AnimationController(vsync: this, duration: SplashConfig.textFadeDuration);
    _textFade = CurvedAnimation(parent: _textController, curve: Curves.easeOut);

    _loadingController = AnimationController(vsync: this, duration: SplashConfig.loadingFadeDuration);
    _loadingFade = CurvedAnimation(parent: _loadingController, curve: Curves.easeOut);

    _dotsPulseController = AnimationController(
      vsync: this,
      duration: SplashConfig.dotPulseCycleDuration,
    )..repeat(reverse: true);

    _revealController = AnimationController(vsync: this, duration: SplashConfig.revealDuration);
    _revealOffset = CurvedAnimation(parent: _revealController, curve: SplashConfig.revealCurve);

    _runSequence();
  }

  /// Step-by-step timeline:
  /// 1) icon pops in
  /// 2) app name + tagline fade in
  /// 3) loading dots + "Connecting our community..." fade in and pulse
  /// 4) after a hold, the whole splash slides up revealing the home screen
  Future<void> _runSequence() async {
    await Future.delayed(SplashConfig.iconPopDelay);
    if (!mounted) return;
    await _iconController.forward();

    if (!mounted) return;
    await _textController.forward();

    if (!mounted) return;
    await _loadingController.forward();

    if (!mounted) return;
    await Future.delayed(SplashConfig.holdBeforeReveal);

    if (!mounted) return;
    await _revealController.forward();

    _goToHome();
  }

  void _goToHome() {
    if (_navigated || !mounted) return;
    _navigated = true;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (_, _, _) => widget.homeScreen,
      ),
    );
  }

  @override
  void dispose() {
    _iconController.dispose();
    _textController.dispose();
    _loadingController.dispose();
    _dotsPulseController.dispose();
    _revealController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: SplashConfig.colorLight,
      body: Stack(
        children: [
          // The real home screen sits underneath the whole time. Once the
          // splash slides up (step 4) it's revealed.
          widget.homeScreen,

          // Splash overlay: everything below animates as one unit sliding
          // upward off the screen for the final reveal.
          AnimatedBuilder(
            animation: _revealOffset,
            builder: (context, child) {
              final dy = -screenHeight * _revealOffset.value;
              return Transform.translate(offset: Offset(0, dy), child: child);
            },
            child: _SplashContent(
              iconScale: _iconScale,
              textFade: _textFade,
              loadingFade: _loadingFade,
              dotsPulseController: _dotsPulseController,
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashContent extends StatelessWidget {
  final Animation<double> iconScale;
  final Animation<double> textFade;
  final Animation<double> loadingFade;
  final AnimationController dotsPulseController;

  const _SplashContent({
    required this.iconScale,
    required this.textFade,
    required this.loadingFade,
    required this.dotsPulseController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: SplashConfig.colorLight,
        image: DecorationImage(
          image: AssetImage(SplashConfig.bgAsset),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * SplashConfig.iconTopSpacing),

            // ---- Step 1: icon pop ----
            ScaleTransition(
              scale: iconScale,
              child: Image.asset(
                SplashConfig.iconAsset,
                width: SplashConfig.iconSize,
                height: SplashConfig.iconSize,
              ),
            ),

            SizedBox(height: SplashConfig.gapIconToName),

            // ---- Step 2: app name + tagline fade in ----
            FadeTransition(
              opacity: textFade,
              child: Column(
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: SplashConfig.appNameFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      children: const [
                        TextSpan(text: 'Neighbor', style: TextStyle(color: SplashConfig.neighborColor)),
                        TextSpan(text: 'Nest', style: TextStyle(color: SplashConfig.nestColor)),
                      ],
                    ),
                  ),
                  SizedBox(height: SplashConfig.gapNameToTagline),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Connect',
                        style: TextStyle(
                          fontSize: SplashConfig.taglineFontSize,
                          color: SplashConfig.taglineTextColor,
                        ),
                      ),
                      _TaglineDot(color: SplashConfig.taglineDot1Color),
                      Text(
                        'Help',
                        style: TextStyle(
                          fontSize: SplashConfig.taglineFontSize,
                          color: SplashConfig.taglineTextColor,
                        ),
                      ),
                      _TaglineDot(color: SplashConfig.taglineDot2Color),
                      Text(
                        'Grow',
                        style: TextStyle(
                          fontSize: SplashConfig.taglineFontSize,
                          color: SplashConfig.taglineTextColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(),

            // ---- Step 3: loading dots + "Connecting our community..." ----
            FadeTransition(
              opacity: loadingFade,
              child: Padding(
                padding: EdgeInsets.only(bottom: SplashConfig.bottomSectionOffset),
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(SplashConfig.loadingDotColors.length, (i) {
                        return _PulsingDot(
                          controller: dotsPulseController,
                          color: SplashConfig.loadingDotColors[i],
                          // stagger each dot's phase so they blink in sequence
                          delayFraction: (SplashConfig.dotPulseStagger.inMilliseconds *
                              i /
                              SplashConfig.dotPulseCycleDuration.inMilliseconds)
                              .clamp(0.0, 0.9),
                        );
                      }),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Connecting our community...',
                      style: TextStyle(
                        fontSize: SplashConfig.connectingTextFontSize,
                        color: SplashConfig.connectingTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaglineDot extends StatelessWidget {
  final Color color;
  const _TaglineDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        width: SplashConfig.taglineDotSize,
        height: SplashConfig.taglineDotSize,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

class _PulsingDot extends StatelessWidget {
  final AnimationController controller;
  final Color color;
  final double delayFraction; // 0.0 - 1.0, offsets this dot's phase in the cycle

  const _PulsingDot({
    required this.controller,
    required this.color,
    this.delayFraction = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: controller,
      curve: Interval(delayFraction, 1.0, curve: Curves.easeInOut),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: AnimatedBuilder(
        animation: curved,
        builder: (context, child) {
          // fades between 35% and 100% opacity to create the "blink"
          final opacity = 0.35 + (0.65 * curved.value);
          return Opacity(
            opacity: opacity,
            child: Container(
              width: SplashConfig.loadingDotSize,
              height: SplashConfig.loadingDotSize,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          );
        },
      ),
    );
  }
}