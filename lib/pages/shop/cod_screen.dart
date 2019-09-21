import 'dart:async';

import 'package:farax/components/fab_bar.dart';
import 'package:farax/components/gradient_appbar.dart';
import 'package:farax/components/hex_color.dart';
import 'package:farax/pages/shop/profile_shop.dart';
import 'package:farax/utils/auth_utils.dart';
import 'package:farax/utils/network_utils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../all_translations.dart';
import 'billing_history.dart';
import 'cashed_out_screen.dart';
import 'create_package.dart';
import 'home_shop.dart';
import 'dart:convert';
import 'notification_screen.dart';
import 'package:provider/provider.dart';
import 'package:farax/services/connectivity.dart';
import '../../components/offline_notification.dart';


class Cod extends StatefulWidget {
  @override
  _CodState createState() => _CodState();
}

class _CodState extends State<Cod> {
  int _selectedIndex = 1;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
	Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences _sharedPreferences;
  bool isOffline;
  var account;
  @override
	void initState() {
		super.initState();
		_fetchSessionAndNavigate();
	}

  _fetchSessionAndNavigate() async {
		_sharedPreferences = await _prefs;
    _sharedPreferences.setBool('isPageThreeExist', false);
		String authToken = AuthUtils.getToken(_sharedPreferences);

		if(authToken == null) {
			_logout();
		}
	}

