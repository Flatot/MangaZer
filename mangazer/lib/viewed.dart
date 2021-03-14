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
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                SelectedMangaPage(selectedManga: mangaSelected)));
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
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child:
                // GridView.count(
                //   crossAxisCount: 2,
                //   children: [
                ListView.builder(
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          _selectManga(listManga[index]);
                        },
                        child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 4.0),
                            child: Row(
                              children: [
                                Image.network(
                                  "https://wwv.scan-1.com/uploads/manga/${listManga[index]["data"]}/cover/cover_250x350.jpg",
                                  height:
                                      MediaQuery.of(context).size.height / 3,
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
            //   ],
            // ),
          ),
        ],
      ),
    );
  }
}
