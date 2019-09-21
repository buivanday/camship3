import 'package:farax/components/gradient_appbar.dart';
import 'package:farax/components/hex_color.dart';
import 'package:farax/utils/auth_utils.dart';
import 'package:farax/utils/network_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import '../../components/flutter_tagging.dart';
import '../../all_translations.dart';

class AddCard extends StatefulWidget {
  @override
  _AddCardState createState() => _AddCardState();
}

class TagSearchService {
  static Future<List> getSuggestions(String query,dynamic banks) async {
    List<dynamic> tagList = <dynamic>[];
    for(var bank in banks) {
      tagList.add({'name': bank['name'], 'value': bank['id']});
    }
    List<dynamic> filteredTagList = <dynamic>[];
    for (var tag in tagList) {
      if (tag['name'].toLowerCase().contains(query)) {
        filteredTagList.add(tag);
      }
    }
    return filteredTagList;
  }
}

class _AddCardState extends State<AddCard> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
	Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences _sharedPreferences;
  var _cardNumberController = new TextEditingController();
  var _cardHolderNameController = new TextEditingController();
  var _cardExpiry = new TextEditingController();
  var _cardCVV = new TextEditingController();
  final visaReg = RegExp(r'^4[0-9]{12}(?:[0-9]{3})?$');
  final masterReg = RegExp(r'^(?:4[0-9]{12}(?:[0-9]{3})?|5[1-5][0-9]{14})$');
  final jcbReg = RegExp(r'^(?:2131|1800|35\d{3})\d{11}$');
  bool _isVisa = false;
  bool _isMaster = false;
  bool _isJCB = false;
  String text = "Nothing to show";

  @override
	void initState() {
		super.initState();
	}

  Widget _buildAddButton() {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
        color: Colors.pinkAccent,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.add,
            color: Colors.white,
            size: 15.0,
          ),
          Text(
            "Add New Tag",
            style: TextStyle(color: Colors.white, fontSize: 14.0),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: <Widget>[
            GradientAppBar(title: allTranslations.text('add_account'), hasBackIcon: true, closeIcon: true,),
            Expanded(
              flex: 1,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                },
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 55.0, horizontal: 16.0),
                    child: Theme(
                      data: new ThemeData(
                        hintColor: HexColor('#DFE4EA')
                      ),
                      child: Column(
                        children: <Widget>[
                          TextField(
                            decoration: InputDecoration(
                              labelText: allTranslations.text('account_number'),
                              labelStyle: TextStyle(color: HexColor('#90A4AE'), fontSize: 14),
                              suffixIcon: Image.asset(_isVisa ? 'icons/visa-1.png' : _isMaster ? 'icons/master-1.png' : _isJCB ? 'icons/jcb-1.png' : 'icons/add-card.png',  width: 48.0,)
                            ),
                            controller: _cardNumberController,
                            inputFormatters: [
                              MaskedTextInputFormatter(
                                mask: 'xxxx-xxxx-xxxx-xxxx',
                                separator: '-',
                              ),
                            ],
                            onChanged: (value) {
                              if(visaReg.hasMatch(value.replaceAll('-', ''))) {
                                setState(() {
                                  _isVisa = true;
                                  _isMaster = false;
                                  _isJCB = false;
                                });
                              } else if(masterReg.hasMatch(value.replaceAll('-', ''))) {
                                setState(() {
                                  _isVisa = false;
                                  _isMaster = true;
                                  _isJCB = false;
                                });
                              } else if(jcbReg.hasMatch(value.replaceAll('-', ''))) {
                                setState(() {
                                  _isVisa = false;
                                  _isMaster = false;
                                  _isJCB = true;
                                });
                              }
                            },
                            keyboardType: TextInputType.number,
                            style: TextStyle(color: HexColor('#455A64')),
                          ),
                          SizedBox(height: 41.0,),
                          TextField(
                            decoration: InputDecoration(
                              labelText: allTranslations.text('account_holder_name'),
                              labelStyle: TextStyle(color: HexColor('#90A4AE'), fontSize: 14),
                            ),
                            controller: _cardHolderNameController,
                            inputFormatters: [UpperCaseTextFormatter(), new BlacklistingTextInputFormatter(new RegExp('[\\.|\\,]')),],
                            style: TextStyle(color: HexColor('#455A64')),
                          ),
                          SizedBox(height: 41.0,),
                          FutureBuilder(
                            future: NetworkUtils.fetchWithoutAuthorization('/api/banks'),
                            builder: (BuildContext context, AsyncSnapshot snapshot) {
                              switch(snapshot.connectionState) {
                                case ConnectionState.none:
                                  return new Text('wait');
                                case ConnectionState.waiting:
                                  return new Center(child:CircularProgressIndicator());
                                case ConnectionState.active:
                                  return new Text('');
                                case ConnectionState.done:
                                  if(snapshot.hasError) {
                                    return new Text('${snapshot.error}', style: TextStyle(color: Colors.red));
                                  } else {
                                    return new FlutterTagging(
                                      textFieldDecoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        hintText: "Enter Bank Name, ShortName...",
                                        labelText: "Bank Information"
                                      ),
                                      addButtonWidget: _buildAddButton(),
                                      chipsColor: Colors.pinkAccent,
                                      chipsFontColor: Colors.white,
                                      deleteIcon: Icon(Icons.cancel,color: Colors.white),
                                      chipsPadding: EdgeInsets.all(2.0),
                                      chipsFontSize: 14.0,
                                      chipsSpacing: 5.0,
                                      chipsFontFamily: 'helvetica_neue_light',
                                      suggestionsCallback: (pattern) async {
                                        return TagSearchService.getSuggestions(pattern, snapshot.data);
                                      },
                                      onChanged: (result) {
                                        
                                      },
                                    );
                                  }
                              }
                            },
                          )
                        ],
                      ),
                    )
                  ),
                ),
              )
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: RaisedButton(
                onPressed: (_cardNumberController.text == '' || _cardHolderNameController.text == '' || _cardExpiry.text == '') ? null : () async {
                  _sharedPreferences = await _prefs;
		              String memberId = _sharedPreferences.getString('user_id');
                  String authToken = AuthUtils.getToken(_sharedPreferences);
                  var card = await NetworkUtils.postWithBody(authToken, '/api/Cards', {
                    'memberId': memberId,
                    'cardNumber': _cardNumberController.text,
                    'holderName': _cardHolderNameController.text,
                    'expiry': _cardExpiry.text,
                    'type': _isVisa ? 1 : (_isMaster ? 2 : 3)
                  });

                  Navigator.pop(context, card);
                },
                color: Color.fromRGBO(253, 134, 39, 1),
                textColor: Colors.white,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10))
                  ),
                  child: Center(
                    child: Text(allTranslations.text('save').toUpperCase(), style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    ); 
  }
}


class MaskedTextInputFormatter extends TextInputFormatter {
  final String mask;
  final String separator;

  MaskedTextInputFormatter({
    @required this.mask,
    @required this.separator,
  }) { assert(mask != null); assert (separator != null); }

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if(newValue.text.length > 0) {
      if(newValue.text.length > oldValue.text.length) {
        if(newValue.text.length > mask.length) return oldValue;
        if(newValue.text.length < mask.length && mask[newValue.text.length - 1] == separator) {
          return TextEditingValue(
            text: '${oldValue.text}$separator${newValue.text.substring(newValue.text.length-1)}',
            selection: TextSelection.collapsed(
              offset: newValue.selection.end + 1,
            ),
          );
        }
      }
    }
    return newValue;
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text?.toUpperCase(),
      selection: newValue.selection,
    );
  }
}