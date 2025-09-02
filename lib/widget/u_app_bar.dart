import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../themes/theme_provider.dart';


class UAppBar extends StatelessWidget implements PreferredSizeWidget{
  const UAppBar({
    super.key,
    this.title,
  });
  final Widget? title;
  // final VoidCallback? leadingOnPressed;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title,
      actions: [ Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return IconButton(
            icon: Icon(themeProvider.isDarkMode
                ? Icons.light_mode
                : Icons.dark_mode),
            onPressed: () {
              themeProvider.toggleTheme(!themeProvider.isDarkMode);
            },
          );
        },
      ),
    ]
    );
  }

  @override
  Size get preferredSize => Size(50.0,50.0);
}
