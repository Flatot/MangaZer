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
  List<Map<String, dynamic>> _resume;
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
      _resume = webScraper.getElement('.managa-summary > p', []);
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
      // CHECK LAST VIEWED CHAPTER
      for (var i = 0; i < _listChapters.length; i++) {
        if (lastViewedChapter == 0 && _listChapters[i]["viewed"] != true) {
          lastViewedChapter = i;
        }
      }
      // AUTO SCROLL TO LAST VIEWED
      _scrollController.animateTo(
        ((lastViewedChapter * 70).toDouble()),
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
            selectedManga: widget.selectedManga, chapterLink: _listLink[index]),
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

  // Widget bodyGrid(List<Menu> menu) => SliverGrid(
  //       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //         crossAxisCount: menu.length != 0
  //             ? (MediaQuery.of(context).orientation == Orientation.portrait
  //                 ? 2
  //                 : 3)
  //             : 1,
  //         mainAxisSpacing: 0.0,
  //         crossAxisSpacing: 0.0,
  //         childAspectRatio: 1.0,
  //       ),
  //       delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
  //         return (menu.length != 0)
  //             ? menuStack(context, menu[index], index)
  //             : Padding(
  //                 padding: EdgeInsets.all(16.0),
  //                 child: Text("No destination founded !",
  //                     style: TextStyle(
  //                         color: Theme.of(context).accentColor,
  //                         fontSize: 24.0)));
  //       }, childCount: menu.length != 0 ? menu.length : 1),
  //     );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: ClampingScrollPhysics(),
        shrinkWrap: true,
        slivers: <Widget>[
          SliverPersistentHeader(
            pinned: true,
            floating: true,
            delegate: MyDynamicHeader(
                mangaImgUrl:
                    "https://wwv.scan-1.com/uploads/manga/${widget.selectedManga["data"]}/cover/cover_250x350.jpg",
                mangaName: widget.selectedManga["data"]),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Container(
                // margin: EdgeInsets.only(top: 10),
                // padding: EdgeInsets.only(top: 30),
                // decoration: BoxDecoration(
                //   color: Theme.of(context).primaryColor,
                //   borderRadius: BorderRadius.only(
                //     topLeft: Radius.circular(48),
                //     topRight: Radius.circular(48),
                //   ),
                // ),
                // child: Padding(
                //     padding: EdgeInsets.symmetric(horizontal: 20.0),
                // child: Expanded(
                // child: ListView(
                //     physics: ClampingScrollPhysics(),
                //     shrinkWrap: true,
                //     children: <Widget>[
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
                          padding: EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 4.0),
                          child: Dismissible(
                            confirmDismiss: (direction) async {
                              if (direction == DismissDirection.startToEnd) {
                                _addToViewed(index);
                                return false;
                              } else if (direction ==
                                  DismissDirection.endToStart) {
                                return false;
                              }
                            },
                            key: UniqueKey(),
                            child: ListTile(
                              trailing: (_listChapters[index]["viewed"] !=
                                          null &&
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
                    itemCount:
                        _listChapters != null ? _listChapters.length : 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MyDynamicHeader extends SliverPersistentHeaderDelegate {
  int index = 0;
  String mangaName;
  String mangaImgUrl;

  MyDynamicHeader({this.mangaName, this.mangaImgUrl});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return LayoutBuilder(builder: (context, constraints) {
      if (shrinkOffset >= 300) {
        return AppBar(
          title: Text(mangaName),
          actions: [
            IconButton(
              icon: Icon(Icons.sort),
              tooltip: 'Changer le sens de la liste',
              onPressed: () {
                // setState(() {
                //   _listChapters = _listChapters.reversed.toList();
                //   _listLink = _listLink.reversed.toList();
                // });
              },
            )
          ],
        );
      }
      return Container(
        padding: EdgeInsets.only(top: 15),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(48),
            bottomRight: Radius.circular(48),
          ),
        ),
        height: constraints
            .maxHeight, // (MediaQuery.of(context).size.height * 0.30),
        child: Padding(
          padding: EdgeInsets.only(top: 24.0, left: 12, right: 12),
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Image.network(
                  mangaImgUrl,
                  width: (constraints.maxWidth / 3) + 30,
                ),
              ),
              Expanded(
                child: Text(
                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam porttitor scelerisque augue a porta. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla consequat velit nec facilisis dignissim. Aliquam volutpat ligula eget est sodales, eget fermentum felis consectetur. Donec accumsan placerat leo non consequat. Nam pretium malesuada tortor ut pulvinar. Praesent rutrum elit ex, ut feugiat sapien commodo in. Phasellus sit amet eros semper, ullamcorper est nec, varius nisl. Donec congue elementum dolor, quis elementum orci scelerisque nec. Vestibulum elementum egestas felis, porttitor eleifend massa aliquet imperdiet. Sed eleifend justo venenatis purus bibendum, non ultricies lorem gravida. Vestibulum venenatis porta felis, sit amet euismod eros tristique non. Nullam libero est, vehicula at condimentum ornare, hendrerit a diam. Nam commodo, dui vel imperdiet eleifend, lectus risus bibendum tellus, id porttitor velit magna sed ex. In cursus ornare lectus non tincidunt. Aliquam egestas, ligula eu ultrices suscipit, magna tortor auctor nisi, vel commodo ex odio id enim.",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate _) => true;

  @override
  double get maxExtent => 400.0;

  @override
  double get minExtent => 80.0;
}
