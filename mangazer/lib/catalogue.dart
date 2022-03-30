import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mangazer/theme/config.dart';
import 'package:mangazer/view/card_scroll_widget.dart';
import 'package:mangazer/view/selected_chapter.dart';
import 'package:mangazer/view/selected_chapter_horizontal.dart';
import 'package:mangazer/view/selected_manga.dart';
import 'package:mangazer/view/viewed.dart';
import 'package:rating_bar/rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_scraper/web_scraper.dart';

class Catalogue extends StatefulWidget {
  Catalogue({Key key, this.viewedPageKey}) : super(key: key);

  final GlobalKey<ViewedPageState> viewedPageKey;

  @override
  _CatalogueState createState() => _CatalogueState();
}

var cardAspectRatio = 12.0 / 16.0;
var widgetAspectRatio = cardAspectRatio * 1.2;

class _CatalogueState extends State<Catalogue> {
  List<Map<String, dynamic>> _listMangaName;
  List<Map<String, dynamic>> _listMangaStats;
  List<Map<String, dynamic>> _listMangaLastChapters;
  PageController _controller;
  double currentPage;
  var selectedMode;

  _getCatalogue(page) async {
    final webScraper = WebScraper('https://www.scan-1.net');
    if (await webScraper.loadWebPage(
        '/filterList?page=$page&cat=&alpha=&sortBy=views&asc=false&author=&artist=&tag=')) {
      setState(() {
        _listMangaName = webScraper.getElement(
            '.col-sm-6 > .media > .media-body > .media-heading > a', ["href"]);
        for (var i = 0; i < _listMangaName.length; i++) {
          var splitedHref = _listMangaName[i]["attributes"]["href"].split("/");
          _listMangaName[i]["href"] = splitedHref[splitedHref.length - 1];
          _listMangaName[i]["attributes"] = {};
        }
        _listMangaStats = webScraper
            .getElement('.col-sm-6 > .media > .media-body > span', []);
        _listMangaLastChapters = webScraper
            .getElement('.col-sm-6 > .media > .media-body > div > a', ["href"]);
        _listMangaName = _listMangaName.reversed.toList();
        _listMangaStats = _listMangaStats.reversed.toList();
        _listMangaLastChapters = _listMangaLastChapters.reversed.toList();
        _controller = PageController(initialPage: _listMangaName.length - 1);
        currentPage = _listMangaName.length - 1.0;
      });
    }
  }

