import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:dingdrink/players.dart';


class Maps extends StatefulWidget {
  @override
  _MapsState createState() => new _MapsState();
}

class _MapsState extends State<Maps> {
  GlobalKey<AutoCompleteTextFieldState<Players>> key = new GlobalKey();

  AutoCompleteTextField searchTextField;

  TextEditingController controller = new TextEditingController();

  _MapsState();

  void _loadData() async {
    await PlayersViewModel.loadPlayers();
  }

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  Text autoComplete(item){
    Text myText;
    if (item.country == 'India'){
      myText = Text(item.autocompleteterm,
         style: TextStyle(
        fontWeight: FontWeight.w200,
        fontSize: 16.0
      ),);
    }
    else {
      myText = Text(item.autocompleteterm,
        style: TextStyle(
            fontSize: 16.0
        ),);
    }
    return myText;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Text('Select a Map'),
        ),
        body: new Center(
            child: new Column(children: <Widget>[
              new Column(children: <Widget>[
                searchTextField = AutoCompleteTextField<Players>(
                    minLength: 2,
                    style: new TextStyle(color: Colors.black, fontSize: 16.0),
                    decoration: new InputDecoration(
                        suffixIcon: Container(
                          width: 85.0,
                          height: 60.0,
                        ),
                        contentPadding: EdgeInsets.fromLTRB(10.0, 30.0, 10.0, 20.0),
                        filled: true,
                        hintText: 'Type the firt letters of your location',
                        hintStyle: TextStyle(color: Colors.black)),
                    itemSubmitted: (item) {
                      if (item.country != 'India') {
                        setState(() =>
                        searchTextField.textField.controller.text =
                            item.autocompleteterm);
                      }
                      else{
                        setState(() =>
                        searchTextField.textField.controller.text =
                            "");
                      }
                    },
                    clearOnSubmit: false,
                    key: key,
                    suggestions: PlayersViewModel.players,
                    itemBuilder: (context, item) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          autoComplete(item),
 /*                         Text(item.autocompleteterm,
                            style: TextStyle(
                                fontWeight: FontWeight.w100,
                                fontSize: 16.0
                            ),),
*/                          Padding(
                            padding: EdgeInsets.all(15.0),
                          ),
                          Text(item.country,
                          )
                        ],
                      );
                    },
                    itemSorter: (a, b) {
                      return a.autocompleteterm.compareTo(b.autocompleteterm);
                    },
                    itemFilter: (item, query) {
                      return item.autocompleteterm
                          .toLowerCase()
                          .startsWith(query.toLowerCase());
                    }),
              ]),
            ])));
  }
}
