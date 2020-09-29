import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dingdrink/localize.dart';
import 'package:dingdrink/global.dart';

List<Entry> catalogData;
Catalog globalCatalog;

class Entry {
  Entry({this.productId, this.title, this.children = const <Entry>[]});
  String productId;
  String title;
  List<Entry> children;

} // class Entry

class EntryDetail extends Entry {
  int count = 0;
  double price;
  EntryDetail({productId, title, price}) :
        this.price = double.parse(price),
        super(productId: productId, title:title, children: <Entry>[]);
  //@override
  void increment() {
    count++;
    //print(title + ' ' + count.toString());
    //notifyListeners();
  }

  //@override
  void decrement() {
    count--;
    //print(title + ' ' + count.toString());
   // notifyListeners();
  }

//  @override
  double getPrice() => (price);
// @override
  int getCount() => (count);
} //EntryDetail

Catalog catalog;


Future<Catalog> fetchProducts(int myVendorId)  async {
  //print(globalLanguage);
  //if (globalLocContext != null )globalLanguage = AppLocalizations.of(globalLocContext).locale.languageCode;
  var s = globalURL + 'index.php?ops=loadCatalog&lang=$globalLanguage&vendor=$myVendorId';
  final response =
  //await http.get('http://it-cs.be/1easy/index.php?ops=loadCatalog&lang=$globalLanguage&vendor=$myVendorId');
  await http.get(s);
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response, then parse the JSON.
    //print(response.body);
    var responseJson = json.decode(response.body);
    var r = responseJson;
    //  var rc =  (responseJson as List)
    //      .map((p) => Product.fromJson(p))
    //      .toList();

    //print(r[0]);
    var rc = Catalog.fromJson(r[0]);
    //print("***************************products fetched");
    return rc;
  } else {print("http error: " + response.statusCode.toString());
    // If the server did not return a 200 OK response, then throw an exception.
    throw Exception('Failed to load merchand');

  }
}

class Catalog with ChangeNotifier {
  var data = <Entry>[]; // = Entry[];
  Catalog(this.data);

  factory Catalog.fromJson(List< dynamic> json) {
    var entries = <Entry>[];

    for (int i=0; i< json.length; i++){
      //print(json[i]['title']);
      if (json[i]['price'] == null) {   // not a product (EntryDetail), but a category (Entry)
        var entry = Entry(title: json[i]['title']); //(json[0][i][0][2]);
        if ( json[i]['children'].length >0) {
          var childEntry = Catalog.fromJson(json[i]['children']);
          //entry.children.add(childEntry.data[0]);
          entry.children = childEntry.data;
        }

        entries.add(entry);
      }
      else {
        var entryDetail = EntryDetail(productId: json[i]['id'],  title: json[i]['title'], price: json[i]['price']);//
        entries.add(entryDetail);
      }
    }
    var cat = Catalog(entries);   globalCatalog=cat;

    return cat; // Catalog(entries);
  }

  void setLanguage(String myLanguage) { //print('in setLanguage glob lang=' + globalLanguage);
  globalLanguage = myLanguage;
  notifyListeners();
  }
  void rebuildMe() {
    //print('in rebuildMe glob lang=' + globalLanguage);
    notifyListeners();
  }

  void resetAmount( entries){
    for (int i=0; i<  entries.length; i++){
      if ( entries[i] is EntryDetail) { // a product (EntryDetail), not a category (Entry)
        EntryDetail ed = entries[i];
        ed.count = 0;
      }
      else {  //  not a product (EntryDetail), but a category (Entry)
        Entry ec = entries[i];
        resetAmount(ec.children);

      }
     }  //for
    notifyListeners();
  } // resetAmount( entries)

  } // class Catalog

class Product {
  final String id;
  final String title;
  final String description;
  final String price;
  final dynamic children;

  Product({this.id, this.title, this.description, this.price, this.children});

}

