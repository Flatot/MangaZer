import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mangazer/selected_manga.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewedPage extends StatefulWidget {
  ViewedPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ViewedPageState createState() => _ViewedPageState();
}

class _ViewedPageState extends State<ViewedPage> {
  PageController _myPage = PageController(initialPage: 0);
  TextEditingController _mangaSearch = TextEditingController();
  dynamic mangaSelected;
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

  _selectManga(elem) {
    mangaSelected = elem;
    var baseUrl = elem["baseUrl"] != null ? elem["baseUrl"] : "wwv.scan-1.com";
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SelectedMangaPage(
                baseUrl: baseUrl, selectedManga: mangaSelected)));
  }

  _getListViewed() async {
    Iterable<String> keys = await getSPKeys();
    keys.forEach((key) {
      setState(() {
        listManga.add({"data": key, "value": key});
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _getListViewed();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: (listManga != null && listManga.length == 0)
          ? 0
          : (MediaQuery.of(context).size.height / 3) + 24,
      child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                _selectManga(listManga[index]);
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                child: Column(
                  children: [
                    CachedNetworkImage(
                      imageUrl:
                          "https://wwv.scan-1.com/uploads/manga/${listManga[index]["data"]}/cover/cover_250x350.jpg",
                      height: MediaQuery.of(context).size.height / 3,
                      errorWidget: (context, url, error) {
                        listManga[index]["baseUrl"] = "www.scan-fr.cc";
                        return CachedNetworkImage(
                          imageUrl:
                              "https://www.scan-fr.cc/uploads/manga/${listManga[index]["data"]}/cover/cover_250x350.jpg",
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
          itemCount: listManga.length),
    );
  }
}
