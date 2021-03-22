import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:web_scraper/web_scraper.dart';

class SelectedChapterPage extends StatefulWidget {
  SelectedChapterPage(
      {Key key, this.selectedManga, this.chapterLink, this.baseUrl})
      : super(key: key);

  final dynamic selectedManga;
  final dynamic chapterLink;
  final String baseUrl;

  @override
  _SelectedChapterPageState createState() => _SelectedChapterPageState();
}

class _SelectedChapterPageState extends State<SelectedChapterPage> {
  List<String> _listPage;
  List<String> listImages = [];
  int currentMode = 0;
  String suffix;

  @override
  void initState() {
    super.initState();

    loadChapterData();
    getSettings();
  }

  getSettings() async {
    currentMode = await getSPInt("mode");
    setState(() {
      currentMode = currentMode;
    });
  }

  loadChapterData() async {
    final webScraper = WebScraper('https://${widget.baseUrl}');
    var route = widget.chapterLink["attributes"]["href"];
    route = route.split("https://${widget.baseUrl}")[1];
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

  getImageFromIndex(index) async {
    var route = widget.chapterLink["attributes"]["href"];
    route = route.split("https://${widget.baseUrl}")[1];
    var manga = route.split("/")[1];
    var chapter = route.split("/")[2];
    var page = (index >= 1 && index <= 9) ? "0" + index.toString() : index;
    if (widget.baseUrl != "wwv.scan-1.com") {
      manga = route.split("/")[2];
      chapter = route.split("/")[3];
      // page = (index >= 1 && index <= 9) ? "0" + index.toString() : index;
      chapter = pad(int.parse(chapter), 1000);
      page = pad(int.parse(page.toString()), 100);
    }

    if (suffix == null) {
      final response = await http.head(Uri.https("${widget.baseUrl}",
          "/uploads/manga/$manga/chapters/$chapter/$page.jpg"));
      if (response.statusCode == 200) {
        suffix = "jpg";
        return "https://${widget.baseUrl}/uploads/manga/$manga/chapters/$chapter/$page.jpg";
      } else {
        final responsePng = await http.head(Uri.https("${widget.baseUrl}",
            "/uploads/manga/$manga/chapters/$chapter/$page.png"));
        if (responsePng.statusCode == 200) {
          suffix = "png";
          return "https://${widget.baseUrl}/uploads/manga/$manga/chapters/$chapter/$page.png";
        } else {
          return "none";
        }
      }
    } else {
      final responseSuffix = await http.head(Uri.https("${widget.baseUrl}",
          "/uploads/manga/$manga/chapters/$chapter/$page.$suffix"));
      if (responseSuffix.statusCode == 200) {
        return "https://${widget.baseUrl}/uploads/manga/$manga/chapters/$chapter/$page.$suffix";
      } else {
        return "none";
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

  validateChapter() async {
    List<String> listString = await getSP(widget.selectedManga["data"]);
    if (listString == null) listString = [];
    listString.add(widget.chapterLink["attributes"]["href"]);
    setSP(widget.selectedManga["data"], listString);
    Navigator.pop(context, true);
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            child: PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: _listPage == null ? 0 : _listPage.length,
              itemBuilder: (context, int currentIdx) {
                return Container(
                  child: FutureBuilder(
                    future: getImageFromIndex(currentIdx + 1),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data != "none") {
                          return PhotoView(
                            imageProvider:
                                CachedNetworkImageProvider(snapshot.data),
                          );
                        } else {
                          return Text("");
                        }
                      }
                      return SpinKitDoubleBounce(
                          color: Theme.of(context).primaryColor);
                    },
                  ),
                );
              },
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
              actions: [
                Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: IconButton(
                    onPressed: validateChapter,
                    icon: Icon(
                      Icons.check,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
