import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mangazer/theme/config.dart';
import 'package:mangazer/view/selected_manga.dart';
import 'package:mangazer/view/viewed.dart';

class CatalogueSearchPage extends StatefulWidget {
  CatalogueSearchPage({Key key, this.viewedPageKey}) : super(key: key);

  GlobalKey<ViewedPageState> viewedPageKey;

  @override
  _CatalogueSearchPageState createState() => _CatalogueSearchPageState();
}

class _CatalogueSearchPageState extends State<CatalogueSearchPage> {
  TextEditingController _mangaSearch = TextEditingController();
  List<dynamic> listManga = null;
  Timer _debounce;
  var baseUrl = "wwv.scan-1.com";

  _updateListManga(query) {
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 700), () async {
      mangaZerServices.searchInCatalogue(baseUrl, query).then((res) {
        setState(() {
          listManga = res;
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _updateListManga("");
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  _showMangaDetails(index) async {
    Future<String> resume =
        mangaZerServices.loadResume(baseUrl, listManga[index]["data"]);
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.4 + 20,
          child: Padding(
            padding: EdgeInsets.only(top: 12, left: 24, right: 24),
            child: Row(
              children: [
                Image.network(
                  "https://${baseUrl}/uploads/manga/${listManga[index]["data"]}/cover/cover_250x350.jpg",
                  height: (MediaQuery.of(context).size.height * 0.3) + 20,
                ),
                Flexible(
                  child: Container(
                    height: (MediaQuery.of(context).size.height * 0.4) - 40,
                    child: Padding(
                      padding: EdgeInsets.only(left: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 12, bottom: 12),
                            child: Text(
                              listManga[index]["value"],
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SelectedMangaPage(
                                      baseUrl: baseUrl,
                                      selectedManga: listManga[index]),
                                ),
                              ).then(
                                (value) {
                                  mangaZerServices.getListViewed().then((list) {
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Container(
            child: TextFormField(
              controller: _mangaSearch,
              onChanged: _updateListManga,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Rechercher un manga",
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      if (baseUrl == "wwv.scan-1.com") {
                        baseUrl = "www.scan-fr.cc";
                      } else {
                        baseUrl = "wwv.scan-1.com";
                      }
                    });
                    _updateListManga(_mangaSearch.text);
                  },
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  icon: Icon(Icons.swap_vert_circle_sharp),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 8, right: 8, top: 24, bottom: 0),
          child: Text(
            "Tendances",
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        listManga != null
            ? SizedBox(
                height: (MediaQuery.of(context).size.height / 5) + 50,
                child: listManga.length == 0
                    ? Row(
                        children: [
                          Container(
                            height:
                                (MediaQuery.of(context).size.height / 5) + 50,
                            width: (MediaQuery.of(context).size.width / 2),
                            child: FlareActor("assets/akatsuki.flr",
                                alignment: Alignment.center,
                                fit: BoxFit.contain,
                                animation: "Animate"),
                          ),
                          Text(
                            "Aucun résultat",
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              _showMangaDetails(index);
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 4.0),
                              child: Column(
                                children: [
                                  CachedNetworkImage(
                                      imageUrl:
                                          "https://${baseUrl}/uploads/manga/${listManga[index]["data"]}/cover/cover_250x350.jpg",
                                      height:
                                          (MediaQuery.of(context).size.height /
                                                  5) +
                                              30,
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error_outline_sharp)),
                                ],
                              ),
                            ),
                          );
                        },
                        itemCount: listManga.length),
              )
            : Center(
                child:
                    SpinKitDoubleBounce(color: Theme.of(context).primaryColor),
              ),
      ],
    );
  }
}
