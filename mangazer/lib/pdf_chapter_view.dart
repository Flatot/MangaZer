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

class PdfChapterViewPage extends StatefulWidget {
  PdfChapterViewPage({Key key, this.pdfFile}) : super(key: key);

  final File pdfFile;

  @override
  _PdfChapterViewPageState createState() => _PdfChapterViewPageState();
}

class _PdfChapterViewPageState extends State<PdfChapterViewPage> {
  File pdfFile;

  @override
  void initState() {
    super.initState();

    checkPermission();
  }

  checkPermission() async {
    if (!await Permission.storage.request().isGranted) {
      Navigator.pop(context);
      return;
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
      body: FutureBuilder(
        future: pdfFile?.exists(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return PDFViewerScaffold(path: pdfFile.path);
          }
          return SpinKitDoubleBounce(
            color: Theme.of(context).primaryColor,
          );
        },
      ),
    );
  }
}
