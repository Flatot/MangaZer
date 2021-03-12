import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:mangazer/pdf_chapter_view.dart';
import 'package:mangazer/selected_manga.dart';
import 'package:mangazer/settings.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DownloadedChapterPage extends StatefulWidget {
  DownloadedChapterPage({Key key, this.pathFolder}) : super(key: key);

  final String pathFolder;

  @override
  _DownloadedChapterPageState createState() => _DownloadedChapterPageState();
}

class _DownloadedChapterPageState extends State<DownloadedChapterPage> {
  dynamic mangaSelected;
  List<dynamic> listChapter = [];

  Future<List<String>> getSP(pref) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> value = prefs.getStringList(pref);
    return value;
  }

  getSPKeys() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var value = prefs.getKeys().where((element) => element != "mode");
    return value;
  }

  _getListDownloadedInFolder() async {
    Stream<FileSystemEntity> list = await Directory(widget.pathFolder).list();
    list.forEach((element) async {
      var arr = element.path.split('/');
      var chapterName = arr[arr.length - 1];
      setState(() {
        listChapter.add({"name": chapterName, "path": element.path});
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _getListDownloadedInFolder();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chapitres"),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: ListView.builder(
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      var file = File(listChapter[index]["path"]);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PdfChapterViewPage(pdfFile: file),
                        ),
                      );
                    },
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                      child: ListTile(
                        title: Text(
                          listChapter[index]["name"],
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  );
                },
                itemCount: listChapter.length),
          ),
        ],
      ),
    );
  }
}
