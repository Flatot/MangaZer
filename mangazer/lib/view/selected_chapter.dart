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
  PageController pageViewController = PageController();
  int currentMode = 0;
  String suffix;
  String chapter;
  String imgUrl;

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
    List<Map<String, dynamic>> img;
    // GET NB OF PAGES IN CHAPTER
    if (await webScraper.loadWebPage(route)) {
      strPages = webScraper.getElement('.selectpicker', []);
      img = webScraper.getElement('.scan-page', ['src']);
      imgUrl = img[0]["attributes"]["src"].toString().trim();
      // GET CHAPTER OF THE FIRST PAGE (AJIN -> CHAPTER 16.5 => 17)
      chapter = imgUrl.split("/")[7];

      for (var i = 0; i < strPages.length; i++) {
        strPages[i]["title"] = strPages[i]["title"].trim();
      }
      if (mounted) {
        setState(() {
          _listPage = strPages[0]["title"].split(new RegExp(r"(\s)+"));
        });
      }
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
    if (chapter == null) {
      if (widget.baseUrl != "wwv.scan-1.com") {
        chapter = route.split("/")[3];
      } else {
        chapter = route.split("/")[2];
      }
    }
    var page = (index >= 1 && index <= 9) ? "0" + index.toString() : index;
    if (widget.baseUrl != "wwv.scan-1.com") {
      manga = route.split("/")[2];
      page = pad(int.parse(page.toString()), 100);
    }
    if (suffix == null) {
      return checkAllSuffix(manga, chapter, page);
    } else {
      final responseSuffix = await http.head(Uri.https("${widget.baseUrl}",
          "/uploads/manga/$manga/chapters/$chapter/$page.$suffix"));
      if (responseSuffix.statusCode == 200) {
        return "https://${widget.baseUrl}/uploads/manga/$manga/chapters/$chapter/$page.$suffix";
      } else {
        return checkAllSuffix(manga, chapter, page);
      }
    }
  }

  checkAllSuffix(manga, chapter, page) {
    List<Future<http.Response>> futuresArray = [];
    ["jpg", "png", "webp"].forEach((suffix) {
      futuresArray.add(http.head(Uri.https("${widget.baseUrl}",
          "/uploads/manga/$manga/chapters/$chapter/$page.$suffix")));
    });
    return Future.wait(futuresArray).then((res) {
      for (var i = 0; i < res.length; i++) {
        if (res[i].statusCode == 200) {
          suffix = ["jpg", "png", "webp"][i];
          return "https://${widget.baseUrl}/uploads/manga/$manga/chapters/$chapter/$page.$suffix";
        }
      }
      return "none";
    });
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

  String similarChapter(chapter) {
    var tmp = "";
    for (var i = 0; i < chapter.length; i++) {
      if (chapter[i] == "0") {
        tmp += "0";
      }
    }
    tmp += (int.parse(chapter) + 1).toString();
    return tmp;
  }

  nextChapter() async {
    List<String> listString = await getSP(widget.selectedManga["data"]);
    if (listString == null) listString = [];
    listString.add(widget.chapterLink["attributes"]["href"]);
    setSP(widget.selectedManga["data"], listString);
    var newChapter = similarChapter(chapter);
    setState(() {
      chapter = newChapter;
      pageViewController.animateTo(0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            child: PageView.builder(
              controller: pageViewController,
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
                ),
                Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: IconButton(
                    onPressed: nextChapter,
                    icon: Icon(
                      Icons.navigate_next_rounded,
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
