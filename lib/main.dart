// ============================================================
// lib/main.dart
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/tabs/home_tab.dart';
import 'screens/tabs/matching_tab.dart';
import 'screens/tabs/message_tab.dart';
import 'screens/tabs/myPage_tab.dart';
import 'utils/colors.dart';
import 'utils/routes.dart';

void main() async {
  // Flutter 엔진 초기화 (async main 사용 시 필수)
  WidgetsFlutterBinding.ensureInitialized();

  // 네이버 지도 SDK 초기화
  if (!kIsWeb) {
    await NaverMapSdk.instance.initialize(
      clientId: 'f61sxzdmej',
      onAuthFailed: (error) {
        debugPrint('네이버 지도 인증 실패: $error');
      },
    );
  }

  runApp(const TaxiMateApp());
}

class TaxiMateApp extends StatelessWidget {
  const TaxiMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaxiMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: Colors.white,
          onPrimary: Colors.white,
          onSurface: AppColors.secondary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.secondary,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        scaffoldBackgroundColor: AppColors.bg,
        cardTheme: CardThemeData(
          color: Colors.white, elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border),
          ),
        ),
      ),
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.login:  (_) => const LoginScreen(),
        AppRoutes.signup: (_) => const SignupScreen(),
        AppRoutes.main:   (_) => const MainScreen(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  List<Widget> get _screens => [
    HomeTab(onTabChange: (i) => setState(() => _selectedIndex = i)),
    const MatchingTab(),
    const MessageTab(),
    const MyPageTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.gray,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        elevation: 12,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined),        activeIcon: Icon(Icons.home),        label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.location_on_outlined), activeIcon: Icon(Icons.location_on), label: '매칭'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline),  activeIcon: Icon(Icons.chat_bubble), label: '채팅'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline),       activeIcon: Icon(Icons.person),      label: '내정보'),
        ],
      ),
    );
  }
}