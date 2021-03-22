import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mangazer/selected_manga.dart';
import 'package:web_scraper/web_scraper.dart';

import 'package:http/http.dart' as http;

class CatalogueSearchPage extends StatefulWidget {
  CatalogueSearchPage({Key key}) : super(key: key);

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
      final response = await http.get(
        Uri.https(baseUrl, '/search', {"query": query}),
        headers: {
          "Access-Control-Allow-Origin":
              "*", // Required for CORS support to work
          // "Access-Control-Allow-Credentials":
          //     true, // Required for cookies, authorization headers with HTTPS
          "Access-Control-Allow-Headers":
              "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale",
          "Access-Control-Allow-Methods": "POST, OPTIONS"
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          listManga = json.decode(response.body)["suggestions"];
        });
      } else {
        setState(() {
          listManga = [];
        });
      }
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

  Future<String> _loadResume(mangaRef) async {
    var webScraperUrl = "https://" + baseUrl;
    final webScraper = WebScraper(webScraperUrl);
    var webScraperPage =
        (baseUrl != "wwv.scan-1.com") ? "/manga/${mangaRef}" : "/${mangaRef}";
    if (await webScraper.loadWebPage(webScraperPage)) {
      var _resumeElement = webScraper.getElement('.well > p', []);
      if (_resumeElement.length > 0) {
        return _resumeElement[0]["title"];
      }
      return null;
    }
  }

  _showMangaDetails(index) async {
    Future<String> resume = _loadResume(listManga[index]["data"]);
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
                child: ListView.builder(
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
                                      (MediaQuery.of(context).size.height / 5) +
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
