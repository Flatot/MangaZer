import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mangazer/catalogue_search.dart';
import 'package:mangazer/catalogue.dart';
import 'package:mangazer/custom_splash_screen.dart';
import 'package:mangazer/theme/config.dart';
import 'package:mangazer/download/downloaded.dart';
import 'package:mangazer/theme/mangazer_theme.dart';
import 'package:mangazer/settings.dart';
import 'package:mangazer/view/viewed.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);
  //1
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State {
  getSettings() async {
    var theme = await getSP("theme");
    currentTheme.setTheme((theme != null && theme == 0) ? false : true);
  }

  getSP(pref) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var value = prefs.get(pref);
    return value;
  }

  @override
  void initState() {
    super.initState();
    getSettings();
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

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // class body of parent:
  final viewedPageKey = GlobalKey<ViewedPageState>();
  PageController _myPage = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Theme.of(context).scaffoldBackgroundColor,
        systemNavigationBarColor:
            Theme.of(context).bottomAppBarColor, // navigation bar color
        statusBarIconBrightness:
            Theme.of(context).brightness == Brightness.light
                ? Brightness.dark
                : Brightness.light,
      ),
      child: Scaffold(
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
                CatalogueSearchPage(viewedPageKey: viewedPageKey),
                Padding(
                  padding:
                      EdgeInsets.only(left: 8, right: 8, top: 24, bottom: 0),
                  child: Text(
                    "En cours",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                ViewedPage(key: viewedPageKey, title: "En cours"),
                Padding(
                  padding:
                      EdgeInsets.only(left: 8, right: 8, top: 24, bottom: 0),
                  child: Text(
                    "Top manga",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                Catalogue(viewedPageKey: viewedPageKey),
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
      ),
    );
  }
}
