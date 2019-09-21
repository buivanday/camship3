import 'package:farax/blocs/shop_api.dart';
import 'package:farax/components/gradient_appbar.dart';
import 'package:farax/components/hex_color.dart';
import 'package:farax/utils/auth_utils.dart';
import 'package:farax/utils/network_utils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../all_translations.dart';
import 'dart:convert';
import 'package:date_format/date_format.dart';

class DeliveryStatus extends StatefulWidget {
  DeliveryStatus({
    Key key,
    this.order,
  }) : super(key: key);

  final ShopOrder order;

  @override
  _DeliveryStatusState createState() => _DeliveryStatusState();
}

class _DeliveryStatusState extends State<DeliveryStatus> {
  bool _isValid = true;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
	Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences _sharedPreferences;

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

  Future<List<dynamic>> _getHistories() async {
    _sharedPreferences = await _prefs;
    String authToken = AuthUtils.getToken(_sharedPreferences);
    String historyUrl = 'https://camships.com:3000/api/Orders/${widget.order.id}/history?access_token=${authToken}';
    print(historyUrl);
    return http.get('https://camships.com:3000/api/Orders/${widget.order.id}/history?access_token=${authToken}').then((response) => json.decode(response.body));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        color: Color.fromRGBO(242, 242, 242, 1),
        child: Column(
          children: <Widget>[
            GradientAppBar(title: allTranslations.text('delivery_status'),hasBackIcon: true),
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(4.0))
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(allTranslations.text('order_id'), style: TextStyle(color: HexColor('#78909C'), fontSize: 12.0),),
                            SizedBox(height: 4.0,),
                            Text(widget.order.orderId.toUpperCase(), style: TextStyle(color: HexColor('#455A64'), fontSize: 18.0, fontWeight: FontWeight.bold),),
                            SizedBox(height: 16.0,),
                            Image.asset('icons/Line.png', width: double.infinity, fit: BoxFit.fitWidth),
                            SizedBox(height: 16.0,),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 2,
                                  child: Text(allTranslations.text('delivery_time') + ':', style: TextStyle(color: HexColor('#455A64'), fontSize: 14.0),),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: Text(widget.order.delivery['time'].toString() +  ' ' +allTranslations.text('hours'), style: TextStyle(color: HexColor('#455A64'), fontSize: 14.0),),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30.0,),
                      FutureBuilder(
                        future: _getHistories(),
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
                                if(snapshot.data.length == 0) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Image.asset('icons/no-order.png'),
                                        SizedBox(height: 16),
                                        Text(allTranslations.text('no_status_text'))
                                      ]
                                    ),
                                  );
                                } else {
                                  List<Widget> listStatuses = new List<Widget>();
                                  for (var i = snapshot.data.length - 1; i >= 0; i--) {
                                    var status = snapshot.data[i];
                                    if(i == snapshot.data.length - 1) {
                                      listStatuses.add(new DeliveryStatusActive(isFirst: i == snapshot.data.length - 1,isLast: snapshot.data.length == 1, title: status['title'], subtitle: status['subtitle'], createdOn: status['createdOn']));
                                    } else {
                                      listStatuses.add(new DeliveryStatusInActive(isLast: i == 0, title: status['title'], subtitle: status['subtitle'], createdOn: status['createdOn']));
                                    }
                                    
                                  }

                                  return Column(
                                    children: listStatuses,
                                  );
                                }
                              }
                          }
                        }
                      )
                    ],
                  ),
                )
              ),
            ),
          ]
        )
      )
    );
  }
}

class DeliveryStatusActive extends StatelessWidget {
  const DeliveryStatusActive({
    Key key,
    this.isFirst,
    this.isLast,
    this.title,
    this.subtitle,
    this.createdOn
  }) : super(key: key);

  final bool isFirst;
  final bool isLast;
  final String title;
  final String subtitle;
  final String createdOn;

  replaceTAndZ(String time) => time.replaceAll('T',' ').replaceAll('Z', ' ').substring(0, time.length - 5);

  String convertDateFromString(String strDate){
    DateTime todayDate = DateTime.parse(strDate).toUtc();
    return formatDate(todayDate, [dd, '/', mm, '/', yyyy, ', ', hh, ':', nn]);
  }

  @override
  Widget build(BuildContext context) {
    print(title.length);
    return Row(
      children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              width: 1.0,
              height: 40.5 + (title.length > 40 ? 5 : 0),
              color: isFirst == false ? HexColor('#CED4DA') : Colors.transparent,
            ),
            Icon(Icons.lens, size: 10, color: HexColor('#FF9933'),),
            Container(
              width: 1.0,
              height: 40.5 + (title.length > 40 ? 5 : 0),
              color: isLast == false ? HexColor('#CED4DA') : Colors.transparent,
            ),
          ],
        ),
        SizedBox(
          width: 20.0,
        ),
        Expanded(
          flex: 1,
          child: Container(
            height: 91.0 + (title.length > 40 ? 10.0 : 0),
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: HexColor('#CED4DA')
                )
              )
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(convertDateFromString(replaceTAndZ(createdOn)), style: TextStyle(color: HexColor('#78909C'), fontSize: 12.0),),
                Text(allTranslations.text(title).toUpperCase(), style: TextStyle(color: HexColor('#FF9933'), fontWeight: FontWeight.bold, fontSize: 14.0),),
                Text(subtitle, style: TextStyle(color: HexColor('#455A64'), fontSize: 12.0))
              ],
            ),
          )
        )
      ],
    );
  }
}

class DeliveryStatusInActive extends StatelessWidget {
  const DeliveryStatusInActive({
    Key key,
    this.isFirst,
    this.isLast,
    this.title,
    this.subtitle,
    this.createdOn
  }) : super(key: key);

  final bool isFirst;
  final bool isLast;
  final String title;
  final String subtitle;
  final String createdOn;

  replaceTAndZ(String time) => time.replaceAll('T',' ').replaceAll('Z', ' ').substring(0, time.length - 5);

  String convertDateFromString(String strDate){
    DateTime todayDate = DateTime.parse(strDate).toUtc();
    return formatDate(todayDate, [dd, '/', mm, '/', yyyy, ', ', hh, ':', nn]);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              width: 1.0,
              height: 40.5 + (title.length > 40 ? 5 : 0),
              color: isFirst == false || isFirst == null ? HexColor('#CED4DA') : Colors.transparent,
            ),
            Icon(Icons.lens, size: 10, color: HexColor('#B0BEC5'),),
            Container(
              width: 1.0,
              height: 40.5 + (title.length > 40 ? 5 : 0),
              color: isLast == false || isLast == null ? HexColor('#CED4DA') : Colors.transparent,
            ),
          ],
        ),
        SizedBox(
          width: 20.0,
        ),
        Expanded(
          flex: 1,
          child: Container(
            height: 91.0 + (title.length > 40 ? 10.0 : 0),
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: HexColor('#CED4DA')
                )
              )
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(convertDateFromString(replaceTAndZ(createdOn)), style: TextStyle(color: HexColor('#78909C'), fontSize: 12.0),),
                Text(allTranslations.text(title).toUpperCase(), style: TextStyle(color: HexColor('#90A4AE'), fontWeight: FontWeight.bold, fontSize: 14.0),),
                Text(subtitle, style: TextStyle(color: HexColor('#455A64'), fontSize: 12.0))
              ],
            ),
          )
        )
      ],
    );
  }
}