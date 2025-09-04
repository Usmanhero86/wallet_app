import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../themes/theme_provider.dart';

class UAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const UAppBar({super.key, this.title});
  final Widget? title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);
    final notifier = ref.read(themeNotifierProvider.notifier);

    return AppBar(
      title: title,
      actions: [
        IconButton(
          icon: Icon(
            themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
          ),
          onPressed: () {
            notifier.toggleTheme(themeMode != ThemeMode.dark);
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size(50.0, 50.0);
}
