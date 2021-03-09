import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:mangazer/selected_manga.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MangaZer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.green[700],
        brightness: Brightness.dark,
      ),
      home: MyHomePage(title: 'MangaZer'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  PageController _myPage = PageController(initialPage: 0);
  TextEditingController _mangaSearch = TextEditingController();
  dynamic mangaSelected;
  List<dynamic> listManga = [];

  _updateListManga(query) async {
    final response = await http.get(
      Uri.https('wwv.scan-1.com', '/search', {"query": query}),
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

  _selectManga(elem) {
    mangaSelected = elem;
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                SelectedMangaPage(selectedManga: mangaSelected)));
  }

  @override
  void initState() {
    super.initState();
    _updateListManga("");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: PageView(
        controller: _myPage,
        onPageChanged: (int) {},
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Container(
                  child: TextFormField(
                    controller: _mangaSearch,
                    onChanged: _updateListManga,
                    decoration: InputDecoration(hintText: "Recherche un manga"),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
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
                                      MediaQuery.of(context).size.height / 5,
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
              )
            ],
          ),
          Center(
            child: Container(
              child: Text('Empty Body 1'),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Container(
          height: 75,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                iconSize: 30.0,
                padding: EdgeInsets.only(left: 28.0),
                icon: Icon(Icons.search),
                onPressed: () {
                  setState(() {
                    _myPage.jumpToPage(0);
                  });
                },
              ),
              IconButton(
                iconSize: 30.0,
                padding: EdgeInsets.only(right: 28.0),
                icon: Icon(Icons.file_download),
                onPressed: () {
                  setState(() {
                    _myPage.jumpToPage(1);
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
