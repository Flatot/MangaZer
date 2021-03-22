import 'package:flutter/material.dart';

class MangaZerTheme with ChangeNotifier {
  static bool _isDarkTheme = true;
  ThemeMode get currentTheme => _isDarkTheme ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    _isDarkTheme = !_isDarkTheme;
    notifyListeners();
  }

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: Color(0xFFBA131A),
      primaryColorLight: Color(0xFFFF242D),
      accentColor: Colors.grey,
      brightness: Brightness.light,
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: Color(0xFFBA131A),
        selectionHandleColor: Color(0xFFFFB4B7),
        selectionColor: Color(0xFFFFB4B7),
      ),
      toggleButtonsTheme: ToggleButtonsThemeData(color: Color(0xFFBA131A)),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Color(0xFFBA131A)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(primary: Color(0xFFBA131A)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return Color(0xFFFF242D);
          }
          return Colors.grey[300];
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return Color(0xFFBA131A);
          }
          return Colors.grey[700];
        }),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: Color(0xFFBA131A),
      primaryColorLight: Color(0xFFFF242D),
      accentColor: Colors.grey,
      scaffoldBackgroundColor: Color(0xFF000),
      backgroundColor: Color(0xFF2E2626),
      bottomAppBarColor: Color(0xFF2D2C2C),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: Color(0xFFBA131A),
        selectionHandleColor: Color(0xFFFFB4B7),
        selectionColor: Color(0xFFFFB4B7),
      ),
      toggleButtonsTheme: ToggleButtonsThemeData(color: Color(0xFFBA131A)),
      brightness: Brightness.dark,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Color(0xFFBA131A)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(primary: Color(0xFFBA131A)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return Color(0xFFFF242D);
          }
          return Colors.grey[300];
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return Color(0xFFBA131A);
          }
          return Colors.grey[700];
        }),
      ),
    );
  }
}
