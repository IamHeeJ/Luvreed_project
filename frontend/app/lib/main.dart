import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:luvreed/screens/chart_screen.dart';
import 'package:luvreed/screens/chat_screen.dart';

import 'package:luvreed/screens/collection_screen.dart';
import 'package:luvreed/screens/home_screen.dart';
import 'package:luvreed/screens/setting_screen.dart';
import 'package:luvreed/screens/splash_screen.dart';
import 'package:luvreed/screens/startpage1.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:luvreed/screens/stomp_provider.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:luvreed/constants.dart';
import 'package:luvreed/screens/login_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'screens/main_screen.dart';

void main() {
  initializeDateFormatting().then((_) => runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => StompProvider()),
      ],
      child: const MaterialApp( 
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          GlobalCupertinoLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          Locale('ko', ''),
        ],
        home: MyApp(),
      ),
    ),
  ));
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _index = 0;
  final bool _isLoggedIn = false;
  final secureStorage = const FlutterSecureStorage();
  List<Widget> _pages = [];
  String? _chatroomId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', ''),
      ],
      initialRoute: '/',
      routes: {
        '/': (context) => _isLoggedIn == null
            ? const SplashScreen()
            : _isLoggedIn
                ? const MainScreen()
                : const StartPage1(),
        '/main': (context) => const MainScreen(),
        '/start': (context) => const StartPage1(),
        '/setting': (context) => Provider<StompProvider>(
              create: (_) => StompProvider(),
              child: const SettingScreen(),
            ),
            '/chat': (context) => MultiProvider( // ChatScreen을 MultiProvider로 감싸기
          providers: [
            ChangeNotifierProvider(create: (_) => HomeProvider()),
            ChangeNotifierProvider(create: (_) => StompProvider()),
          ],
          child: const ChatScreen(),
        ),
      },
    );
  }
  

  Future<void> _checkLoginStatus() async {
    String? token = await secureStorage.read(key: 'token');

    if (token != null && token.isNotEmpty) {
      final isTokenValid = await _validateToken(token);

      if (isTokenValid) {
        _updatePages();
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const MainScreen(),
            transitionDuration: Duration.zero,
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const StartPage1(),
            transitionDuration: Duration.zero,
          ),
        );
      }
    }
  }

  void _updatePages() {
    _pages = [
      const HomeScreen(),
      const ChatScreen(),
      const ChartScreen(),
      const CollectionScreen(),
    ];
  }

  Future<bool> _validateToken(String token) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/api/validate-token'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 401) {
      return false;
    } else {
      //throw Exception('Failed to validate token');
      return false;
    }
  }

  // void _navigateToLogin(BuildContext context) {
  //   Navigator.pushReplacement(
  //     context,
  //     MaterialPageRoute(builder: (context) => const LoginScreen()),
  //   );
  // }
}
