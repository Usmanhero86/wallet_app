import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet_app/themes/theme_provider.dart';
import 'package:wallet_app/services/auth_provider.dart';
import 'package:wallet_app/services/account_provider.dart';
import 'package:wallet_app/view/login_screen.dart';
import 'themes/theme.dart';

void main() async{

  // Add this for web testing

  if (kIsWeb) {
    HttpOverrides.global = MyHttpOverrides();
  }
  final prefs = await SharedPreferences.getInstance();
  final initialBalance = prefs.getInt('balance') ?? 00;
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // ChangeNotifierProvider(create: (_) => AccountProvider()),
        ChangeNotifierProvider(
          create: (_) => AccountProvider() ..walletBalance = initialBalance
            ..loadSentPayments()
          ..loadAccountInfo(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wallet App',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.themeMode,
      home:LoginScreen(),
    );
  }
}


