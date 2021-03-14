import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:mangazer/downloaded.dart';
import 'package:mangazer/selected_manga.dart';
import 'package:mangazer/settings.dart';
import 'package:mangazer/viewed.dart';
import 'package:splashscreen/splashscreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'MangaZer',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Colors.green[700],
          primaryColorLight: Colors.green[400],
          accentColor: Colors.grey,
          brightness: Brightness.dark,
        ),
        home: CustomSplashScreen());
  }
}

class CustomSplashScreen extends StatefulWidget {
  CustomSplashScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _CustomSplashScreenState createState() => _CustomSplashScreenState();
}

class _CustomSplashScreenState extends State<CustomSplashScreen> {
  final timeout = Duration(seconds: 2);
  final ms = Duration(milliseconds: 1);

  void handleTimeout() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => MyHomePage(title: 'MangaZer'),
      ),
    );
  }

  Timer startTimeout([int milliseconds]) {
    var duration = milliseconds == null ? timeout : ms * milliseconds;
    return Timer(duration, handleTimeout);
  }

  @override
  void initState() {
    super.initState();
    startTimeout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            minRadius: 150,
            maxRadius: 250,
            backgroundImage: AssetImage("assets/splash_screen.png"),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text("MangaZer",
                style: Theme.of(context)
                    .textTheme
                    .headline2
                    .copyWith(color: Theme.of(context).primaryColor)),
          )
        ],
      ),
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
              listManga != null
                  ? Expanded(
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
                                            MediaQuery.of(context).size.height /
                                                5,
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
                  : Center(
                      child: SpinKitDoubleBounce(
                          color: Theme.of(context).primaryColor)),
            ],
          ),
          ViewedPage(
            title: "En cours",
          ),
          DownloadedPage(
            title: "Téléchargé",
          ),
          SettingsPage(
            title: "Paramètres",
          )
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
                padding: EdgeInsets.only(left: 56.0),
                icon: Icon(Icons.search),
                onPressed: () {
                  setState(() {
                    _myPage.jumpToPage(0);
                  });
                },
              ),
              IconButton(
                iconSize: 30.0,
                // padding: EdgeInsets.only(right: 28.0),
                icon: Icon(Icons.menu_book),
                onPressed: () {
                  setState(() {
                    _myPage.jumpToPage(1);
                  });
                },
              ),
              IconButton(
                iconSize: 30.0,
                // padding: EdgeInsets.only(right: 56.0),
                icon: Icon(Icons.download_rounded),
                onPressed: () {
                  setState(() {
                    _myPage.jumpToPage(2);
                  });
                },
              ),
              IconButton(
                iconSize: 30.0,
                padding: EdgeInsets.only(right: 56.0),
                icon: Icon(Icons.settings),
                onPressed: () {
                  setState(() {
                    _myPage.jumpToPage(3);
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
