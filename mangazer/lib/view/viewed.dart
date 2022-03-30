import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mangazer/theme/config.dart';
import 'package:mangazer/view/selected_manga.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewedPage extends StatefulWidget {
  ViewedPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  ViewedPageState createState() => ViewedPageState();
}

class ViewedPageState extends State<ViewedPage> {
  PageController _myPage = PageController(initialPage: 0);
  TextEditingController _mangaSearch = TextEditingController();
  dynamic mangaSelected;

  Future<List<String>> getSP(pref) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> value = prefs.getStringList(pref);
    return value;
  }

  _selectManga(elem) {
    mangaSelected = elem;
    var baseUrl = elem["baseUrl"] != null ? elem["baseUrl"] : "www.scan-1.net";
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SelectedMangaPage(baseUrl: baseUrl, selectedManga: mangaSelected),
      ),
    ).then(
      (value) {
        mangaZerServices.getListViewed().then((list) {
          setState(() {
            listMangaViewed = list;
          });
        });
      },
    );
  }

  deleteFromSp(index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(listMangaViewed[index]["data"]).then((value) {
      if (value) {
        mangaZerServices.getListViewed().then((list) {
          setState(() {
            listMangaViewed = list;
          });
        });
      }
    });
  }

  _showDialogDelete(index) {
    if (Platform.isIOS) {
      showDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: Text("Oublier ce manga ?"),
          content: Text("Voulez-vous supprimer les données de ce manga ?"),
          actions: <Widget>[
            CupertinoDialogAction(
                child: Text(
                  "Non",
                  style: TextStyle(color: Theme.of(context).accentColor),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            CupertinoDialogAction(
                child: Text("Oui",
                    style:
                        TextStyle(color: Theme.of(context).primaryColorLight)),
                onPressed: () {
                  deleteFromSp(index);
                  Navigator.of(context).pop();
                })
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Oublier ce manga ?"),
          content: Text("Voulez-vous supprimer les données de ce manga ?"),
          elevation: 24.0,
          actions: <Widget>[
            TextButton(
                child: Text(
                  "Non",
                  style: TextStyle(color: Theme.of(context).accentColor),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            TextButton(
                child: Text(
                  "Oui",
                  style: TextStyle(color: Theme.of(context).primaryColorLight),
                ),
                onPressed: () {
                  deleteFromSp(index);
                  Navigator.of(context).pop();
                })
          ],
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    mangaZerServices.getListViewed().then((list) {
      setState(() {
        listMangaViewed = list;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: (listMangaViewed != null && listMangaViewed.length == 0)
          ? 0
          : (MediaQuery.of(context).size.height / 3) + 24,
      child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                _selectManga(listMangaViewed[index]);
              },
              onLongPress: () {
                _showDialogDelete(index);
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                child: Column(
                  children: [
                    CachedNetworkImage(
                      imageUrl:
                          "https://www.scan-1.net/uploads/manga/${listMangaViewed[index]["data"]}/cover/cover_250x350.jpg",
                      height: MediaQuery.of(context).size.height / 3,
                      errorWidget: (context, url, error) {
                        listMangaViewed[index]["baseUrl"] = "www.scan-fr.cc";
                        return CachedNetworkImage(
                          imageUrl:
                              "https://www.scan-fr.cc/uploads/manga/${listMangaViewed[index]["data"]}/cover/cover_250x350.jpg",
                          height: MediaQuery.of(context).size.height / 3,
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error_outline_sharp),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
          itemCount: listMangaViewed.length),
    );
  }
}
