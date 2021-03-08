import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mangazer/selected_chapter.dart';

import 'package:web_scraper/web_scraper.dart';

class SelectedMangaPage extends StatefulWidget {
  SelectedMangaPage({Key key, this.selectedManga}) : super(key: key);

  final dynamic selectedManga;

  @override
  _SelectedMangaPageState createState() => _SelectedMangaPageState();
}

class _SelectedMangaPageState extends State<SelectedMangaPage> {
  List<Map<String, dynamic>> _listChapters;
  List<Map<String, dynamic>> _listLink;

  @override
  void initState() {
    super.initState();

    loadDataScan1();
  }

  loadDataScan1() async {
    final webScraper = WebScraper('https://wwv.scan-1.com');
    if (await webScraper.loadWebPage('/${widget.selectedManga["data"]}')) {
      _listChapters = webScraper.getElement('.chapters li > h5', []);
      _listLink = webScraper.getElement('.chapter-title-rtl a', ['href']);

      for (var i = 0; i < _listChapters.length; i++) {
        _listChapters[i]["title"] = _listChapters[i]["title"].trim();
        _listChapters[i]["title"] =
            _listChapters[i]["title"].replaceAll("    :", ":");
      }
      setState(() {
        _listChapters = _listChapters;
        _listLink = _listLink;
      });
    }
  }

  _selectChapter(elem, link) {
    print(elem);
    print(link);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectedChapterPage(
            selectedManga: widget.selectedManga,
            selectedChapter: elem,
            chapterLink: link),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectedManga["value"]),
      ),
      body: Column(
        children: [
          Container(
            child: ElevatedButton(
              onPressed: loadDataScan1,
              child: Text("LOAD"),
            ),
          ),
          Expanded(
            child: ListView.builder(
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      _selectChapter(_listChapters[index], _listLink[index]);
                    },
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                      child: Text(
                        _listChapters[index]["title"],
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  );
                },
                itemCount: _listChapters != null ? _listChapters.length : 0),
          ),
        ],
      ),
    );
  }
}
