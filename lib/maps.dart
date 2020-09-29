import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dingdrink/global.dart';
import 'package:dingdrink/localize.dart';
import 'package:flutter/services.dart';

class Maps {
  String keyword;
  int id;
  String autocompleteterm;
  int open;

  Maps({
    this.keyword,
    this.id,
    this.autocompleteterm,
    this.open
  });

  factory Maps.fromJson(Map<String, dynamic> parsedJson) {
    return Maps(
        keyword: parsedJson['keyword'] as String,
        id: int.parse(parsedJson['id']),
        autocompleteterm: parsedJson['short_name'] as String,
        open: int.parse(parsedJson['open'] )
    );
  }
}

class MapsViewModel {
  static List<Maps> maps;

  static Future loadMaps() async {
    try {
      maps = new List<Maps>();
//      String jsonString = await rootBundle.loadString('assets/players.json');
      String jsonString = await fetchMaps();
      List parsedJson = json.decode(jsonString);
//      var categoryJson = parsedJson['maps'] as List;
      for (int i = 0; i < parsedJson.length; i++) {
        maps.add(new Maps.fromJson(parsedJson[i]));
      }
    } catch (e) {
      print(e); print(e.source);
    }
  }

  static Future<String> fetchMaps()  async {
    var s = globalURL + 'index.php?lang='+globalLanguage+'&ops=getVendors';
    final response = await http.get(s);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response, then parse the JSON.
      var responseJson = json.decode(response.body);
      var r = responseJson;
//      var rc = Catalog.fromJson(r[0]);
      //print("***************************products fetched");
      return response.body;
    } else {print("http error: " + response.statusCode.toString());
    // If the server did not return a 200 OK response, then throw an exception.
    throw Exception('Failed to load merchand');

    }
  }

}
