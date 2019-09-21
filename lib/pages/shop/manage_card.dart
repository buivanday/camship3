import 'package:farax/components/gradient_appbar.dart';
import 'package:farax/components/hex_color.dart';
import 'package:farax/utils/auth_utils.dart';
import 'package:farax/utils/network_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_drawing/path_drawing.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../all_translations.dart';
import 'add_card.dart';

class ManageCard extends StatefulWidget {
  @override
  _ManageCardState createState() => _ManageCardState();
}

class _ManageCardState extends State<ManageCard> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
	Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences _sharedPreferences;
	var _authToken, _id, _name = "", _phoneNumber = "", _address = "";
  @override
	void initState() {
		super.initState();
		_fetchSessionAndNavigate();
	}

  _fetchSessionAndNavigate() async {
		_sharedPreferences = await _prefs;
		String authToken = AuthUtils.getToken(_sharedPreferences);
		var id = _sharedPreferences.getString(AuthUtils.userIdKey);
		var name = _sharedPreferences.getString(AuthUtils.nameKey);
    var phoneNumber = _sharedPreferences.getString(AuthUtils.phoneNumber);
    var address = _sharedPreferences.getString(AuthUtils.address);

		setState(() {
			_authToken = authToken;
			_id = id;
			_name = name;
      _phoneNumber = phoneNumber;
      _address = address;
		});

		if(_authToken == null) {
			_logout();
		}
	}

  Future<List<dynamic>> _getCards() async {
    _sharedPreferences = await _prefs;
    String userId = _sharedPreferences.getString('user_id');
    return http.get('https://camships.com:3000/api/Cards?filter={"where": {"memberId": "${userId}"}}').then((response) => json.decode(response.body));
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
            GradientAppBar(title: allTranslations.text('manage_card'), hasBackIcon: true),
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 16.0),
                  child: Column(
                    children: <Widget>[
                      InkWell(
                        onTap: () async {
                          final card = await Navigator.of(context).push(
                              new PageRouteBuilder(
                                pageBuilder: (BuildContext context, _, __) {
                                  return AddCard();
                                },
                              )
                            );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: HexColor('#F5F5F5'),
                            border: DashPathBorder.all(
                              dashArray: CircularIntervalList<double>(<double>[5.0, 1.5]),
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(4.0))
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(Icons.add, color: HexColor('#0099CC'),),
                                SizedBox(width: 6.0,),
                                Text(allTranslations.text('add_bank_account').toUpperCase(), style: TextStyle(color: HexColor('#455A64'), fontSize: 14.0, height: 16.0/14.0),)
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.5,),
                      FutureBuilder(
                        future: _getCards(),
                        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
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
                                List<Widget> cardWidgets = new List();
                                for (var i = 0; i < snapshot.data.length; i++) {
                                  var card = snapshot.data[i];
                                  if(card['type'] == 1) {
                                    cardWidgets.add(
                                      InkWell(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            new PageRouteBuilder(
                                              pageBuilder: (BuildContext context, _, __) {
                                                return AddCard();
                                              },
                                            )
                                          );
                                        },
                                        child: Stack(
                                          children: <Widget>[
                                            Container(
                                              height: 198.0,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(Radius.circular(12.0)),
                                                gradient: LinearGradient(
                                                  end: Alignment.bottomLeft,
                                                  begin: Alignment.topRight,
                                                  stops: [-0.1779, -0.1213, -0.0837,  0.6693, 1.2202, 1.3285],
                                                  colors: [HexColor('#FDC830'), HexColor('#FDC830'), HexColor('#FDC830'), HexColor('#F37335'),  HexColor('#F37335'),  HexColor('#F37335')],
                                                  tileMode: TileMode.mirror
                                                ),
                                              ),
                                              padding: const EdgeInsets.only(top: 60.0, left: 20.0, right: 20.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(card['cardNumber'], style: TextStyle(color: Colors.white, fontSize: 20.0),),
                                                  SizedBox(height: 30.0,),
                                                  Text('exp  ' + card['expiry'].toUpperCase(), style: TextStyle(color: Colors.white, fontSize: 12.0), ),
                                                  SizedBox(height: 4.0,),
                                                  Text(card['holderName'].toUpperCase(), style: TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold),),
                                                ],
                                              )
                                            ),
                                            Positioned(
                                              right: 20,
                                              bottom: 0,
                                              child: Image.asset('icons/visa.png'),
                                            )
                                          ],
                                        ),
                                      )
                                    );
                                  } else if(card['type'] == 2) {
                                    cardWidgets.add(
                                      InkWell(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            new PageRouteBuilder(
                                              pageBuilder: (BuildContext context, _, __) {
                                                return AddCard();
                                              },
                                            )
                                          );
                                        },
                                        child: Stack(
                                          children: <Widget>[
                                            Container(
                                              height: 198.0,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(Radius.circular(12.0)),
                                                gradient: LinearGradient(
                                                  end: Alignment.bottomLeft,
                                                  begin: Alignment.topRight,
                                                  stops: [-0.1779, -0.1213, -0.0837,  0.6693, 1.2202, 1.3285],
                                                  colors: [ HexColor('#29ABE2'),  HexColor('#29ABE2'),  HexColor('#29ABE2'), HexColor('#4F00BC'), HexColor('#4F00BC'), HexColor('#4F00BC')],
                                                  tileMode: TileMode.mirror
                                                ),
                                              ),
                                              padding: const EdgeInsets.only(top: 60.0, left: 20.0, right: 20.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(card['cardNumber'], style: TextStyle(color: Colors.white, fontSize: 20.0),),
                                                  SizedBox(height: 30.0,),
                                                  Text('exp  ' + card['expiry'].toUpperCase(), style: TextStyle(color: Colors.white, fontSize: 12.0), ),
                                                  SizedBox(height: 4.0,),
                                                  Text(card['holderName'].toUpperCase(), style: TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold),),
                                                ],
                                              )
                                            ),
                                            Positioned(
                                              right: 10,
                                              bottom: 0,
                                              child: Image.asset('icons/master.png', width: 90,),
                                            )
                                          ],
                                        ),
                                      )
                                    );
                                  } else {
                                    cardWidgets.add(
                                      InkWell(
                                        onTap: () async {
                                          final card = await Navigator.of(context).push(
                                            new PageRouteBuilder(
                                              pageBuilder: (BuildContext context, _, __) {
                                                return AddCard();
                                              },
                                            )
                                          );
                                        },
                                        child: Stack(
                                          children: <Widget>[
                                            Container(
                                              height: 198.0,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(Radius.circular(12.0)),
                                                gradient: LinearGradient(
                                                  end: Alignment.bottomLeft,
                                                  begin: Alignment.topRight,
                                                  stops: [-0.1779, -0.1213, -0.0837,  0.6693, 1.2202, 1.3285],
                                                  colors: [ HexColor('#EBC08D'),  HexColor('#EBC08D'),  HexColor('#EBC08D'), HexColor('#F24645'), HexColor('#F24645'), HexColor('#F24645')],
                                                  tileMode: TileMode.mirror
                                                ),
                                              ),
                                              padding: const EdgeInsets.only(top: 60.0, left: 20.0, right: 20.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(card['cardNumber'], style: TextStyle(color: Colors.white, fontSize: 20.0),),
                                                  SizedBox(height: 30.0,),
                                                  Text('exp  ' + card['expiry'].toUpperCase(), style: TextStyle(color: Colors.white, fontSize: 12.0), ),
                                                  SizedBox(height: 4.0,),
                                                  Text(card['holderName'].toUpperCase(), style: TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold),),
                                                ],
                                              )
                                            ),
                                            Positioned(
                                              right: -130.0,
                                              bottom: -140,
                                              child: Image.asset('icons/jcb.png', width: 240.0,),
                                            )
                                          ],
                                        ),
                                      )
                                    );
                                  }

                                  cardWidgets.add(SizedBox(height: 20.5,));
                                }
                                return Column(
                                  children: cardWidgets,
                                );
                              }
                          }
                        }
                      ),
                      SizedBox(height: 20.5,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image.asset('icons/visa-1.png', width: 48.0,),
                          SizedBox(width: 20.0,),
                          Image.asset('icons/master-1.png', width: 48.0,),
                          SizedBox(width: 20.0,),
                          Image.asset('icons/jcb-1.png', width: 48.0,)
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ),
          ],
        ),
      ),
    ); 
  }
}


