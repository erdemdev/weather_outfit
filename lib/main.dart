import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  await NotificationService.init();
  await NotificationService.requestPermission();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const WeatherOutfitApp(),
    ),
  );
}

class WeatherOutfitApp extends StatefulWidget {
  const WeatherOutfitApp({super.key});

  @override
  State<WeatherOutfitApp> createState() => _WeatherOutfitAppState();
}

class _WeatherOutfitAppState extends State<WeatherOutfitApp> {
  bool _showSplash = true;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return AnimatedTheme(
      data: provider.isDark
          ? ThemeData(
              fontFamily: 'SF Pro Display',
              colorScheme: ColorScheme.fromSeed(
                seedColor: provider.themeColor,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
              scaffoldBackgroundColor: const Color(0xFF0D1B2A),
            )
          : ThemeData(
              fontFamily: 'SF Pro Display',
              colorScheme: ColorScheme.fromSeed(
                seedColor: provider.themeColor,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
            ),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: MaterialApp(
        title: 'Hava & Kombin',
        debugShowCheckedModeBanner: false,
        locale: provider.language == 'en'
            ? const Locale('en')
            : const Locale('tr'),
        supportedLocales: const [Locale('tr'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        themeMode: provider.themeMode,
        theme: ThemeData(
          fontFamily: 'SF Pro Display',
          colorScheme: ColorScheme.fromSeed(
            seedColor: provider.themeColor,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          fontFamily: 'SF Pro Display',
          colorScheme: ColorScheme.fromSeed(
            seedColor: provider.themeColor,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFF0D1B2A),
        ),
        home: _showSplash
            ? SplashScreen(
                readyFuture: provider.initialization,
                onComplete: () {
                  if (mounted) setState(() => _showSplash = false);
                })
            : provider.onboardingCompleted
                ? const HomeScreen()
                : const OnboardingScreen(),
      ),
    );
  }
}
