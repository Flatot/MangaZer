import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:mangazer/selected_manga.dart';
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
  }

  @override
  void initState() {
    super.initState();

    getSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: new DropdownButton<String>(
        items: modeArr.map((String value) {
          return new DropdownMenuItem<String>(
            value: value,
            child: new Text(value),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedMode = modeArr.indexWhere((element) => element == value);
            setSP("mode", selectedMode);
          });
        },
        value: modeArr[selectedMode],
      )),
    );
  }
}