  getModeSP(pref) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var value = prefs.get(pref);
    return value;
  }

  getSettings() async {
    selectedMode = await getModeSP("mode");
    setState(() {
      selectedMode = selectedMode;
    });
  }

  @override
  void initState() {
    super.initState();
    _getCatalogue(1);
    getSettings();
  }

  Future<String> _loadResume(mangaRef) async {
    final webScraper = WebScraper('https://www.scan-1.net');
    if (await webScraper.loadWebPage('/${mangaRef}')) {
      var _resumeElement = webScraper.getElement('.well > p', []);
      if (_resumeElement.length > 0) {
        return _resumeElement[0]["title"];
      }
      return null;
    }
  }

  _showMangaDetails(index) async {
    Future<String> resume = _loadResume(_listMangaName[index]["href"]);
    var currentRating = double.parse(_listMangaStats[index]["title"]);
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.4 + 20,
          child: Padding(
            padding: EdgeInsets.only(top: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 24, right: 24),
                  child: Row(
                    children: [
                      Image.network(
                        "https://www.scan-1.net/uploads/manga/${_listMangaName[index]["href"]}/cover/cover_250x350.jpg",
                        height: (MediaQuery.of(context).size.height * 0.3) + 20,
                      ),
                      Flexible(
                        child: Container(
                          height:
                              (MediaQuery.of(context).size.height * 0.3) + 20,
                          child: Padding(
                            padding: EdgeInsets.only(left: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RatingBar.readOnly(
                                  initialRating: currentRating,
                                  size: 22,
                                  isHalfAllowed: true,
                                  halfFilledIcon: Icons.star_half,
                                  filledIcon: Icons.star,
                                  emptyIcon: Icons.star_border,
                                  filledColor: Theme.of(context).primaryColor,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 12, bottom: 12),
                                  child: Text(
                                    _listMangaName[index]["title"],
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Expanded(
                                  child: FutureBuilder(
                                    future: resume,
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        return Text(
                                          snapshot.data,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 8,
                                        );
                                      }
                                      return SpinKitDoubleBounce(
                                        color: Theme.of(context).primaryColor,
                                      );
                                    },
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    var selectedManga = {
                                      "value": _listMangaName[index]["title"],
                                      "data": _listMangaName[index]["href"]
                                    };
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SelectedMangaPage(
                                            baseUrl: "www.scan-1.net",
                                            selectedManga: selectedManga),
                                      ),
                                    ).then(
                                      (value) {
                                        mangaZerServices
                                            .getListViewed()
                                            .then((list) {
                                          widget.viewedPageKey.currentState
                                              .setState(() {
                                            listMangaViewed = list;
                                          });
                                        });
                                      },
                                    );
                                  },
                                  child: Text("Chapitres"),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 12, left: 12, right: 12),
                  child: OutlinedButton(
                    onPressed: () {
                      var selectedManga = {
                        "value": _listMangaName[index]["title"],
                        "data": _listMangaName[index]["href"]
                      };
                      if (selectedMode == 0) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SelectedChapterHorizontalPage(
                                baseUrl: "www.scan-1.net",
                                selectedManga: selectedManga,
                                chapterLink: _listMangaLastChapters[index]),
                          ),
                        ).then(
                          (value) {
                            mangaZerServices.getListViewed().then((list) {
                              widget.viewedPageKey.currentState.setState(() {
                                listMangaViewed = list;
                              });
                            });
                          },
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SelectedChapterPage(
                                baseUrl: "www.scan-1.net",
                                selectedManga: selectedManga,
                                chapterLink: _listMangaLastChapters[index]),
                          ),
                        ).then(
                          (value) {
                            mangaZerServices.getListViewed().then((list) {
                              widget.viewedPageKey.currentState.setState(() {
                                listMangaViewed = list;
                              });
                            });
                          },
                        );
                      }
                    },
                    child: Text(
                        "Dernier: " + _listMangaLastChapters[index]["title"]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_controller != null) {
      _controller.addListener(() {
        if (_controller.page != null) {
          setState(() {
            currentPage = _controller.page;
          });
        }
      });
    }
    return currentPage != null
        ? GestureDetector(
            onTap: () {
              _showMangaDetails(currentPage.toInt());
            },
            child: Stack(
              children: <Widget>[
                CardScrollWidget(currentPage, widgetAspectRatio,
                    cardAspectRatio, _listMangaName),
                Positioned.fill(
                  child: PageView.builder(
                    itemCount: _listMangaName.length,
                    controller: _controller,
                    reverse: true,
                    itemBuilder: (context, index) {
                      return Container();
                    },
                  ),
                )
              ],
            ),
          )
        : Center(
            child: SpinKitDoubleBounce(color: Theme.of(context).primaryColor));
    return _listMangaName != null
        ? SizedBox(
            height: (MediaQuery.of(context).size.height / 5) + 50,
            child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      _showMangaDetails(index);
                    },
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                      child: Column(
                        children: [
                          Image.network(
                            "https://www.scan-1.net/uploads/manga/${_listMangaName[index]["href"]}/cover/cover_250x350.jpg",
                            height:
                                (MediaQuery.of(context).size.height / 5) + 30,
                          ),
                        ],
                      ),
                    ),
                  );
                },
                itemCount: _listMangaName.length),
          )
        : Center(
            child: SpinKitDoubleBounce(color: Theme.of(context).primaryColor));
  }
}