class DashPathBorder extends Border {
  DashPathBorder({
    @required this.dashArray,
    BorderSide top = BorderSide.none,
    BorderSide left = BorderSide.none,
    BorderSide right = BorderSide.none,
    BorderSide bottom = BorderSide.none,
  }) : super(
          top: top,
          left: left,
          right: right,
          bottom: bottom,
        );

  factory DashPathBorder.all({
    BorderSide borderSide = const BorderSide(),
    @required CircularIntervalList<double> dashArray,
  }) {
    return DashPathBorder(
      dashArray: dashArray,
      top: borderSide,
      right: borderSide,
      left: borderSide,
      bottom: borderSide,
    );
  }
  final CircularIntervalList<double> dashArray;

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    TextDirection textDirection,
    BoxShape shape = BoxShape.rectangle,
    BorderRadius borderRadius,
  }) {
    if (isUniform) {
      switch (top.style) {
        case BorderStyle.none:
          return;
        case BorderStyle.solid:
          switch (shape) {
            case BoxShape.circle:
              assert(borderRadius == null,
                  'A borderRadius can only be given for rectangular boxes.');
              canvas.drawPath(
                dashPath(Path()..addOval(rect), dashArray: dashArray),
                top.toPaint(),
              );
              break;
            case BoxShape.rectangle:
              if (borderRadius != null) {
                final RRect rrect =
                    RRect.fromRectAndRadius(rect, borderRadius.topLeft);
                canvas.drawPath(
                  dashPath(Path()..addRRect(rrect), dashArray: dashArray),
                  top.toPaint(),
                );
                return;
              }
              canvas.drawPath(
                dashPath(Path()..addRect(rect), dashArray: dashArray),
                top.toPaint(),
              );

              break;
          }
          return;
      }
    }

    assert(borderRadius == null,
        'A borderRadius can only be given for uniform borders.');
    assert(shape == BoxShape.rectangle,
        'A border can only be drawn as a circle if it is uniform.');
  }
}