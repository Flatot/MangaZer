import 'dart:async';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:mangazer/catalogue_search.dart';
import 'package:mangazer/catalogue.dart';
import 'package:mangazer/theme/config.dart';
import 'package:mangazer/downloaded.dart';
import 'package:mangazer/theme/mangazer_theme.dart';
import 'package:mangazer/selected_manga.dart';
import 'package:mangazer/settings.dart';
import 'package:mangazer/viewed.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);
  //1
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State {
  @override
  void initState() {
    super.initState();
    currentTheme.addListener(() {
      setState(() {
        currentTheme;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MangaZer',
      debugShowCheckedModeBanner: false,
      theme: MangaZerTheme.lightTheme,
      darkTheme: MangaZerTheme.darkTheme,
      themeMode: currentTheme.currentTheme,
      home: CustomSplashScreen(),
    );
  }
}

class CustomSplashScreen extends StatefulWidget {
  CustomSplashScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _CustomSplashScreenState createState() => _CustomSplashScreenState();
}

class _CustomSplashScreenState extends State<CustomSplashScreen> {
  final timeout = Duration(seconds: 4);
  final ms = Duration(milliseconds: 500);

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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: MediaQuery.of(context).size.height / 2,
              child: FlareActor("assets/akatsuki.flr",
                  alignment: Alignment.center,
                  fit: BoxFit.contain,
                  animation: "Animate"),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _myPage,
        onPageChanged: (int i) {
          setState(() {
            _myPage.jumpToPage(i);
          });
        },
        children: <Widget>[
          ListView(
            children: [
              CatalogueSearchPage(),
              Padding(
                padding: EdgeInsets.only(left: 8, right: 8, top: 24, bottom: 0),
                child: Text(
                  "En cours",
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              ViewedPage(title: "En cours"),
              Padding(
                padding: EdgeInsets.only(left: 8, right: 8, top: 24, bottom: 0),
                child: Text(
                  "Top manga",
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              Catalogue(),
            ],
          ),
          DownloadedPage(
            title: "Téléchargé",
          ),
          SettingsPage()
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Container(
          height: 60,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  setState(() {
                    _myPage.jumpToPage(0);
                  });
                },
                child: SizedBox(
                  height: 60,
                  width: MediaQuery.of(context).size.width / 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.home,
                        color: _myPage.hasClients && _myPage.page == 0
                            ? Theme.of(context).primaryColorLight
                            : Theme.of(context).accentColor,
                        size: 30,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text("Accueil")
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _myPage.jumpToPage(1);
                  });
                },
                child: SizedBox(
                  height: 60,
                  width: MediaQuery.of(context).size.width / 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.download_rounded,
                        color: _myPage.hasClients && _myPage.page == 1
                            ? Theme.of(context).primaryColorLight
                            : Theme.of(context).accentColor,
                        size: 30,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text("Téléchargé")
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _myPage.jumpToPage(2);
                  });
                },
                child: SizedBox(
                  height: 60,
                  width: MediaQuery.of(context).size.width / 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.settings,
                        color: _myPage.hasClients && _myPage.page == 2
                            ? Theme.of(context).primaryColorLight
                            : Theme.of(context).accentColor,
                        size: 30,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text("Paramètres")
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
