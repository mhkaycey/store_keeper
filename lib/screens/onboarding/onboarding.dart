import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store_keeper/screens/home/home_page.dart';

class OnboardingScreen extends StatefulWidget {
  final bool isDarkMode;
  final Function() toggleTheme;
  const OnboardingScreen({
    super.key,
    required this.isDarkMode,
    required this.toggleTheme,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Start the animation when screen loads
    _controller.forward();
  }

  final image = [
    'assets/images/onboarding.png',
    'assets/images/onboarding1.jpg',
    'assets/images/onboarding2.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Image collage background
          Positioned.fill(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,

              children: [
                Expanded(
                  child: Image.asset(
                    image[0],
                    fit: BoxFit.cover,
                    height: double.infinity,
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(child: Image.asset(image[1], fit: BoxFit.cover)),
                      Expanded(child: Image.asset(image[2], fit: BoxFit.cover)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                        Colors.black.withValues(alpha: 0.95),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      spacing: 12,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Welcome, Manager!",
                          textAlign: TextAlign.center,
                          style: ShadTheme.of(context).textTheme.h2.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                offset: const Offset(2, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),

                        Text(
                          "Track inventory, manage sales, and grow your business with ease.",
                          textAlign: TextAlign.center,
                          style: ShadTheme.of(
                            context,
                          ).textTheme.p.copyWith(color: Colors.white70),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ShadButton(
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HomePage(
                                    themeToggle: widget.toggleTheme,
                                    isDarkMode: widget.isDarkMode,
                                  ),
                                ),
                                (route) => false,
                              );
                            },
                            size: ShadButtonSize.lg,
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            child: Text(
                              "Get Started",
                              style: ShadTheme.of(context).textTheme.large
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
