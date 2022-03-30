import 'package:flutter/material.dart';
import 'package:mangazer/theme/config.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  var selectedMode = 0;
  var modeArr = ['Slide horizontal', 'Slide vertical'];

  getSP(pref) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var value = prefs.get(pref);
    return value;
  }

  setSP(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(key, value);
  }

  getSettings() async {
    selectedMode = await getSP("mode");
    if (selectedMode == null) {
      await setSP("mode", 0);
      selectedMode = await getSP("mode");
    }
    setState(() {
      selectedMode = selectedMode;
    });
  }

  @override
  void initState() {
    super.initState();

    getSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: 48),
        child: SettingsList(
          // backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          sections: [
            SettingsSection(
              title: Text('Mode de lecture'),
              tiles: [
                SettingsTile.switchTile(
                  initialValue: selectedMode == 0 ? false : true,
                  title: Text(modeArr[selectedMode]),
                  leading: Icon(Icons.menu_book_sharp),
                  onToggle: (bool value) {
                    setState(() {
                      selectedMode = value == false ? 0 : 1;
                      setSP("mode", selectedMode);
                    });
                  },
                ),
              ],
            ),
            SettingsSection(
              title: Text('Thèmes'),
              tiles: [
                SettingsTile.switchTile(
                  initialValue: currentTheme.currentTheme == ThemeMode.light ? false : true,
                  title: currentTheme.currentTheme == ThemeMode.light
                      ? Text("Mode clair")
                      : Text("Mode sombre"),
                  leading: Icon(Icons.brightness_4),
                  // switchValue: currentTheme.currentTheme == ThemeMode.light
                  //     ? false
                  //     : true,
                  onToggle: (bool value) {
                    setState(() {
                      currentTheme.toggleTheme();
                      setSP("theme", value == false ? 0 : 1);
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
//  Center(
//           child: new DropdownButton<String>(
//         items: modeArr.map((String value) {
//           return new DropdownMenuItem<String>(
//             value: value,
//             child: new Text(value),
//           );
//         }).toList(),
//         onChanged: (value) {
//           setState(() {
//             selectedMode = modeArr.indexWhere((element) => element == value);
//             setSP("mode", selectedMode);
//           });
//         },
//         value: modeArr[selectedMode],
//       )),
  }
}
