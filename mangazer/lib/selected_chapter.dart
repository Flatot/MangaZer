import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  @override
  void initState() {
    super.initState();

    loadChapterData();
    getImage();
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
    print("uploads/manga/$manga/chapters/$chapter/$page.jpg");

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

  changePage() {
    if (_selectedPage < _listPage.length)
      _selectedPage++;
    else {
      Navigator.pop(context);
      return;
    }
    getImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectedManga["value"]),
      ),
      body: Column(
        children: [
          // Container(
          //   child: ElevatedButton(
          //     onPressed: loadChapterData,
          //     child: Text("LOAD"),
          //   ),
          // ),
          // Container(
          //   height: 50,
          //   width: MediaQuery.of(context).size.width / 2,
          //   child: Expanded(
          //     child: ListView.builder(
          //         shrinkWrap: true,
          //         scrollDirection: Axis.horizontal,
          //         itemBuilder: (BuildContext context, int index) {
          //           return GestureDetector(
          //             onTap: () {
          //               // _selectChapter(_listChapters[index], _listLink[index]);
          //             },
          //             child: Padding(
          //               padding: EdgeInsets.symmetric(
          //                   vertical: 8.0, horizontal: 4.0),
          //               child: Text(
          //                 _listPage[index],
          //                 style: TextStyle(fontSize: 18),
          //               ),
          //             ),
          //           );
          //         },
          //         itemCount: _listPage != null ? _listPage.length : 0),
          //   ),
          // ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                changePage();
              },
              child: _currentImage != null
                  ? Image.network(_currentImage)
                  : Text("Not founded"),
            ),
          ),
        ],
      ),
    );
  }
}
