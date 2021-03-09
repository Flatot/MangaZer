import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mangazer/selected_chapter.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  getSP(pref) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var value = prefs.get(pref);
    return value;
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
      var listView = await getSP(widget.selectedManga["data"]);
      listView?.forEach((elem) {
        var index = _listLink
            .indexWhere((element) => element["attributes"]["href"] == elem);
        if (index != -1) {
          _listChapters[index]["viewed"] = true;
        }
      });

      setState(() {
        _listChapters = _listChapters.reversed.toList();
        _listLink = _listLink.reversed.toList();
      });
    }
  }

  _selectChapter(elem, link) {
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

  setSP(String key, List<String> value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(key, value);
  }

  _addToViewed(index) async {
    List<String> listString = await getSP(widget.selectedManga["data"]);
    if (listString == null) listString = [];
    listString.add(_listLink[index]["attributes"]["href"]);
    setSP(widget.selectedManga["data"], listString);

    setState(() {
      _listChapters[index]["viewed"] = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectedManga["value"]),
        actions: [
          IconButton(
            icon: Icon(Icons.sort),
            tooltip: 'Changer le sens de la liste',
            onPressed: () {
              setState(() {
                _listChapters = _listChapters.reversed.toList();
                _listLink = _listLink.reversed.toList();
              });
            },
          )
        ],
      ),
      body: Column(
        children: [
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
                      child: Dismissible(
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.startToEnd) {
                            _addToViewed(index);
                            return false;
                          } else if (direction == DismissDirection.endToStart) {
                            return false;
                          }
                        },
                        key: UniqueKey(),
                        child: ListTile(
                          trailing: (_listChapters[index]["viewed"] != null &&
                                  _listChapters[index]["viewed"] == true)
                              ? Icon(Icons.check,
                                  color: Theme.of(context).primaryColor)
                              : Text(""),
                          title: Text(
                            _listChapters[index]["title"],
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
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
