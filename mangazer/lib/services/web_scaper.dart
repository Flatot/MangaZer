import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_scraper/web_scraper.dart';
import 'package:http/http.dart' as http;

class MangaZerServices {
  Future<String> loadResume(baseUrl, mangaRef) async {
    var webScraperUrl = "https://" + baseUrl;
    final webScraper = WebScraper(webScraperUrl);
    var webScraperPage =
        (baseUrl != "wwv.scan-1.com") ? "/manga/${mangaRef}" : "/${mangaRef}";
    webScraper.loadWebPage(webScraperPage).then((value) {
      if (value) {
        var _resumeElement = webScraper.getElement('.well > p', []);
        if (_resumeElement.length > 0) {
          return _resumeElement[0]["title"];
        }
        return null;
      }
    });
  }

  Future<dynamic> searchInCatalogue(baseUrl, query) async {
    final response = await http.get(
      Uri.https(baseUrl, '/search', {"query": query}),
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
      return json.decode(response.body)["suggestions"];
    } else {
      return [];
    }
  }

  getSPKeys() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var value = prefs
        .getKeys()
        .where((element) => element != "mode" && element != "theme");
    return value;
  }

  Future<List<dynamic>> getListViewed() async {
    List<dynamic> list = [];
    Iterable<String> keys = await getSPKeys();
    keys.forEach((key) {
      list.add({"data": key, "value": key});
    });
    return list;
  }
}
