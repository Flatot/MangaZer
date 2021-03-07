import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mangazer/selected_manga.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MangaZer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
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
    final response =
        await http.get('https://wwv.scan-1.com/search?query=${query}');
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
              Container(
                child: TextFormField(
                  controller: _mangaSearch,
                  onChanged: _updateListManga,
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
                          child: Text(
                            listManga[index]["value"],
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      );
                    },
                    itemCount: listManga.length),
              ),
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
