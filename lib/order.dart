import 'dart:async';
import 'dart:convert';
import 'package:dingdrink/main.dart';
import 'package:http/http.dart' as http;
import 'package:dingdrink/catalog.dart';
import 'package:dingdrink/global.dart';

class OrderItem {
  final int id;
  final String productId;
  final int amount;
  final double price;
  OrderItem({this.id, this.productId, this.amount, this.price});

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      productId: json['productId'],
      amount: json['amount'],
      price: json['price'],
    );
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["productId"] = productId;
    map["amount"] = amount.toString();
    map["price"] = price.toString();
    return map;
  } // toMap()

} // class OrderItem

class Order {
  final int id;
  final String vendorId;
  final String timestamp;
  final double totalPrice;
  final String deviceId;
  final String nickName;
  final String place;
  var orderItems = <OrderItem>[];

  Order({this.id, this.vendorId, this.timestamp, this.totalPrice, this.deviceId, this.nickName, this.place});

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      vendorId: json['vendorId'],
      timestamp: json['timestamp'],
      totalPrice: json['totalPrice'],
      deviceId: json['deviceId'],
      nickName: json['nickName'],
      place: json['place'],
    );
  }

  Map toMap() {

    var map = new Map<String, dynamic>();
    map["vendorId"] = vendorId.toString() ;
    map["totalPrice"] = totalPrice.toString();
    map["deviceId"] = deviceId.toString();
    map["orderItems"] = new List<Map<String, String>>(); //=mapItem;
    map["nickName"] = nickName.toString();
    map["place"] = place.toString();
    var l = new List<OrderItem>(); //=mapItem;

    for (int i = 0; i < orderItems.length; i++){
      var mapItem = new OrderItem(
          productId: orderItems[i].productId,
          amount: orderItems[i].amount,
          price: orderItems[i].price);
      l.add(mapItem);

    }
    String json = jsonEncode(l.map((i)=>i.toMap()).toList()).toString();
    map["orderItems"] = json; //l;
 //   print(map);
    return map;
  }
} // class Order

Future<String> postOrder(Order order) async {
  final CREATE_ORDER_URL = globalURL + 'index.php?ops=order';
  Order newOrder = order; //Order(vendorId: "1", totalPrice: 200.00);

  //var myBody = newOrder.toMap();
  //var myBody = json.encode(newOrder);
  var myBody = newOrder.toMap();
  //print(myBody);
  return http
      .post(CREATE_ORDER_URL, body: myBody)
      .then((http.Response response) {
    final int statusCode = response.statusCode;
    //print(newOrder.totalPrice.toString());
    if (statusCode < 200 || statusCode > 400 || json == null) {
      throw new Exception("Error while fetching data");
    }
    globalCatalog.resetAmount(globalCatalog.data);
    //print(json.decode(response.bodyBytes.toString()));
    //print((response.body.toString()));
    globalOrdered = true;
   // var sPush =  pushOrder();
    //print(sPush );
    return ( int.parse( response.body.toString()).toString());
  });
}
Future<String> pushOrder() async {
  final CREATE_PUSH_URL = 'https://www.it-cs.be/1easy/push.php?token=$globalDeviceId';
  final resp = await http.get(CREATE_PUSH_URL);
  /*   return http
        .get(CREATE_PUSH_URL)
        .then((http.Response response) {
      final int statusCode = response.statusCode;
      //print(newOrder.totalPrice.toString());
 */
  print (resp.body.toString() );
  final int statusCode = resp.statusCode;

  if (statusCode < 200 || statusCode > 400 || json == null) {
    throw new Exception("Error while fetching data");
  }

      return ((resp.body.toString()) );
}


