import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wallet_app/presentation/view/login_screen.dart';
import 'package:wallet_app/themes/theme_provider.dart';
import 'themes/theme.dart';
import 'presentation/view/auth_wrapper.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ZainPay App',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      home:  LoginScreen(),
    );
  }
}
