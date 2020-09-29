import 'package:dingdrink/order.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dingdrink/catalog.dart';
import 'package:dingdrink/main.dart';
import 'package:dingdrink/global.dart';
import 'package:dingdrink/localize.dart';

class CartPage extends StatelessWidget {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Future<String> _userName;
  String userName;
  final userNameController = TextEditingController();
  final tableNameController = TextEditingController();
  String _tableName;
  List<Entry> catalogData;
  double totalPrice = 0.0;
  String myCart;

  CartPage({Key key, @required this.catalogData, this.myCart})
      : super(key: key) {
    getPrefs();

    catalogData = this.catalogData;
    myCart = buildCart(catalogData) +
        '\nPrix total: ' +
        totPrice(catalogData).toStringAsFixed(2);


  }

  String result = "";

  Future<void> getPrefs() async{
    final SharedPreferences prefs = await _prefs;
    _userName = _prefs.then((SharedPreferences prefs) {
        return (prefs.getString('userName') ?? '');

      });
    userNameController.text = await _userName ;
    tableNameController.text = globalTableName;
 }

  Future<void> setPrefs() async{
    globalTableName  = tableNameController.text;
    final SharedPreferences prefs = await _prefs;
    _userName = prefs.setString("userName", userNameController.text).then((bool success) {
      return userName;
    });
  }

  String buildCart(List<Entry> data) {
    //List<EntryDetail> dataCart = <EntryDetail>[];
    for (int i = 0; i < data.length; i++) {
      if (data[i] is EntryDetail) {
        EntryDetail myDetail = data[i];
        if (myDetail.count > 0) {
          totalPrice += myDetail.count * myDetail.price;
          result += 
              myDetail.getCount().toString() +
              '    ' + data[i].title.toString() +
              '    ' +
              '    (' +
              (myDetail.count * myDetail.price).toStringAsFixed(2) +
              ')\n';
        }
        //print(result + '\n');
      } else {
        result = buildCart(data[i].children);
      }
    }
    return (result);
  }

  double totPrice(List<Entry> data) {
    //List<EntryDetail> dataCart = <EntryDetail>[];
    for (int i = 0; i < data.length; i++) {
      if (data[i] is EntryDetail) {
        EntryDetail myDetail = data[i];
        if (myDetail.count > 0) {
          totalPrice += myDetail.count * myDetail.price;
        } else {
          totalPrice += totPrice(data[i].children);
        }
      }
    }
    return (totalPrice);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Panier'),
          backgroundColor: Colors.redAccent,
        ),
        body: Builder(
          // Create an inner BuildContext so that the onPressed methods
          // can refer to the Scaffold with Scaffold.of().
          builder: (BuildContext context) { var cmd = "yes";
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextField(
                    controller: tableNameController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: AppLocalizations.of(context).localized('enterTable'),
                    ),

                  ),
                  TextField(
                    controller: userNameController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: AppLocalizations.of(context).localized('enterName'),
                    ),

                  ),
                  Text(myCart),
                  RaisedButton(
                    textColor: Colors.white,
                    color: Colors.redAccent,
                    child: Text('<-Retour à la Carte'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  RaisedButton(
                    textColor: Colors.white,
                    color: Colors.redAccent,
                    child: Text('Passer Commande'),
                    onPressed: disableOrder() ? null : () {

                      Order order = Order(vendorId: globalVendorId.toString(), totalPrice: totalPrice, deviceId: globalDeviceId,
                                      nickName: userNameController.text, place: tableNameController.text);
                      totalPrice =0;
                      var orderId="";
                      Future<String> s =   createMyOrder(context, order);
                      //TO DO: control good execution of creating order(return code) and modify
                      //showAlertDialog to reflect failed or success
                      setPrefs();
 //                     showAlertDialog( context);
                      //print("pressed, trying to set a snackbar");

                   /*   Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text(s.toString())
                          )
                      );   // showSnackBar
*/
                    }

                    ,),

                ],
              ),
            );
          },
        ));
  }  // Widget build

  Future<String> createMyOrder(context, order) async {
    buildOrderItems(catalogData, order);

    var s = await postOrder(order);
    globalOrderMsg = s;
    showAlertDialog(context, s);
    return s;
  }
  void buildOrderItems(List<Entry> data, Order order) {
    //List<EntryDetail> dataCart = <EntryDetail>[];
    for (int i = 0; i < data.length; i++) {
      if (data[i] is EntryDetail) {
        EntryDetail myDetail = data[i];
        if (myDetail.count > 0) {
          // create orderItem
          OrderItem oi = OrderItem(
              productId: myDetail.productId, amount: myDetail.count, price: myDetail.price);
          order.orderItems.add(oi);
        }
      }
      else {
        buildOrderItems(data[i].children, order);
      }
    }
    //return (order);
  }


  bool disableOrder(){
    //return (_ordered) ;
 //   totalPrice = totPrice(data)
    if (totalPrice > 0) {
      return false;
    }
    return true;
  }
  showAlertDialog(BuildContext context, String msg) async {
    var i = msg.lastIndexOf('}')+1; //return code of add order in DB
    var myCode = msg.substring(i); print(myCode);
    var sTitle;
    var sContent;
   // var sContent = AppLocalizations.of(context).alert2 + myCode + AppLocalizations.of(context).alert3;

    if (myCode == "-1"){  // order not added because vendor orders not open
      sTitle = AppLocalizations.of(context).localized('alert4');
      sContent = AppLocalizations.of(context).localized('alert5');
      globalOrdered = false;
    }
    else {
      sTitle = AppLocalizations.of(context).localized('alert1');
      sContent = AppLocalizations.of(context).localized('alert2') + myCode +
          AppLocalizations.of(context).localized('alert3');
      globalOrdered = true;
    }
      // set up the button
    Widget okButton = FlatButton(
      child: Text("Ok"),
      onPressed: () {navPush(context); },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(sTitle),
      content: Text(sContent),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  navPush(BuildContext context){
    Navigator.of(context, rootNavigator: true).pop(result);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MyApp()));
  }


} // class CartPage
