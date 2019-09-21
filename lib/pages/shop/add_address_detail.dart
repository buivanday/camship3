import 'package:farax/components/gradient_appbar.dart';
import 'package:farax/components/hex_color.dart';
import 'package:farax/utils/auth_utils.dart';
import 'package:farax/utils/network_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../all_translations.dart';
import 'address_book.dart';

class AdressBookDetail extends StatefulWidget {
  const AdressBookDetail({
    Key key,
    this.title,
    this.address,
    this.phoneNumber
  }) : super(key: key);

  final String title;
  final String address;
  final String phoneNumber;
  @override
  _AdressBookDetailState createState() => _AdressBookDetailState();
}

class _AdressBookDetailState extends State<AdressBookDetail> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
	Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences _sharedPreferences;
  bool _isDefaultAddress = false;
  
  @override
	void initState() {
		super.initState();
		_fetchSessionAndNavigate();
	}

  _fetchSessionAndNavigate() async {
		_sharedPreferences = await _prefs;
		String authToken = AuthUtils.getToken(_sharedPreferences);

		if(authToken == null) {
			_logout();
		}
	}

  Future _showDialog() async {
    _sharedPreferences = await _prefs;
		String authToken = AuthUtils.getToken(_sharedPreferences);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await showDialog<String>(
        context: context,
        builder: (BuildContext context) => new DialogDeleteAddressBook(
        authToken: authToken, scaffoldKey: _scaffoldKey, 
        sharedPreferences: _sharedPreferences)
      );
    });
  }

  _logout() {
		NetworkUtils.logoutUser(_scaffoldKey.currentContext, _sharedPreferences);
	}
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: <Widget>[
            GradientAppBar(title: widget.title, hasBackIcon: true, closeIcon: true,),
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.06),
                            spreadRadius: 2.0,
                            blurRadius: 1.0,
                            offset: Offset(0.2, 0.2)
                          )
                        ],
                        borderRadius: BorderRadius.all(Radius.circular(4.0))
                      ),
                      child: new AddressBookItem(title: widget.title, address: widget.address, phoneNumber: widget.phoneNumber,),
                    ),
                    SizedBox(height: 16.0,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Checkbox(
                          value: _isDefaultAddress,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          onChanged: (bool value) {
                            setState(() {
                              _isDefaultAddress = value;
                            });
                          },
                        ),
                        Text(allTranslations.text('make_default_address'), style: TextStyle(color: HexColor('#455A64'), fontSize: 14.0),)
                      ],
                    ),
                  ],
                ),
              )
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: InkWell(
                onTap: _showDialog,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: HexColor('#F5F5F5'),
                    border: Border.all(color: HexColor('#E0E0E0')),
                    borderRadius: BorderRadius.all(Radius.circular(4.0))
                  ),
                  child: Center(
                    child: Text(allTranslations.text('delete_this_address').toUpperCase(), style: TextStyle(fontSize: 14.0,fontWeight: FontWeight.bold, color: HexColor('#78909C'))),
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


class DialogDeleteAddressBook extends StatelessWidget {
  const DialogDeleteAddressBook({
    Key key,
    @required this.authToken,
    @required this.scaffoldKey,
    @required this.sharedPreferences
  }) : super(key: key);

  final String authToken;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final SharedPreferences sharedPreferences;


  Future _acceptOrder(BuildContext context) async {
    // Navigator.of(context).push(
    //   new PageRouteBuilder(
    //     pageBuilder: (BuildContext context, _, __) {
    //       return CreatePackageDetail();
    //     },
    //   )
    // );
  }

  _logout() {
		NetworkUtils.logoutUser(scaffoldKey.currentContext, sharedPreferences);
	}

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4.0))
          ),
          contentPadding: const EdgeInsets.all(20.0),
          backgroundColor: Colors.white,
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Image.asset('icons/remove-address.png'),
              SizedBox(width: 16),
              Text(allTranslations.text('title_alert_delete_address'),
              style: TextStyle(
                color: Color.fromRGBO(20, 156, 206, 1),
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 0.5
              )),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(allTranslations.text('confirm_alert_delete_address'), style: TextStyle(
                  color: HexColor('#455A64'),
                  fontSize: 12,
                  height: 16/14.0
                )),
                SizedBox(height: 20.0),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: () {_acceptOrder(context);},
                        child: new Container(
                          padding: const EdgeInsets.symmetric(vertical: 12.5),
                          decoration: new BoxDecoration(
                            color: HexColor('#FFFFFF'),
                            border: Border.all(color: HexColor('#DFE4EA')),
                            borderRadius: BorderRadius.all(Radius.circular(4.0))
                          ),
                          child: new Center(child: new Text(allTranslations.text('cancel').toUpperCase(), style: new TextStyle(fontSize: 14.0, color: HexColor('#78909C'), fontWeight: FontWeight.bold),),),
                        ),
                      ),
                    ),
                    SizedBox(width: 11.0,),
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: () {_acceptOrder(context);},
                        child: new Container(
                          padding: const EdgeInsets.symmetric(vertical: 12.5),
                          decoration: new BoxDecoration(
                            color: HexColor('#FF3333'),
                            borderRadius: BorderRadius.all(Radius.circular(4.0))
                          ),
                          child: new Center(child: new Text(allTranslations.text('delete').toUpperCase(), style: new TextStyle(fontSize: 14.0, color: Colors.white, fontWeight: FontWeight.bold),),),
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}