import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MangaZerTheme with ChangeNotifier {
  bool _isDarkTheme = true;
  void setTheme(bool _isDark) {
    _isDarkTheme = _isDark;
    notifyListeners();
  }

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

  // static ThemeData get darkTheme {
  //   return ThemeData(
  //     primaryColor: Color(0xFFBA131A),
  //     primaryColorLight: Color(0xFFFF242D),
  //     accentColor: Color(0xFFEBEBEB),
  //     scaffoldBackgroundColor: Color(0xFF141414),
  //     backgroundColor: Color(0xFF141414),
  //     bottomAppBarColor: Color(0xFF282828),
  //     textSelectionTheme: TextSelectionThemeData(
  //       cursorColor: Color(0xFFBA131A),
  //       selectionHandleColor: Color(0xFFFFB4B7),
  //       selectionColor: Color(0xFFFFB4B7),
  //     ),
  //     primaryIconTheme: IconThemeData(color: Color(0xFFFFB4B7)),
  //     accentIconTheme: IconThemeData(color: Color(0xFFEBEBEB)),
  //     iconTheme: IconThemeData(color: Color(0xFFEBEBEB)),
  //     toggleButtonsTheme: ToggleButtonsThemeData(color: Color(0xFFBA131A)),
  //     brightness: Brightness.dark,
  //     elevatedButtonTheme: ElevatedButtonThemeData(
  //       style: ButtonStyle(
  //         backgroundColor: MaterialStateProperty.all(Color(0xFFBA131A)),
  //       ),
  //     ),
  //     outlinedButtonTheme: OutlinedButtonThemeData(
  //       style: OutlinedButton.styleFrom(primary: Color(0xFFBA131A)),
  //     ),
  //     switchTheme: SwitchThemeData(
  //       thumbColor: MaterialStateProperty.resolveWith((states) {
  //         if (states.contains(MaterialState.selected)) {
  //           return Color(0xFFFF242D);
  //         }
  //         return Colors.grey[300];
  //       }),
  //       trackColor: MaterialStateProperty.resolveWith((states) {
  //         if (states.contains(MaterialState.selected)) {
  //           return Color(0xFFBA131A);
  //         }
  //         return Colors.grey[700];
  //       }),
  //     ),
  //   );
  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: Colors.deepOrange,
      primaryColorLight: Colors.deepOrange[600],
      accentColor: Color(0xFFEBEBEB),
      scaffoldBackgroundColor: Color(0xFF141414),
      backgroundColor: Color(0xFF141414),
      bottomAppBarColor: Color(0xFF282828),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: Colors.deepOrange,
        selectionHandleColor: Colors.deepOrangeAccent,
        selectionColor: Colors.deepOrangeAccent,
      ),
      // primaryIconTheme: IconThemeData(color: Colors.deepOrange),
      accentIconTheme: IconThemeData(color: Color(0xFFEBEBEB)),
      iconTheme: IconThemeData(color: Color(0xFFEBEBEB)),
      toggleButtonsTheme: ToggleButtonsThemeData(color: Colors.deepOrange),
      brightness: Brightness.dark,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.deepOrange),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(primary: Colors.deepOrange),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return Colors.deepOrange;
          }
          return Colors.grey[300];
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return Colors.deepOrange;
          }
          return Colors.grey[700];
        }),
      ),
    );
  }

  static ThemeData get darkGreenTheme {
    return ThemeData(
      primaryColor: Colors.green,
      primaryColorLight: Colors.green[700],
      accentColor: Color(0xFFEBEBEB),
      scaffoldBackgroundColor: Color(0xFF141414),
      backgroundColor: Color(0xFF141414),
      bottomAppBarColor: Color(0xFF282828),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: Colors.green,
        selectionHandleColor: Colors.greenAccent,
        selectionColor: Colors.greenAccent,
      ),
      primaryIconTheme: IconThemeData(color: Colors.green),
      accentIconTheme: IconThemeData(color: Color(0xFFEBEBEB)),
      iconTheme: IconThemeData(color: Color(0xFFEBEBEB)),
      toggleButtonsTheme: ToggleButtonsThemeData(color: Colors.green),
      brightness: Brightness.dark,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.green),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(primary: Colors.green),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return Colors.green;
          }
          return Colors.grey[300];
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return Colors.green;
          }
          return Colors.grey[700];
        }),
      ),
    );
  }
}
