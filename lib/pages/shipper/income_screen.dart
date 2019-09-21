import 'dart:async';

import 'package:farax/components/fab_bar.dart';
import 'package:farax/components/gradient_appbar.dart';
import 'package:farax/components/hex_color.dart';
import 'package:farax/pages/shipper/income_history.dart';
import 'package:farax/pages/shop/profile_shop.dart';
import 'package:farax/utils/auth_utils.dart';
import 'package:farax/utils/network_utils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../all_translations.dart';
//import 'billing_history.dart';
//import 'create_package.dart';
//import 'home_shop.dart';
import 'dart:convert';
//import 'notification_screen.dart';
import 'package:provider/provider.dart';
import 'package:farax/services/connectivity.dart';
import '../../components/offline_notification.dart';
import 'package:gradient_text/gradient_text.dart';

import '../home.dart';
import 'package:farax/pages/history.dart';
import 'package:farax/pages/profile.dart';

class Income extends StatefulWidget {
  @override
  _IncomeState createState() => _IncomeState();
}

class _IncomeState extends State<Income> {
  int _selectedIndex = 2;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
	Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences _sharedPreferences;
  bool isOffline;


  static const fontSizeTitle =12.0;
  static const iconSize =24.0;
  Color clr =Color.fromRGBO(50, 51, 102, 1.0);
  Color clrSelected = Color.fromRGBO(97, 56, 140, 1.0);
  TextStyle styleTitle = TextStyle(fontSize:fontSizeTitle );
  var account;
  @override
	void initState() {
		super.initState();
		_fetchSessionAndNavigate();
    print(_selectedIndex);
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
  _saveLocal(){
    //_sharedPreferences =await _prefs;
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
              return History();
            },
          )
        );
        break;
      case 1:
        Navigator.of(context).pushReplacement(
          new PageRouteBuilder(
            pageBuilder: (BuildContext context, _, __) {
              return Home();
            },
          )
        );
        break;
      case 2:
        Navigator.of(context).pushReplacement(
          new PageRouteBuilder(
            pageBuilder: (BuildContext context, _, __) {
              return Income();
            },
          )
        );
        break;
      case 3:
        Navigator.of(context).pushReplacement(
          new PageRouteBuilder(
            pageBuilder: (BuildContext context, _, __) {
              return Profile();
            },
          )
        );
        break;
      default:
    }
  }

  Future<List<dynamic>> _getAccount() async {
    _sharedPreferences = await _prefs;
    String userId = _sharedPreferences.getString('user_id');
    return http.get('https://camships.com:3000/api/Accounts?filter={"where": {"memberId": "${userId}"}}').then((response) => json.decode(response.body));
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
                GradientAppBar(title: "Income"),//allTranslations.text('cod_tab')),      
                Expanded(
                  flex: 1,
                  child: isOffline? OfflineNotification():Container(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    width: double.infinity,
                    color: Color.fromRGBO(242, 242, 242, 1),
                    child:    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        // FutureBuilder(
                        //   //future: ,
                        //   builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
                        //     switch (snapshot.connectionState) {
                        //       case ConnectionState.none:
                        //         return new Text(allTranslations.text('something_wrong'));
                        //       case ConnectionState.waiting:
                        //         return new Center(child: CircularProgressIndicator(),);
                        //       case ConnectionState.active:
                        //         return new Text('');
                        //       case ConnectionState.done:
                        //         if(snapshot.hasError) {
                        //           return new Text(
                        //             '${snapshot.error}',
                        //             style: TextStyle(color: Colors.red),
                        //           );
                        //         } else {
                        //           account = snapshot.data[0];
                        //           return 
                                  RefreshIndicator(
                                    onRefresh: _refresh,
                                  child: SingleChildScrollView(
                                    physics: AlwaysScrollableScrollPhysics(),
                                   child: Column(
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
                                                  Text(allTranslations.text('income')
                                                  , style: TextStyle(color: HexColor('#FF9933'), fontSize: 14),),
                                                ],
                                              ),
                                            ),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: <Widget>[
                                                Text("0" //account['cashDelivered'].toString()
                                                , style: TextStyle(color: HexColor('#FF9933'), fontSize: 18, fontWeight: FontWeight.bold),),
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
                                                Text("0"//account['faraxHolding'].toStringAsFixed(2)
                                                , style: TextStyle(color: HexColor('#0099CC'), fontSize: 18, fontWeight: FontWeight.bold),),
                                                SizedBox(width: 4,),
                                                Text(allTranslations.text('usd').toUpperCase(), style: TextStyle(color: HexColor('#0099CC'), fontSize: 14, fontWeight: FontWeight.bold),)
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
                                                    backgroundColor: Color.fromRGBO(255, 153, 51, 0.2),
                                                    child: Image.asset('icons/income.png'),
                                                  ),
                                                  SizedBox(width: 10,),
                                                  Text("Total completed orders"//allTranslations.text('totol_completed_orders')
                                                  , style: TextStyle(color: HexColor('#FF9933'), fontSize: 14),),
                                                ],
                                              ),
                                            ),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: <Widget>[
                                                Text("0" //account['cashDelivered'].toString()
                                                , style: TextStyle(color: HexColor('#FF9933'), fontSize: 18, fontWeight: FontWeight.bold),),
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
                                                  Text(allTranslations.text('last_7_days')//allTranslations.text('farax_is_holding')
                                                  , style: TextStyle(color: HexColor('#0099CC'), fontSize: 14),),
                                                ],
                                              ),
                                            ),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: <Widget>[
                                                Text("0"//account['faraxHolding'].toStringAsFixed(2)
                                                , style: TextStyle(color: HexColor('#0099CC'), fontSize: 18, fontWeight: FontWeight.bold),),
                                                SizedBox(width: 4,),
                                                Text(allTranslations.text('usd').toUpperCase(), style: TextStyle(color: HexColor('#0099CC'), fontSize: 14, fontWeight: FontWeight.bold),)
                                              ],
                                            )
                                          ],
                                        ),
                                      ),//
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
                                                    backgroundColor: Color.fromRGBO(255, 153, 51, 0.2),
                                                    child: Image.asset('icons/income.png'),
                                                  ),
                                                  SizedBox(width: 10,),
                                                  Text(allTranslations.text('this_month')
                                                  , style: TextStyle(color: HexColor('#FF9933'), fontSize: 14),),
                                                ],
                                              ),
                                            ),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: <Widget>[
                                                Text("0" //account['cashDelivered'].toString()
                                                , style: TextStyle(color: HexColor('#FF9933'), fontSize: 18, fontWeight: FontWeight.bold),),
                                                SizedBox(width: 4,),
                                                Text(allTranslations.text('usd').toUpperCase(), style: TextStyle(color: HexColor('#FF9933'), fontSize: 14, fontWeight: FontWeight.bold),)
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ))),
                                //}
                            //}
                        //   },
                        // ),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              new PageRouteBuilder(
                                pageBuilder: (BuildContext context, _, __) {
                                 return IncomeHistory();
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
                            child: new Center(child: Text("Income history".toUpperCase()//allTranslations.text('income_history').toUpperCase()
                              , style: TextStyle(color: HexColor('#FF9933'), fontSize: 14, fontWeight: FontWeight.bold),),),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          //floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
         bottomNavigationBar: BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today), 
                title: _selectedIndex == 0 ? GradientText(
                  allTranslations.text('history_tab'),
                  gradient: LinearGradient(
                    colors: [Color.fromRGBO(0, 201, 232, 1),
                      Color.fromRGBO(0, 153, 204, 1)]),
                  textAlign: TextAlign.center) : Text(allTranslations.text('history_tab'),)
              ),
              BottomNavigationBarItem(icon: Icon(Icons.home), 
                title: _selectedIndex == 1 ? GradientText(
                  allTranslations.text('home_tab'),
                  gradient: LinearGradient(
                    colors: [Color.fromRGBO(0, 201, 232, 1),
                      Color.fromRGBO(0, 153, 204, 1)]),
                  textAlign: TextAlign.center) : Text(allTranslations.text('home_tab'))
              ),
              BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), 
                title: _selectedIndex == 2 ? GradientText("Income",
                  //allTranslations.text('income_tab'),
                  gradient: LinearGradient(
                    colors: [Color.fromRGBO(0, 201, 232, 1),
                      Color.fromRGBO(0, 153, 204, 1)]),
                  textAlign: TextAlign.center) : Text("Income"//allTranslations.text('income_tab')
                  )
              ),
              BottomNavigationBarItem(icon: Icon(Icons.more_horiz), 
                title: _selectedIndex == 3 ? GradientText(
                  allTranslations.text('more_tab'),
                  gradient: LinearGradient(
                    colors: [Color.fromRGBO(0, 201, 232, 1),
                      Color.fromRGBO(0, 153, 204, 1)]),
                  textAlign: TextAlign.center) : Text(allTranslations.text('more_tab'))
              ),
            ],
            //fixedColor: Color.fromRGBO(0, 153, 204, 1),
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: Color.fromRGBO(0, 153, 204, 1),
            unselectedItemColor: Colors.grey[600],
            selectedFontSize: 12.0,
            unselectedFontSize: 12,
            selectedLabelStyle: TextStyle(fontSize:12 ),
            unselectedLabelStyle: TextStyle(fontSize:12 ),
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
          ), 
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