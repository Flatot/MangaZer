import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mangazer/download/downloaded_chapter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DownloadedPage extends StatefulWidget {
  DownloadedPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _DownloadedPageState createState() => _DownloadedPageState();
}

class _DownloadedPageState extends State<DownloadedPage> {
  List<dynamic> listManga = [];

  Future<List<String>> getSP(pref) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> value = prefs.getStringList(pref);
    return value;
  }

  getSPKeys() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var value = prefs.getKeys().where((element) => element != "mode");
    return value;
  }

  _getListDownloaded() async {
    Stream<FileSystemEntity> list =
        (await getApplicationDocumentsDirectory()).list();
    list.forEach((element) async {
      if (await FileSystemEntity.isDirectory(element.path) &&
          element.path.indexOf("flutter_assets") == -1) {
        var arr = element.path.split('/');
        var mangaName = arr[arr.length - 1];
        setState(() {
          listManga.add(
              {"data": mangaName, "value": mangaName, "path": element.path});
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _getListDownloaded();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: ListView.builder(
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DownloadedChapterPage(
                            pathFolder: listManga[index]["path"],
                          ),
                        ),
                      );
                    },
                    child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 4.0),
                        child: Row(
                          children: [
                            CachedNetworkImage(
                              imageUrl:
                                  "https://www.scan-1.net/uploads/manga/${listManga[index]["data"]}/cover/cover_250x350.jpg",
                              height: MediaQuery.of(context).size.height / 3,
                              errorWidget: (context, url, error) {
                                listManga[index]["baseUrl"] = "www.scan-fr.cc";
                                return CachedNetworkImage(
                                  imageUrl:
                                      "https://www.scan-fr.cc/uploads/manga/${listManga[index]["data"]}/cover/cover_250x350.jpg",
                                  height:
                                      MediaQuery.of(context).size.height / 3,
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error_outline_sharp),
                                );
                              },
                            ),
                            SizedBox(
                              width: 25,
                            ),
                            Text(
                              listManga[index]["value"],
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        )),
                  );
                },
                itemCount: listManga.length),
          ),
        ],
      ),
    );
  }
}
