import 'package:farax/components/fab_bar.dart';
import 'package:farax/components/gradient_appbar.dart';
import 'package:farax/components/hex_color.dart';
import 'package:farax/pages/shop/profile_shop.dart';
import 'package:farax/utils/auth_utils.dart';
import 'package:farax/utils/network_utils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../all_translations.dart';
import 'cod_screen.dart';
import 'create_package.dart';
import 'home_shop.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:farax/services/connectivity.dart';
import '../../components/offline_notification.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  int _selectedIndex = 2;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
	Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences _sharedPreferences;
  static const snackBarDuration = Duration(seconds: 3);
  bool isOffline;
  final snackBar = SnackBar(
    content: Text(''),
    duration: snackBarDuration,
  );

  DateTime backButtonPressTime;
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

  Future<List<dynamic>> _getNotifications() async {
    _sharedPreferences = await _prefs;

    String userId = _sharedPreferences.getString('user_id');
    String authToken = AuthUtils.getToken(_sharedPreferences);

    return http.get('https://camships.com:3000/api/Notifications?access_token=${authToken}&filter={"where": {"receiver": "${userId}"}, "order": "updatedOn DESC"}').then((response) => json.decode(response.body));
  }

  Future<bool> onWillPop() async {
    DateTime currentTime = DateTime.now();

    bool backButtonHasNotBeenPressedOrSnackBarHasBeenClosed =
        backButtonPressTime == null ||
            currentTime.difference(backButtonPressTime) > snackBarDuration;

    if (backButtonHasNotBeenPressedOrSnackBarHasBeenClosed) {
      backButtonPressTime = currentTime;
      _scaffoldKey.currentState.showSnackBar(snackBar);
      return false;
    }

    return true;
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
            child: Column(
              children: <Widget>[
                GradientAppBar(title: allTranslations.text('notification_tab')),
                Expanded(
                  flex: 1,
                  child: isOffline? OfflineNotification():Container(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    width: double.infinity,
                    color: Color.fromRGBO(242, 242, 242, 1),
                    child: FutureBuilder(
                      future: _getNotifications(),
                      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.none:
                            return new Text(allTranslations.text('something_wrong'));
                          case ConnectionState.waiting:
                            return new Center(child: CircularProgressIndicator(),);
                          case ConnectionState.active:
                            return new Text('');
                          case ConnectionState.done:
                            if(snapshot.hasData) {
                              return snapshot.data.length > 0 ? ListView.builder(
                                itemCount: snapshot.data.length,
                                itemBuilder: (context, index) {
                                  return Slidable(
                                    key: ValueKey(index),
                                    actionPane: SlidableScrollActionPane(),
                                    actionExtentRatio: 0.25,
                                    secondaryActions: <Widget>[
                                      IconSlideAction(
                                        caption: 'Delete',
                                        color: Colors.red,
                                        icon: Icons.delete,
                                        onTap: () => {},
                                      ),
                                    ],
                                    dismissal: SlidableDismissal(
                                      child: SlidableDrawerDismissal(),
                                      onDismissed: (actionType) {
                                        
                                      },
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border(
                                          bottom: BorderSide(
                                            width: 1.0,
                                            style: BorderStyle.solid,
                                            color: HexColor('#DFE4EA')
                                          )
                                        )
                                      ),
                                      child: Row(
                                        children: <Widget>[
                                          Stack(
                                            children: <Widget>[
                                              CircleAvatar(
                                                backgroundColor: HexColor('#0099CC'),
                                                child: Icon(Icons.mail, size: 20, color: Colors.white),
                                              ),
                                              Positioned(
                                                right: 1,
                                                top: 2,
                                                child: Icon(Icons.lens, size: 10, color: HexColor('#FF9933'),),
                                              )
                                            ],
                                          ),
                                          SizedBox(width: 10.0,),
                                          Expanded(
                                            flex: 1,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(snapshot.data[index]['title'], style: TextStyle(color: HexColor('#455A64'), fontWeight: FontWeight.bold),),
                                                SizedBox(height: 4.0,),
                                                Text(snapshot.data[index]['data']['sentence'], style: TextStyle(color: HexColor('#78909C'), fontSize: 12),)
                                              ],
                                            ),
                                          ),
                                          // GestureDetector( onTap: () {}, child: Icon(Icons.chevron_right, color: HexColor('#0099CC'),)),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ) : Container(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Image.asset('icons/no-notification.png', width: 200,),
                                    SizedBox(height: 16),
                                    Text(allTranslations.text('no_notification_text'))
                                  ]
                                ),
                              );
                            } else {
                              return Container(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Image.asset('icons/no-order.png'),
                                    SizedBox(height: 16),
                                    Text(allTranslations.text('no_order_text'))
                                  ]
                                ),
                              );
                            }
                        }
                      },
                    )
                  ),
                ),
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
            selectedIndex: _selectedIndex,
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