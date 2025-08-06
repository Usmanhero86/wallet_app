import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet_app/themes/theme_provider.dart';
import 'package:wallet_app/services/auth_provider.dart';
import 'package:wallet_app/services/account_provider.dart';
import 'package:wallet_app/view/login_screen.dart';
import 'themes/theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AccountProvider()),
      ],
      child: const MyApp(),
    ),
  );
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


