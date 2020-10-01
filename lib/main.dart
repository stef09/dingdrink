//modified on 25/05/2020 by sg
// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:dingdrink/cart.dart';
import 'dart:convert';

//import 'package:easy/global.dart';
import 'package:dingdrink/catalog.dart';
import 'package:dingdrink/global.dart';
import 'package:dingdrink/mapsPage.dart';
import 'package:dingdrink/push_nofitications.dart';

import 'package:dingdrink/localize.dart';

//bool globalOrdered = false;
var globalPush;
 
//begin test
FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
//end test


//ListModel listModel;  //should not be  a global object
BuildContext globalContext;

class ExpansionTileCatalog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    globalPush = PushNotificationsManager().init();


    var ic, col, tooltip;
    var mapName = "";
    if (globalOrdered) {
      ic = Icon(Icons.hourglass_full);
      col = Colors.yellow;
      tooltip = "Préparation";
    } else {
      ic = Icon(Icons.hourglass_empty);
      col = Colors.white;
      tooltip = "Pas de commande en cours";
    }
      if (globalBUpdate) {
        mapName = AppLocalizations.of(context).localized('updateAppTitle');
      }
      else {
        if (globalVendorId == -1) {
          //mapName = AppLocalizations.of(context).catalogTitle + '\n' + AppLocalizations.of(context).selectMap;
          mapName =
              AppLocalizations.of(context).localized('catalogTitle') + '\n' +
                  AppLocalizations.of(context).localized('selectMap');
        }
        else {
          mapName =
              AppLocalizations.of(context).localized('catalogTitle') + '\n' +
                  globalVendorShortName;
        }
      }
        //Future<Catalog> fc;
        // fc = fetchProducts();
        return Scaffold(
          appBar: AppBar(
              title: Text(mapName),
              actions: [
                IconButton(
                  icon: Icon(Icons.map),
                  onPressed: () {
                    if (!globalBUpdate) {
                      navigateToMapsPage(context);
                    }
                  },
                ),
                IconButton(
                  icon: Icon(Icons.shopping_cart),
                  onPressed: () {
                    if (!globalBUpdate) {
                      navigateToCartPage(context, globalCatalog.data);
                    }
                  },
                ),
/*            IconButton(
              icon: ic,
              color: col,
              onPressed: () {
                // display list of orders
              },
            ),
 */         ]),
          body: body(context, globalBUpdate),
          // ),
          //),
        );
      }
 // }
}

body(BuildContext context, bool bUpdate){
  if (globalBUpdate) {
    return Text( AppLocalizations.of(context).localized('updateApp'));
  }
  else {
    if (globalVendorId == -1) {
      return Text(AppLocalizations.of(context).localized('selectMapDetail'));
    }
    else {
      return ListView.builder(
        itemBuilder: (BuildContext context, int index) =>
            EntryItem(globalCatalog.data[index]),
        itemCount: globalCatalog.data.length,
      );
    }
  }
}


Future navigateToMapsPage(context) async {
  //final myContext = context;
  final result = await Navigator.push(
      context, MaterialPageRoute(builder: (context) => MapsPage()));
  //ModalRoute.of(context);

  if (result != null) {
    globalOrdered = true;
    //globalCatalog.resetAmount(globalCatalog.data);
    Scaffold.of(globalContext)
        .showSnackBar(SnackBar(content: Text(result.toString())));
  }
}

Future navigateToCartPage(context, catalogData) async {
  //final myContext = context;
  final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CartPage(catalogData: catalogData)));
  //ModalRoute.of(context);

  if (result != null) {
    globalOrdered = true;
    //globalCatalog.resetAmount(globalCatalog.data);
    Scaffold.of(globalContext)
        .showSnackBar(SnackBar(content: Text(result.toString())));
  }
}

// Displays one Entry. If the entry has children then it's displayed
// with an ExpansionTile.
class EntryItem extends StatelessWidget {
  EntryItem(this.entry);

  final Entry entry;

//BuildContext ctx;

  Widget _buildTiles(Entry root) {
    String myText;
    myText = root.title;
    // String myCount = root.getCount();

    if (root is EntryDetail) {
      EntryDetail myDetail = root;
      //(root.children.isEmpty) {
      //print(root.title + myDetail.getCount().toString());

      return Row(

          //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              flex: 6,
              child: Text(myText, textDirection: TextDirection.ltr),
            ),
            Expanded(
              flex: 2,
              child: Text(
                myDetail.getPrice().toStringAsFixed(2) + " €",
                textDirection: TextDirection.rtl,
              ),
            ),
            Expanded(
              flex: 2,
              child: Consumer<Catalog>(
                builder: (context, lm, child) => IconButton(
                  icon: Icon(Icons.remove_circle_outline, size: 25),
                  onPressed: () {
                    if (myDetail.getCount() > 0) {
                      myDetail.decrement();
                      lm.rebuildMe();
                    }
                  },
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Consumer<Catalog>(builder: (context, lm, child) {
                // lm.rebuildMe();
                return Text(root.getCount().toString());
              }),
            ),
            Expanded(
              flex: 1,
              child: Consumer<Catalog>(
                builder: (context, lm, child) => IconButton(
                  icon: Icon(Icons.add_circle_outline, size: 25),
                  onPressed: () {
                    root.increment();
                    lm.rebuildMe();
                    //  Scaffold.of(context).showSnackBar(new SnackBar(content:
                    //   Text( root.title + 'decremented' + ' ' + root.getCount())));
                  },
                ),
              ),
            ),
          ]
          //  )
          );
    } // if
    return ExpansionTile(
      key: PageStorageKey<Entry>(root),
      title: Text(root.title),
      children: root.children.map(_buildTiles).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    globalContext = context;

    ///need to show snackbar afetr cart page
    ///

    return _buildTiles(entry);
  }
} //class EntryItem

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();




}

