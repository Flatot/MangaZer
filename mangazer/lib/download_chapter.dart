import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:web_scraper/web_scraper.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class DownloadChapterPage extends StatefulWidget {
  DownloadChapterPage(
      {Key key, this.selectedManga, this.selectedChapter, this.chapterLink})
      : super(key: key);

  final dynamic selectedManga;
  final dynamic selectedChapter;
  final dynamic chapterLink;

  @override
  _DownloadChapterPageState createState() => _DownloadChapterPageState();
}

class _DownloadChapterPageState extends State<DownloadChapterPage> {
  List<String> _listPage;
  List<String> listImages = [];

  @override
  void initState() {
    super.initState();

    checkPermission();
    final pdf = pw.Document();
    loadChapterData(pdf);
  }

  checkPermission() async {
    if (!await Permission.storage.request().isGranted) {
      Navigator.pop(context);
      return;
    }
  }

  loadChapterData(pw.Document pdf) async {
    final webScraper = WebScraper('https://wwv.scan-1.com');
    var route = widget.chapterLink["attributes"]["href"];
    route = route.split("https://wwv.scan-1.com")[1];
    List<Map<String, dynamic>> strPages;
    if (await webScraper.loadWebPage(route)) {
      strPages = webScraper.getElement('.selectpicker', []);
    }
    for (var i = 0; i < strPages.length; i++) {
      strPages[i]["title"] = strPages[i]["title"].trim();
    }
    setState(() {
      _listPage = strPages[0]["title"].split(new RegExp(r"(\s)+"));
    });
    for (var i = 0; i < _listPage.length; i++) {
      var imgUrl = await getImage(int.parse(_listPage[i]));
      // var image = NetworkImage(imgUrl);
      // ImageProvider provider = NetworkImage(imgUrl);
      // Uint8List yourVar;
      // final DecoderCallback callback = (Uint8List bytes,
      //     {bool allowUpScaling, int cacheWidth, int cacheHeight}) {
      //   yourVar = bytes.buffer.asUint8List();
      //   return instantiateImageCodec(bytes,
      //       targetWidth: cacheWidth, targetHeight: cacheHeight);
      // } as DecoderCallback;
      // ImageProvider provider = NetworkImage(yourImageUrl);
      // provider.obtainKey(createLocalImageConfiguration(context)).then((key) {
      //   provider.load(key, callback);
      // });
      Uint8List bytes =
          (await NetworkAssetBundle(Uri.parse(imgUrl)).load(imgUrl))
              .buffer
              .asUint8List();
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
    String dir = (await getApplicationDocumentsDirectory()).path;
    var folderName = route.split('/')[1];
    var chapterName = route.split('/')[2];
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
  }

  getImage(page) async {
    var route = widget.chapterLink["attributes"]["href"];
    route = route.split("https://wwv.scan-1.com")[1];
    var manga = route.split("/")[1];
    var chapter = route.split("/")[2];
    var currentPage = (page >= 1 && page <= 9) ? "0" + page.toString() : page;

    final response = await http.head(Uri.https("wwv.scan-1.com",
        "/uploads/manga/$manga/chapters/$chapter/$currentPage.jpg"));

    if (response.statusCode == 200) {
      return "https://wwv.scan-1.com/uploads/manga/$manga/chapters/$chapter/$currentPage.jpg";
    } else {
      final responsePng = await http.head(Uri.https("wwv.scan-1.com",
          "/uploads/manga/$manga/chapters/$chapter/$page.png"));
      if (responsePng.statusCode == 200) {
        return "https://wwv.scan-1.com/uploads/manga/$manga/chapters/$chapter/$currentPage.png";
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
      body: SpinKitDoubleBounce(
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}
