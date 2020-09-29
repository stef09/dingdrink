import 'package:flutter/material.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:dingdrink/maps.dart';
import 'package:dingdrink/main.dart';
import 'package:dingdrink/global.dart';
import 'package:dingdrink/localize.dart';


class MapsPage extends StatefulWidget {
  @override
  _MapsPageState createState() => new _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  GlobalKey<AutoCompleteTextFieldState<Maps>> key = new GlobalKey();

  AutoCompleteTextField searchTextField;

  TextEditingController controller = new TextEditingController();

  _MapsPageState();

  void _loadData() async {
    await MapsViewModel.loadMaps();
  }

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  Text autoComplete(item){
    Text myText;
    if (item.open == 0){
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

  Future navigateToMainPage(context, vendorId) async {
    //final myContext = context;
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MyApp()));
/*    if (result!= null) {
      globalOrdered = true;
      //globalCatalog.resetAmount(globalCatalog.data);
      Scaffold.of(globalContext).showSnackBar(SnackBar(
          content: Text(result.toString())


      )
      );
    }
*/
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).localized('mapSelectionTitle')),
        ),
        body: new Center(
            child: new Column(children: <Widget>[
              new Column(children: <Widget>[
                searchTextField = AutoCompleteTextField<Maps>(
                    minLength: 2,
                    style: new TextStyle(color: Colors.black, fontSize: 16.0),
                    decoration: new InputDecoration(
                        suffixIcon: Container(
                          width: 85.0,
                          height: 60.0,
                        ),
                        contentPadding: EdgeInsets.fromLTRB(10.0, 30.0, 10.0, 20.0),
                        filled: true,
                        hintText: AppLocalizations.of(context).localized('firstLetters') ,//'Type the firt letters of your location',
                        hintStyle: TextStyle(color: Colors.black)),
                    itemSubmitted: (item) {
                      if (item.open == 1) {
 //                       setState(() =>
 //                       searchTextField.textField.controller.text =
 //                           item.autocompleteterm);
                        globalVendorId = item.id;
                        globalVendorShortName = item.autocompleteterm;
                        navigateToMainPage(context, item.id);
                      }
                      else{
                        setState(() =>
                        searchTextField.textField.controller.text =
                            "");
                      }
                    },
                    clearOnSubmit: false,
                    key: key,
                    suggestions: MapsViewModel.maps,
                    itemBuilder: (context, item) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          autoComplete(item),
                          Padding(
                            padding: EdgeInsets.all(15.0),
                          ),
                          Text(item.open.toString(),
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