class _MyAppState extends State<MyApp> {
  Future<Catalog> futureCatalog;
  String language;






  /* int vendorId = 1;

  int getVendorId() {
    // will be changed when user will select a vendor in a list
    return (vendorId);
    ;
  }
*/
  @override
  void initState() {
    super.initState();
    //globalLanguage = "nl";
    //begin test
    var androidInitSettings = new AndroidInitializationSettings('mipmap/ic_launcher');
    var iosInitSettings = new IOSInitializationSettings();
    var initSettings = new InitializationSettings(androidInitSettings, iosInitSettings);

    Future<String> sUpdate =  checkForUpdate();
    //return Text(AppLocalizations.of(context).localized('updateApp'));
/*    var s =  sUpdate.toString();
    if (s == "needed"){
      globalBUpdate = true;
    }
    else{
      globalBUpdate = false;
    }

*/

    flutterLocalNotificationsPlugin.initialize(initSettings);

    firebaseMessaging.configure(
      onLaunch: (Map<String, dynamic> msg) {
        print(" onLaunch called ${(msg)}");
      },
      onResume: (Map<String, dynamic> msg) {
        print(" onResume called ${(msg)}");
      },
      onMessage: (Map<String, dynamic> msg) {
        // set up the AlertDialog
        AlertDialog alert = AlertDialog(
          title: Text(msg['notification']['title']),
          content: Text(msg['notification']['body']),
          actions: [
             FlatButton(
              child: Text("OK"),
               onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
              )
          ],
        );

        // show the dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return alert;
          },
        );
        print(" onMessage called ${(msg)}");
      },
    );
    firebaseMessaging.requestNotificationPermissions(const IosNotificationSettings(sound: true, alert: true, badge: true));
    firebaseMessaging.onIosSettingsRegistered.listen((IosNotificationSettings setting) {
      print('IOS Setting Registed');
    });
    firebaseMessaging.getToken().then((token) {
      //update(token);
    });
    // end test





    futureCatalog = fetchProducts(globalVendorId);
  }

  void changeLanguage() {
    if (appLanguage == globalLanguage) {
    } else {
      setState(() {
        globalLanguage = appLanguage;
        futureCatalog = fetchProducts(globalVendorId);
        print('state');
      });
    }
  }

/*  checkForUpdate returns possibily:
  "needed"
  "recommanded"
  "no"
  */


  @override
  Widget build(BuildContext ctxt) {
    //listModel = ListModel();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      changeLanguage();

      //ordered();
    });

    return MaterialApp(
        onGenerateTitle: (BuildContext context) {





          return AppLocalizations.of(context).localized('catalogTitle');
        },
        localizationsDelegates: [
          const AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('fr', ''),
          const Locale('nl', ''),
        ],
        home: ChangeNotifierProvider<Catalog>(
          create: (context) => Catalog(catalogData),
          child: FutureBuilder<Catalog>(
            future: futureCatalog,
            builder: (context, snapshot) {
              if (globalVendorId == -1){
                return ExpansionTileCatalog();
              }
              if (snapshot.hasData) {
                globalCatalog = snapshot.data;
                //print(snapshot.data);
                return ExpansionTileCatalog();
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }

              // By default, show a loading spinner.

              return const Center(child: const CircularProgressIndicator());
            },
          ),
        ));
  } // Widget build
} // class _MyAppState


 Future<String> checkForUpdate() async {

   PackageInfo packageInfo = await PackageInfo.fromPlatform();

   String appName = packageInfo.appName;
   String packageName = packageInfo.packageName;
   String version = packageInfo.version;
   String buildNumber = packageInfo.buildNumber;


  String myVersion = version;
  var s = globalURL + 'index.php?lang='+globalLanguage+'&ops=checkForUpdate&current_version=' + myVersion;
  final response = await http.get(s);
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response, then parse the JSON.
    var responseJson = json.decode(response.body);
    if (responseJson =="needed"){
      globalBUpdate = true;
    }
    else{
      globalBUpdate = false;
    }
    return responseJson;
  }
  else {
    print("http error: " + response.statusCode.toString());
    // If the server did not return a 200 OK response, then throw an exception.
    throw Exception('Failed to load merchand');
  }
}