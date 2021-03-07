import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SelectedMangaPage extends StatefulWidget {
  SelectedMangaPage({Key key, this.selectedManga}) : super(key: key);

  final dynamic selectedManga;

  @override
  _SelectedMangaPageState createState() => _SelectedMangaPageState();
}

class _SelectedMangaPageState extends State<SelectedMangaPage> {
  @override
  void initState() {
    super.initState();

    loadDataFormScan1();
  }

  loadDataFormScan1() async {
    final response = await http
        .get('https://wwv.scan-1.com/${widget.selectedManga["data"]}');
    if (response.statusCode == 200) {
      print(response.body);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectedManga["value"]),
      ),
      body: Center(
        child: Container(
          child: Text('Empty Body 1'),
        ),
      ),
    );
  }
}
