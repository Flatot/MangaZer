import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:web_scraper/web_scraper.dart';

class SelectedChapterHorizontalPage extends StatefulWidget {
  SelectedChapterHorizontalPage(
      {Key key, this.selectedManga, this.chapterLink, this.baseUrl})
      : super(key: key);

  final dynamic selectedManga;
  final dynamic chapterLink;
  final String baseUrl;

  @override
  _SelectedChapterHorizontalPageState createState() =>
      _SelectedChapterHorizontalPageState();
}

class _SelectedChapterHorizontalPageState
    extends State<SelectedChapterHorizontalPage> {
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
    final webScraper = WebScraper('https://' + widget.baseUrl);
    var route = widget.chapterLink["attributes"]["href"];
    route = route.split('https://' + widget.baseUrl)[1];
    List<Map<String, dynamic>> strPages;
    if (await webScraper.loadWebPage(route)) {
      strPages = webScraper.getElement('.selectpicker', []);
      for (var i = 0; i < strPages.length; i++) {
        strPages[i]["title"] = strPages[i]["title"].trim();
      }
      setState(() {
        _listPage = strPages[0]["title"].split(new RegExp(r"(\s)+"));
      });
    }
  }

  pad(int data, int limit) {
    String res = data.toString();
    while (data < limit) {
      res = ("0" + res.toString());
      data = data * 10;
    }
    return res;
  }

  getImage() async {
    var route = widget.chapterLink["attributes"]["href"];
    route = route.split('https://' + widget.baseUrl)[1];
    var manga = route.split("/")[1];
    var chapter = route.split("/")[2];
    var page = (_selectedPage >= 1 && _selectedPage <= 9)
        ? "0" + _selectedPage.toString()
        : _selectedPage;
    if (widget.baseUrl != "wwv.scan-1.com") {
      manga = route.split("/")[2];
      chapter = route.split("/")[3];
      // page = (index >= 1 && index <= 9) ? "0" + index.toString() : index;
      chapter = pad(int.parse(chapter), 1000);
      page = pad(int.parse(page.toString()), 100);
    }

    final response = await http.head(Uri.https(
        widget.baseUrl, "/uploads/manga/$manga/chapters/$chapter/$page.jpg"));

    if (response.statusCode == 200) {
      setState(() {
        _currentImage =
            "https://${widget.baseUrl}/uploads/manga/$manga/chapters/$chapter/$page.jpg";
      });
    } else {
      final responsePng = await http.head(Uri.https(
          widget.baseUrl, "/uploads/manga/$manga/chapters/$chapter/$page.png"));
      if (responsePng.statusCode == 200) {
        setState(() {
          _currentImage =
              "https://${widget.baseUrl}/uploads/manga/$manga/chapters/$chapter/$page.png";
        });
      } else {
        _currentImage = null;
      }
    }
  }

  getImageFromIndex(index) async {
    var route = widget.chapterLink["attributes"]["href"];
    route = route.split("https://${widget.baseUrl}")[1];
    var manga = route.split("/")[1];
    var chapter = route.split("/")[2];
    var page = (index >= 1 && index <= 9) ? "0" + index.toString() : index;

    final response = await http.head(Uri.https(
        widget.baseUrl, "/uploads/manga/$manga/chapters/$chapter/$page.jpg"));

    if (response.statusCode == 200) {
      return "https://${widget.baseUrl}/uploads/manga/$manga/chapters/$chapter/$page.jpg";
    } else {
      final responsePng = await http.head(Uri.https(
          widget.baseUrl, "/uploads/manga/$manga/chapters/$chapter/$page.png"));
      if (responsePng.statusCode == 200) {
        return "https://${widget.baseUrl}/uploads/manga/$manga/chapters/$chapter/$page.png";
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
      body: Stack(
        children: [
          Container(
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
          Positioned(
            width: MediaQuery.of(context).size.width,
            height: 80,
            top: 10,
            left: 0,
            child: AppBar(
              iconTheme: Theme.of(context)
                  .iconTheme
                  .copyWith(color: Theme.of(context).primaryColor),
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(''),
            ),
          ),
        ],
      ),
    );
  }
}
