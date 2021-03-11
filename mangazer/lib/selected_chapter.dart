import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:web_scraper/web_scraper.dart';

class SelectedChapterPage extends StatefulWidget {
  SelectedChapterPage(
      {Key key, this.selectedManga, this.selectedChapter, this.chapterLink})
      : super(key: key);

  final dynamic selectedManga;
  final dynamic selectedChapter;
  final dynamic chapterLink;

  @override
  _SelectedChapterPageState createState() => _SelectedChapterPageState();
}

class _SelectedChapterPageState extends State<SelectedChapterPage> {
  List<String> _listPage;
  int _selectedPage = 1;
  String _currentImage = "";
  List<String> listImages = [];
  int currentMode = 0;

  @override
  void initState() {
    super.initState();

    loadChapterData();
    getImage();
    getSettings();
  }

  getSettings() async {
    currentMode = await getSPInt("mode");
    setState(() {
      currentMode = currentMode;
    });
  }

  loadChapterData() async {
    final webScraper = WebScraper('https://wwv.scan-1.com');
    var route = widget.chapterLink["attributes"]["href"];
    route = route.split("https://wwv.scan-1.com")[1];
    List<Map<String, dynamic>> strPages;
    if (await webScraper.loadWebPage(route)) {
      strPages = webScraper.getElement('.selectpicker', []);
    }
    for (var i = 0; i < strPages.length; i++) {
      strPages[i]["title"] = strPages[i]["title"].trim();
    }
    setState(() {
      _listPage = strPages[0]["title"].split(new RegExp(r"(\s)+"));
    });
  }

  getImage() async {
    var route = widget.chapterLink["attributes"]["href"];
    route = route.split("https://wwv.scan-1.com")[1];
    var manga = route.split("/")[1];
    var chapter = route.split("/")[2];
    var page = (_selectedPage >= 1 && _selectedPage <= 9)
        ? "0" + _selectedPage.toString()
        : _selectedPage;

    final response = await http.head(Uri.https(
        "wwv.scan-1.com", "/uploads/manga/$manga/chapters/$chapter/$page.jpg"));

    if (response.statusCode == 200) {
      setState(() {
        _currentImage =
            "https://wwv.scan-1.com/uploads/manga/$manga/chapters/$chapter/$page.jpg";
      });
    } else {
      final responsePng = await http.head(Uri.https("wwv.scan-1.com",
          "/uploads/manga/$manga/chapters/$chapter/$page.png"));
      if (responsePng.statusCode == 200) {
        setState(() {
          _currentImage =
              "https://wwv.scan-1.com/uploads/manga/$manga/chapters/$chapter/$page.png";
        });
      } else {
        _currentImage = null;
      }
    }
  }

  getImageFromIndex(index) async {
    var route = widget.chapterLink["attributes"]["href"];
    route = route.split("https://wwv.scan-1.com")[1];
    var manga = route.split("/")[1];
    var chapter = route.split("/")[2];
    var page = (index >= 1 && index <= 9) ? "0" + index.toString() : index;

    final response = await http.head(Uri.https(
        "wwv.scan-1.com", "/uploads/manga/$manga/chapters/$chapter/$page.jpg"));

    if (response.statusCode == 200) {
      return "https://wwv.scan-1.com/uploads/manga/$manga/chapters/$chapter/$page.jpg";
    } else {
      final responsePng = await http.head(Uri.https("wwv.scan-1.com",
          "/uploads/manga/$manga/chapters/$chapter/$page.png"));
      if (responsePng.statusCode == 200) {
        return "https://wwv.scan-1.com/uploads/manga/$manga/chapters/$chapter/$page.png";
      } else {
        return null;
      }
    }
  }

  getSPInt(pref) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int value = prefs.getInt(pref);
    return value;
  }

  Future<List<String>> getSP(pref) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> value = prefs.getStringList(pref);
    return value;
  }

  setSP(String key, List<String> value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(key, value);
  }

  changePage() async {
    if (_selectedPage < _listPage.length) {
      _selectedPage++;
    } else {
      List<String> listString = await getSP(widget.selectedManga["data"]);
      if (listString == null) listString = [];
      listString.add(widget.chapterLink["attributes"]["href"]);
      setSP(widget.selectedManga["data"], listString);
      Navigator.pop(context, true);
      return;
    }
    getImage();
  }

  prevPage() {
    if (_selectedPage > 1)
      _selectedPage--;
    else {
      Navigator.pop(context);
      return;
    }
    getImage();
  }

  @override
  Widget build(BuildContext context) {
    String swipeDirection;
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.selectedManga["value"]),
        ),
        body:
            // currentMode == 0
            // ?
            Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  changePage();
                },
                onHorizontalDragUpdate: (details) {
                  swipeDirection = details.primaryDelta < 0 ? 'left' : 'right';
                },
                onHorizontalDragEnd: (details) {
                  if (swipeDirection == 'left') {
                    changePage();
                  }
                  if (swipeDirection == 'right') {
                    prevPage();
                  }
                },
                child: _currentImage != null
                    ? PhotoView(
                        imageProvider: NetworkImage(_currentImage),
                      )
                    : Text("Not founded"),
              ),
            ),
          ],
        )
        // : ListView.builder(
        //     itemCount: _listPage != null ? _listPage.length : 0,
        //     itemBuilder: (BuildContext context, int index) {
        //       // listImages.add(_currentImage);
        //       return FutureBuilder<Widget>(
        //           future: getImageFromIndex(index),
        //           builder:
        //               (BuildContext context, AsyncSnapshot<Widget> snapshot) {
        //             if (snapshot.hasData) {
        //               print(snapshot.data);
        //               return Text("test");
        //               // return PhotoView(
        //               //   imageProvider: NetworkImage(snapshot.data[index]),
        //               // );
        //             }
        //             return Container(child: CircularProgressIndicator());
        //           });
        //     },
        //   ),
        // : ListView(
        //     children: [
        //       FutureBuilder<Widget>(
        //         future: getImageFromIndex(0),
        //         builder:
        //             (BuildContext context, AsyncSnapshot<Widget> snapshot) {
        //           if (snapshot.hasData) {
        //             print(snapshot.data);
        //             return Text("test");
        //             // return PhotoView(
        //             //   imageProvider: NetworkImage(snapshot.data[index]),
        //             // );
        //           }
        //           return Container(child: CircularProgressIndicator());
        //         },
        //       ),
        //     ],
        //   ),
        );
  }
}
