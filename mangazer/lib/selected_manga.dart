import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mangazer/download_chapter.dart';
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
  String _resume;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    loadDataScan1();
  }

  getSP(pref) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> value = prefs.getStringList(pref);
    return value;
  }

  loadDataScan1() async {
    var lastViewedChapter = 0;
    final webScraper = WebScraper('https://wwv.scan-1.com');
    if (await webScraper.loadWebPage('/${widget.selectedManga["data"]}')) {
      var _resumeElement = webScraper.getElement('.well > p', []);
      _listChapters = webScraper.getElement('.chapters li > h5', []);
      _listLink = webScraper.getElement('.chapter-title-rtl a', ['href']);
      _resume = _resumeElement[0]["title"];

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
      // CHECK LAST VIEWED CHAPTER
      for (var i = 0; i < _listChapters.length; i++) {
        if (lastViewedChapter == 0 && _listChapters[i]["viewed"] != true) {
          lastViewedChapter = i;
        }
      }
      // AUTO SCROLL TO LAST VIEWED
      _scrollController.animateTo(
        ((lastViewedChapter * 63).toDouble()),
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  _selectChapter(index, _listChapters, _listLink) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectedChapterPage(
            selectedManga: widget.selectedManga,
            selectedChapter: _listChapters[index],
            chapterLink: _listLink[index]),
      ),
    ).then((value) {
      if (value == true) {
        setState(() {
          _listChapters[index]["viewed"] = true;
        });
      }
    });
  }

  setSP(String key, List<String> value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(key, value);
  }

  setPreviousChapterToViewed(index) async {
    List<String> listString = await getSP(widget.selectedManga["data"]);
    if (listString == null) listString = [];
    for (var i = 0; i <= index; i++) {
      listString.add(_listLink[i]["attributes"]["href"]);
      _listChapters[i]["viewed"] = true;
    }
    setSP(widget.selectedManga["data"], listString);
    setState(() {
      _listChapters = _listChapters;
    });
  }

  showDialogConfirmation(index) {
    if (Platform.isIOS) {
      showDialog(
          context: context,
          builder: (_) => CupertinoAlertDialog(
                title: Text("Marquer les chapitres précédents"),
                content: Text(
                    "Voulez-vous marquer les chapitres précédents comme lus ?"),
                actions: <Widget>[
                  CupertinoDialogAction(
                      child: Text(
                        "Non",
                        style: TextStyle(color: Theme.of(context).accentColor),
                      ),
                      onPressed: () {
                        setState(() {
                          _listChapters[index]["viewed"] = true;
                        });
                        Navigator.of(context).pop();
                      }),
                  CupertinoDialogAction(
                      child: Text("Oui",
                          style: TextStyle(
                              color: Theme.of(context).primaryColorLight)),
                      onPressed: () {
                        setPreviousChapterToViewed(index);
                        Navigator.of(context).pop();
                      })
                ],
              ));
    } else {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: Text("Marquer les chapitres précédents"),
                content: Text(
                    "Voulez-vous marquer les chapitres précédents comme lus ?"),
                elevation: 24.0,
                actions: <Widget>[
                  TextButton(
                      child: Text(
                        "Non",
                        style: TextStyle(color: Theme.of(context).accentColor),
                      ),
                      onPressed: () {
                        setState(() {
                          _listChapters[index]["viewed"] = true;
                        });
                        Navigator.of(context).pop();
                      }),
                  TextButton(
                      child: Text(
                        "Oui",
                        style: TextStyle(
                            color: Theme.of(context).primaryColorLight),
                      ),
                      onPressed: () {
                        setPreviousChapterToViewed(index);
                        Navigator.of(context).pop();
                      })
                ],
              ));
    }
  }

  _addToViewed(index) async {
    List<String> listString = await getSP(widget.selectedManga["data"]);
    if (listString == null) listString = [];
    listString.add(_listLink[index]["attributes"]["href"]);
    setSP(widget.selectedManga["data"], listString);

    if (_listChapters[index - 1]["viewed"] != true) {
      showDialogConfirmation(index);
    } else {
      setState(() {
        _listChapters[index]["viewed"] = true;
      });
    }
  }

  _downloadChapter(index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DownloadChapterPage(
            selectedManga: widget.selectedManga,
            selectedChapter: _listChapters[index],
            chapterLink: _listLink[index]),
      ),
    );
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
                controller: _scrollController,
                itemBuilder: (BuildContext context, int index) {
                  if (_listChapters == null) {
                    return Container(
                      height: MediaQuery.of(context).size.height - 60,
                      width: MediaQuery.of(context).size.width,
                      child: Center(
                        child: SpinKitDoubleBounce(
                            color: Theme.of(context).primaryColor),
                      ),
                    );
                  }
                  return GestureDetector(
                    onTap: () {
                      _selectChapter(index, _listChapters, _listLink);
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
                          leading: IconButton(
                            icon: Icon(Icons.download_rounded),
                            color: Theme.of(context).primaryColor,
                            onPressed: () {
                              _downloadChapter(index);
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
                itemCount: _listChapters != null ? _listChapters.length : 1),
          ),
        ],
      ),
    );
  }
}
