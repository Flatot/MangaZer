import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mangazer/catalogue_search.dart';
import 'package:mangazer/catalogue.dart';
import 'package:mangazer/downloaded.dart';
import 'package:mangazer/selected_manga.dart';
import 'package:mangazer/viewed.dart';

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
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.green[700]),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(primary: Colors.green[700]),
          ),
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
      body: Center(
        child: Column(
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
        onPageChanged: (int) {},
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
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Container(
          height: 70,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(
                height: 75,
                width: MediaQuery.of(context).size.width / 2,
                child: Column(
                  children: [
                    IconButton(
                      iconSize: 30.0,
                      icon: _myPage.hasClients && _myPage.page == 0
                          ? Icon(
                              Icons.home,
                              color: Theme.of(context).primaryColorLight,
                            )
                          : Icon(Icons.home),
                      onPressed: () {
                        setState(() {
                          _myPage.jumpToPage(0);
                        });
                      },
                    ),
                    Text("Accueil")
                  ],
                ),
              ),
              // SizedBox(
              //   height: 75,
              //   width: MediaQuery.of(context).size.width / 2,
              //   child: Column(
              //     children: [
              //       IconButton(
              //         iconSize: 30.0,
              //         icon: _myPage.hasClients && _myPage.page == 1
              //             ? Icon(
              //                 Icons.menu_book,
              //                 color: Theme.of(context).primaryColorLight,
              //               )
              //             : Icon(Icons.menu_book),
              //         onPressed: () {
              //           setState(() {
              //             _myPage.jumpToPage(1);
              //           });
              //         },
              //       ),
              //       Text("Reading")
              //     ],
              //   ),
              // ),
              SizedBox(
                height: 75,
                width: MediaQuery.of(context).size.width / 2,
                child: Column(
                  children: [
                    IconButton(
                      iconSize: 30.0,
                      icon: _myPage.hasClients && _myPage.page == 1
                          ? Icon(
                              Icons.download_rounded,
                              color: Theme.of(context).primaryColorLight,
                            )
                          : Icon(Icons.download_rounded),
                      onPressed: () {
                        setState(() {
                          _myPage.jumpToPage(2);
                        });
                      },
                    ),
                    Text("Téléchargé")
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
