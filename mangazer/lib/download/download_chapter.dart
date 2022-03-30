import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:web_scraper/web_scraper.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class DownloadChapterPage extends StatefulWidget {
  DownloadChapterPage(
      {Key key,
      this.selectedManga,
      this.selectedChapter,
      this.chapterLink,
      this.baseUrl})
      : super(key: key);

  final dynamic selectedManga;
  final dynamic selectedChapter;
  final dynamic chapterLink;
  final String baseUrl;

  @override
  _DownloadChapterPageState createState() => _DownloadChapterPageState();
}

class _DownloadChapterPageState extends State<DownloadChapterPage> {
  List<String> _listPage;
  List<String> listImages = [];
  double dlPercentage = 0.1;

  @override
  void initState() {
    super.initState();

    checkPermission();
    final pdf = pw.Document();
    loadChapterData(pdf);
  }

  checkPermission() async {
    if (Platform.isAndroid || Platform.isIOS) {
      if (!await Permission.storage.request().isGranted) {
        Navigator.pop(context);
        return;
      }
    }
  }

  loadChapterData(pw.Document pdf) async {
    final webScraper = WebScraper('https://${widget.baseUrl}');
    var route = widget.chapterLink["attributes"]["href"];
    route = route.split("https://${widget.baseUrl}")[1];
    List<Map<String, dynamic>> strPages;
    webScraper.loadWebPage(route).then((value) {
      if (value) {
        strPages = webScraper.getElement('.selectpicker', []);
        for (var i = 0; i < strPages.length; i++) {
          strPages[i]["title"] = strPages[i]["title"].trim();
        }
        setState(() {
          _listPage = strPages[0]["title"].split(new RegExp(r"(\s)+"));
        });
        List<Future<String>> futuresArr = [];
        for (var i = 0; i < _listPage.length; i++) {
          futuresArr.add(getImage(int.parse(_listPage[i])));
        }
        Future.wait(futuresArr).then((value) {
          setState(() {
            dlPercentage = 0.3;
          });
          List<Future<ByteData>> futuresBytesArr = [];
          for (var x = 0; x < value.length; x++) {
            if (value[x] != null) {
              futuresBytesArr
                  .add(NetworkAssetBundle(Uri.parse(value[x])).load(value[x]));
            }
          }
          Future.wait(futuresBytesArr).then((value) async {
            setState(() {
              dlPercentage = 0.7;
            });
            for (var n = 0; n < value.length; n++) {
              Uint8List bytes = value[n].buffer.asUint8List();
              pdf.addPage(
                pw.Page(
                  pageFormat: PdfPageFormat.a4,
                  build: (pw.Context context) {
                    return pw.Center(
                      child: pw.Image(
                        pw.MemoryImage(bytes),
                      ),
                    );
                  },
                ),
              );
            }
            setState(() {
              dlPercentage = 0.99;
            });
            String dir = (await getApplicationDocumentsDirectory()).path;
            var folderName = route.split('/')[1];
            var chapterName = route.split('/')[2];
            if (widget.baseUrl != "www.scan-1.net") {
              folderName = route.split('/')[2];
              chapterName = route.split('/')[3];
            }
            Directory _appDocDirFolder = Directory('$dir/$folderName/');
            if (!await _appDocDirFolder.exists()) {
              //if folder not exists create folder
              _appDocDirFolder = await _appDocDirFolder.create(recursive: true);
            }
            var pdfBytes = await pdf.save();
            File file = File("${_appDocDirFolder.path}${chapterName}.pdf");
            file = await file.writeAsBytes(pdfBytes);

            if (await file.exists()) {
              Navigator.of(context).pop();
            }
          });
        });
      }
    });
  }

  pad(int data, int limit) {
    String res = data.toString();
    while (data < limit) {
      res = ("0" + res.toString());
      data = data * 10;
    }
    return res;
  }

  Future<String> getImage(page) async {
    var route = widget.chapterLink["attributes"]["href"];
    route = route.split("https://${widget.baseUrl}")[1];
    var manga = route.split("/")[1];
    var chapter = route.split("/")[2];
    var currentPage = (page >= 1 && page <= 9) ? "0" + page.toString() : page;

    if (widget.baseUrl != "www.scan-1.net") {
      manga = route.split("/")[2];
      chapter = route.split("/")[3];
      chapter = pad(int.parse(chapter), 1000);
      currentPage = pad(int.parse(currentPage.toString()), 100);
    }

    final response = await http.head(Uri.https("${widget.baseUrl}",
        "/uploads/manga/$manga/chapters/$chapter/$currentPage.jpg"));

    if (response.statusCode == 200) {
      return "https://${widget.baseUrl}/uploads/manga/$manga/chapters/$chapter/$currentPage.jpg";
    } else {
      final responsePng = await http.head(Uri.https("${widget.baseUrl}",
          "/uploads/manga/$manga/chapters/$chapter/$page.png"));
      if (responsePng.statusCode == 200) {
        return "https://${widget.baseUrl}/uploads/manga/$manga/chapters/$chapter/$currentPage.png";
      } else {
        return null;
      }
    }
  }

  Future<List<String>> getSP(pref) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> value = prefs.getStringList(pref);
    return value;
  }

  setSP(String key, List<String> value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectedManga["value"]),
      ),
      body: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
          value: dlPercentage,
        ),
      ),
    );
  }
}