  _logout() {
		NetworkUtils.logoutUser(_scaffoldKey.currentContext, _sharedPreferences);
	}

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacement(
          new PageRouteBuilder(
            pageBuilder: (BuildContext context, _, __) {
              return HomeShop();
            },
          )
        );
        break;
      case 1:
        Navigator.of(context).pushReplacement(
          new PageRouteBuilder(
            pageBuilder: (BuildContext context, _, __) {
              return Cod();
            },
          )
        );
        break;
      case 2:
        Navigator.of(context).pushReplacement(
          new PageRouteBuilder(
            pageBuilder: (BuildContext context, _, __) {
              return NotificationScreen();
            },
          )
        );
        break;
      case 3:
        Navigator.of(context).pushReplacement(
          new PageRouteBuilder(
            pageBuilder: (BuildContext context, _, __) {
              return ProfileShop();
            },
          )
        );
        break;
      default:
    }
  }

  Future<dynamic> _getAccount() async {
    _sharedPreferences = await _prefs;
    String authToken = AuthUtils.getToken(_sharedPreferences);
    return NetworkUtils.fetch(authToken, '/api/Orders/account');
  }

   Future<List<dynamic>> _refresh()async{
     Completer<Null> completer = Completer<Null>();
     new Future.delayed(Duration(seconds: 1)).then((_){
       completer.complete(); 
       setState(() {
        account = _getAccount(); 
       });
     });
     return  completer.future;
   }
  @override
  Widget build(BuildContext context) {
     var network = Provider.of<ConnectionStatus>(context);
    if(network==ConnectionStatus.offline){
     // NetworkUtils.showSnackBar(_scaffoldKey, null);
      isOffline = true;
    }else{
      isOffline = false;
    }
    
    return WillPopScope(
      onWillPop: () {},
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          key: _scaffoldKey,
          body: Container(
            child:  Column(
              children: <Widget>[
                GradientAppBar(title: allTranslations.text('cod_tab')),               
                Expanded(
                  flex: 3,
                  child: isOffline? OfflineNotification():Container(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    width: double.infinity,
                    color: Color.fromRGBO(242, 242, 242, 1),
                    child:    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        FutureBuilder(
                          future: _getAccount(),
                          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                            switch (snapshot.connectionState) {
                              case ConnectionState.none:
                                return new Text(allTranslations.text('something_wrong'));
                              case ConnectionState.waiting:
                                return new Center(child: CircularProgressIndicator(),);
                              case ConnectionState.active:
                                return new Text('');
                              case ConnectionState.done:
                                if(snapshot.hasError) {
                                  return new Text(
                                    '${snapshot.error}',
                                    style: TextStyle(color: Colors.red),
                                  );
                                } else {
                                  account = snapshot.data;
                                  return 
                                  RefreshIndicator(
                                    onRefresh: _refresh,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxHeight: MediaQuery.of(context).size.height * 0.6,
                                      ),
                                      child: SingleChildScrollView(
                                        physics: AlwaysScrollableScrollPhysics(),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.all(Radius.circular(4.0))
                                                ),
                                                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: <Widget>[
                                                    Container(
                                                      child: Row(
                                                        children: <Widget>[
                                                          CircleAvatar(
                                                            backgroundColor: Color.fromRGBO(255, 153, 51, 0.2),
                                                            child: Image.asset('icons/income.png'),
                                                          ),
                                                          SizedBox(width: 10,),
                                                          Text(allTranslations.text('cash_delivered'), style: TextStyle(color: HexColor('#FF9933'), fontSize: 14),),
                                                        ],
                                                      ),
                                                    ),
                                                    Row(
                                                      crossAxisAlignment: CrossAxisAlignment.end,
                                                      children: <Widget>[
                                                        Text(account['cashDelivered'].toStringAsFixed(2), style: TextStyle(color: HexColor('#FF9933'), fontSize: 18, fontWeight: FontWeight.bold),),
                                                        SizedBox(width: 4,),
                                                        Text(allTranslations.text('usd').toUpperCase(), style: TextStyle(color: HexColor('#FF9933'), fontSize: 14, fontWeight: FontWeight.bold),)
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 16.0),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.all(Radius.circular(4.0))
                                                ),
                                                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: <Widget>[
                                                    Container(
                                                      child: Row(
                                                        children: <Widget>[
                                                          CircleAvatar(
                                                            backgroundColor: Color.fromRGBO(0, 153, 204, 0.2),
                                                            child: Image.asset('icons/coin.png'),
                                                          ),
                                                          SizedBox(width: 10,),
                                                          Text(allTranslations.text('farax_is_holding'), style: TextStyle(color: HexColor('#0099CC'), fontSize: 14),),
                                                        ],
                                                      ),
                                                    ),
                                                    Row(
                                                      crossAxisAlignment: CrossAxisAlignment.end,
                                                      children: <Widget>[
                                                        Text(account['faraxHolding'].toStringAsFixed(2), style: TextStyle(color: HexColor('#0099CC'), fontSize: 18, fontWeight: FontWeight.bold),),
                                                        SizedBox(width: 4,),
                                                        Text(allTranslations.text('usd').toUpperCase(), style: TextStyle(color: HexColor('#0099CC'), fontSize: 14, fontWeight: FontWeight.bold),)
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 16.0,),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.all(Radius.circular(4.0))
                                                ),
                                                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: <Widget>[
                                                    Container(
                                                      child: Row(
                                                        children: <Widget>[
                                                          CircleAvatar(
                                                            backgroundColor: Color.fromRGBO(255, 153, 51, 0.2),
                                                            child: Image.asset('icons/income.png'),
                                                          ),
                                                          SizedBox(width: 10,),
                                                          Text(allTranslations.text('total_cashed_out_bills'), style: TextStyle(color: HexColor('#FF9933'), fontSize: 14),),
                                                        ],
                                                      ),
                                                    ),
                                                    Row(
                                                      crossAxisAlignment: CrossAxisAlignment.end,
                                                      children: <Widget>[
                                                        Text(account['totalCashedOut'].toString(), style: TextStyle(color: HexColor('#FF9933'), fontSize: 24, fontWeight: FontWeight.bold),),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 16.0),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.all(Radius.circular(4.0))
                                                ),
                                                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: <Widget>[
                                                    Container(
                                                      child: Row(
                                                        children: <Widget>[
                                                          CircleAvatar(
                                                            backgroundColor: Color.fromRGBO(0, 153, 204, 0.2),
                                                            child: Image.asset('icons/coin.png'),
                                                          ),
                                                          SizedBox(width: 10,),
                                                          Text(allTranslations.text('not_cashed_out'), style: TextStyle(color: HexColor('#0099CC'), fontSize: 14),),
                                                        ],
                                                      ),
                                                    ),
                                                    Row(
                                                      crossAxisAlignment: CrossAxisAlignment.end,
                                                      children: <Widget>[
                                                        Text(account['totalNotCashedOut'].toString(), style: TextStyle(color: HexColor('#0099CC'), fontSize: 24, fontWeight: FontWeight.bold),),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              )
                                            ],
                                        ),
                                        ),
                                    )
                                  );
                                }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              new PageRouteBuilder(
                                pageBuilder: (BuildContext context, _, __) {
                                  return CashedOutScreen();
                                },
                              )
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12.5),
                            decoration: new BoxDecoration(
                              color: Colors.transparent,
                              border: new Border.all(color: HexColor('#FF9933'), width: 1.0),
                              borderRadius: new BorderRadius.circular(3.0),
                            ),
                            child: new Center(child: Text(allTranslations.text('cashed_out_bills_history').toUpperCase(), style: TextStyle(color: HexColor('#FF9933'), fontSize: 14, fontWeight: FontWeight.bold),),),
                          ),
                        ),
                        SizedBox(height: 16.0,),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              new PageRouteBuilder(
                                pageBuilder: (BuildContext context, _, __) {
                                  return BillingHistory();
                                },
                              )
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12.5),
                            decoration: new BoxDecoration(
                              color: Colors.transparent,
                              border: new Border.all(color: HexColor('#FF9933'), width: 1.0),
                              borderRadius: new BorderRadius.circular(3.0),
                            ),
                            child: new Center(child: Text(allTranslations.text('bill_history').toUpperCase(), style: TextStyle(color: HexColor('#FF9933'), fontSize: 14, fontWeight: FontWeight.bold),),),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(
                new PageRouteBuilder(
                  pageBuilder: (BuildContext context, _, __) {
                    return CreatePackage();
                  },
                )
              );
            },
            materialTapTargetSize: MaterialTapTargetSize.padded,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(Icons.add),
            ),
            foregroundColor: Colors.white,
            backgroundColor: Color.fromRGBO(23, 176, 219, 1),
            shape: _PolygonBorder(),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: FABBottomAppBar(
            color: HexColor('#B0BEC5'),
            selectedColor: HexColor('#0099CC'),
            onTabSelected: _onItemTapped,
            selectedIndex: 1,
            // notchedShape: CircularNotchedRectangle(),
            items: [
              FABBottomAppBarItem(iconData: Icons.home, text: allTranslations.text('home_tab')),
              FABBottomAppBarItem(iconData: Icons.account_balance_wallet, text: allTranslations.text('cod_tab')),
              FABBottomAppBarItem(iconData: Icons.notifications, text: allTranslations.text('notification_tab'), count: 2),
              FABBottomAppBarItem(iconData: Icons.more_horiz, text: allTranslations.text('more_tab')),
            ],
          )
        ),
        
      ),
    );
  }
}

class _PolygonBorder extends ShapeBorder {
  const _PolygonBorder();

  @override
  EdgeInsetsGeometry get dimensions {
    return const EdgeInsets.only();
  }

  @override
  Path getInnerPath(Rect rect, { TextDirection textDirection }) {
    return getOuterPath(rect, textDirection: textDirection);
  }

  @override
  Path getOuterPath(Rect rect, { TextDirection textDirection }) {
    return Path()
      ..moveTo(rect.left + rect.width / 2.0, rect.top)
      ..lineTo(rect.width, rect.height * 0.25)
      ..lineTo(rect.width, rect.height * 0.75)
      ..lineTo(rect.width  / 2.0, rect.bottom)
      ..lineTo(0, rect.height * 0.75)
      ..lineTo(0, rect.height * 0.25)
      ..close();
  }

  @override
  void paint(Canvas canvas, Rect rect, { TextDirection textDirection }) {}

  // This border doesn't support scaling.
  @override
  ShapeBorder scale(double t) {
    return null;
  }
}