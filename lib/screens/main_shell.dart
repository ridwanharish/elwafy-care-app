import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../state/elwafy_store.dart';
import '../theme/elwafy_theme.dart';
import 'admin_dashboard_screen.dart';
import 'customer_flow_screen.dart';
import 'mitra_portal_screen.dart';

class MainShell extends StatefulWidget {
  final ElwafyStore store;
  final bool showSplash;

  const MainShell({super.key, required this.store, this.showSplash = true});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late bool _showSplash;
  Timer? _splashTimer;

  @override
  void initState() {
    super.initState();
    _showSplash = widget.showSplash;

    if (_showSplash) {
      _splashTimer = Timer(const Duration(milliseconds: 2100), () {
        if (mounted) {
          setState(() => _showSplash = false);
        }
      });
    }
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final activeRolePortal = widget.store.activePortalTab;

        Widget activeApp;
        if (_showSplash) {
          activeApp = _ElwafyAnimatedSplashScreen(
            onSkip: () => setState(() => _showSplash = false),
          );
        } else if (activeRolePortal == 1) {
          activeApp = AdminDashboardScreen(store: widget.store);
        } else if (activeRolePortal == 2) {
          activeApp = MitraPortalScreen(store: widget.store);
        } else {
          activeApp = CustomerFlowScreen(store: widget.store);
        }

        final switcher = AnimatedSwitcher(
          duration: const Duration(milliseconds: 520),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: KeyedSubtree(
            key: ValueKey<String>(
              _showSplash ? 'splash' : 'portal-$activeRolePortal',
            ),
            child: activeApp,
          ),
        );

        // Bingkai Responsif Mobile-First:
        // Di HP tampil penuh 100%, di layar lebar (Web/Windows) terpusat ukuran layar HP (max 460px)
        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth <= 500) {
              return switcher;
            }
            return Container(
              color: const Color(0xFFDCE8F7),
              alignment: Alignment.center,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 450),
                decoration: BoxDecoration(
                  color: ElwafyColors.babyBlueBg,
                  boxShadow: [
                    BoxShadow(
                      color: ElwafyColors.navyDark.withValues(alpha: 0.18),
                      blurRadius: 28,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRect(child: switcher),
              ),
            );
          },
        );
      },
    );
  }
}

/// SPLASH SCREEN ANIMASI HALUS & MODERN ELWAFY CARE
class _ElwafyAnimatedSplashScreen extends StatefulWidget {
  final VoidCallback onSkip;

  const _ElwafyAnimatedSplashScreen({required this.onSkip});

  @override
  State<_ElwafyAnimatedSplashScreen> createState() =>
      _ElwafyAnimatedSplashScreenState();
}

class _ElwafyAnimatedSplashScreenState
    extends State<_ElwafyAnimatedSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideTextAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _scaleAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
    );
    _fadeAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.15, 0.85, curve: Curves.easeIn),
    );
    _slideTextAnim =
        Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _ctrl,
            curve: const Interval(0.25, 0.9, curve: Curves.easeOutCubic),
          ),
        );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF0A58CA),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: GestureDetector(
          onTap: widget.onSkip,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF073B8A),
                  Color(0xFF0A58CA),
                  Color(0xFF00A8FF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Ornamen Lingkaran Cahaya Lembut di Latar Belakang
                Positioned(
                  top: -90,
                  right: -70,
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.07),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -110,
                  left: -80,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                ),

                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 24,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(flex: 3),

                        // Logo Resmi Elwafy dengan Animasi Scale + Glow Ring
                        ScaleTransition(
                          scale: _scaleAnim,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.22),
                                  blurRadius: 28,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: const ElwafyLogo(size: 122),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Judul & Tagline dengan Animasi Slide + Fade
                        FadeTransition(
                          opacity: _fadeAnim,
                          child: SlideTransition(
                            position: _slideTextAnim,
                            child: Column(
                              children: [
                                const Text(
                                  'Elwafy Care',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.16),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'Mom, Kids and Baby Spa • by Bidan Elfi',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Layanan Homecare ke Rumah & Outlet Resmi\nJl. Sei Mencirim, Kec. Sunggal',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontSize: 12,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const Spacer(flex: 3),

                        // Indikator Loading Halus di Bawah
                        FadeTransition(
                          opacity: _fadeAnim,
                          child: Column(
                            children: [
                              SizedBox(
                                width: 140,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    minHeight: 4,
                                    backgroundColor: Colors.white.withValues(
                                      alpha: 0.22,
                                    ),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Menyiapkan layanan terbaik untuk Bunda & Buah Hati...',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
