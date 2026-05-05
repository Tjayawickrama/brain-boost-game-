import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/mock_api_service.dart';
import 'services/storage_service.dart';
import 'providers/auth_provider.dart';
import 'providers/game_provider.dart';
import 'providers/profile_provider.dart';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/games/memory_game_screen.dart';
import 'screens/games/puzzle_game_screen.dart';
import 'screens/games/speed_tap_screen.dart';
import 'screens/daily_challenge_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  // Init storage
  final storage = StorageService();
  await storage.init();

  final api = MockApiService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(storage)),
        ChangeNotifierProvider(create: (_) => GameProvider(api)),
        ChangeNotifierProvider(create: (_) => ProfileProvider(api, storage)),
      ],
      child: const BrainBoostApp(),
    ),
  );
}

class BrainBoostApp extends StatelessWidget {
  const BrainBoostApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Brain Boost',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      home: const _SplashGate(),
      routes: {
        '/home': (_) => const MainNavScreen(),
        '/login': (_) => const LoginScreen(),
        '/daily-challenge': (_) => const DailyChallengeScreen(),
        '/leaderboard': (_) => const LeaderboardScreen(),
        '/memory': (_) => const MemoryGameScreen(),
        '/puzzle': (_) => const PuzzleGameScreen(),
        '/speed-tap': (_) => const SpeedTapScreen(),
      },
    );
  }
}

/// Shows splash, then routes to Login or Home based on auth state.
class _SplashGate extends StatefulWidget {
  const _SplashGate();
  @override
  State<_SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<_SplashGate> {
  void _onSplashFinished() {
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    final nextRoute = auth.isLoggedIn ? '/home' : '/login';
    Navigator.of(context).pushReplacementNamed(nextRoute);
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen(onFinished: _onSplashFinished);
  }
}

// ── Bottom tab navigation shell ───────────────────────────────────────────────
class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});
  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _index = 0;

  final _pages = const [
    HomeScreen(),
    _GamesHubScreen(),
    DailyChallengeScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: _AppBottomNav(
        index: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

// ── Games hub tab ─────────────────────────────────────────────────────────────
class _GamesHubScreen extends StatelessWidget {
  const _GamesHubScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFA),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Builder(builder: (context) {
                final width = MediaQuery.of(context).size.width;
                final height = width * 0.42;
                return Container(
                  width: width,
                  height: height,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.purple],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                  ),
                  child: Stack(children: [
                    Positioned(
                      right: 0,
                      bottom: 0,
                      top: 0,
                      child: Image.asset(
                        'assets/images/games_header.png',
                        width: width * 0.6,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          SizedBox(height: 12),
                          Text('Ready to play?',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              )),
                          SizedBox(height: 8),
                          Text('Choose a game and sharpen your mind.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              )),
                        ],
                      ),
                    ),
                  ]),
                );
              }),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _GameCard(
                    title: 'Memory Match',
                    subtitle: 'Flip cards and match pairs',
                    icon: Icons.grid_view_rounded,
                    color: AppColors.primary,
                    badge: 'POPULAR',
                    detail: '16 cards · 60s',
                    onTap: () => Navigator.push(context,
                        _slide(const MemoryGameScreen())),
                  ),
                  const SizedBox(height: 14),
                  _GameCard(
                    title: 'Sliding Puzzle',
                    subtitle: 'Arrange tiles in correct order',
                    icon: Icons.extension_rounded,
                    color: AppColors.purple,
                    detail: '3×3 grid',
                    onTap: () => Navigator.push(context,
                        _slide(const PuzzleGameScreen())),
                  ),
                  const SizedBox(height: 14),
                  _GameCard(
                    title: 'Speed Tap',
                    subtitle: 'Tap circles before they vanish',
                    icon: Icons.touch_app_rounded,
                    color: AppColors.orange,
                    badge: 'FAST',
                    detail: '30 seconds',
                    onTap: () => Navigator.push(context,
                        _slide(const SpeedTapScreen())),
                  ),
                  const SizedBox(height: 24),
                  // Stats hint
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryFaint,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Row(children: [
                      const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Complete games to earn XP and unlock achievements!',
                          style: TextStyle(fontSize: 13, color: AppColors.textMedium),
                        ),
                      ),
                    ]),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PageRoute _slide(Widget page) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: const Duration(milliseconds: 350),
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
      );
}

class _GameCard extends StatefulWidget {
  final String title, subtitle, detail;
  final String? badge;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _GameCard({
    required this.title, required this.subtitle, required this.detail,
    required this.icon, required this.color, required this.onTap, this.badge,
  });
  @override
  State<_GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<_GameCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100),
        lowerBound: 0.96, upperBound: 1.0)..value = 1.0;
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) { _ctrl.forward(); widget.onTap(); },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _ctrl,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: widget.color.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 6))],
            border: Border.all(color: widget.color.withOpacity(0.12)),
          ),
          child: Row(children: [
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [widget.color, Color.lerp(widget.color, Colors.black, 0.2)!],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: widget.color.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Icon(widget.icon, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(widget.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  if (widget.badge != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: widget.color.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                      child: Text(widget.badge!, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: widget.color)),
                    ),
                  ],
                ]),
                const SizedBox(height: 2),
                Text(widget.subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.08), borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(widget.detail, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: widget.color)),
                ),
              ]),
            ),
            Icon(Icons.chevron_right_rounded, color: widget.color, size: 24),
          ]),
        ),
      ),
    );
  }
}

// ── Bottom navigation bar ─────────────────────────────────────────────────────
class _AppBottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const _AppBottomNav({required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.home_rounded, Icons.home_outlined, 'Home'),
      (Icons.grid_view_rounded, Icons.grid_view_outlined, 'Games'),
      (Icons.emoji_events_rounded, Icons.emoji_events_outlined, 'Challenge'),
      (Icons.person_rounded, Icons.person_outline_rounded, 'Profile'),
    ];

    return Container(
      height: 72 + MediaQuery.of(context).padding.bottom,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 20, offset: const Offset(0, -4))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final on = i == index;
          return GestureDetector(
            onTap: () => onTap(i),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 72,
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: on ? AppColors.primaryLight : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      on ? items[i].$1 : items[i].$2,
                      key: ValueKey(on),
                      color: on ? AppColors.primary : Colors.grey[400],
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(items[i].$3,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: on ? FontWeight.w600 : FontWeight.w400,
                        color: on ? AppColors.primary : Colors.grey[400])),
              ]),
            ),
          );
        }),
      ),
    );
  }
}
