import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mangazer/selected_chapter.dart';
import 'package:mangazer/selected_manga.dart';
import 'package:rating_bar/rating_bar.dart';
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

  _updateListManga(query) async {
    final response = await http.get(
      Uri.https('wwv.scan-1.com', '/search', {"query": query}),
      headers: {
        "Access-Control-Allow-Origin": "*", // Required for CORS support to work
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
  }

  @override
  void initState() {
    super.initState();
    _updateListManga("");
  }

  Future<String> _loadResume(mangaRef) async {
    final webScraper = WebScraper('https://wwv.scan-1.com');
    if (await webScraper.loadWebPage('/${mangaRef}')) {
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
                  "https://wwv.scan-1.com/uploads/manga/${listManga[index]["data"]}/cover/cover_250x350.jpg",
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
                  prefixIcon: Icon(Icons.search), hintText: "Search a manga"),
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
                              Image.network(
                                "https://wwv.scan-1.com/uploads/manga/${listManga[index]["data"]}/cover/cover_250x350.jpg",
                                height:
                                    (MediaQuery.of(context).size.height / 5) +
                                        30,
                              ),
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
