import 'dart:async';

import 'package:farax/blocs/shop_api.dart';
import 'package:farax/components/gradient_appbar.dart';
import 'package:farax/components/hex_color.dart';
import 'package:farax/pages/shop/create_package.dart';
import 'package:farax/utils/auth_utils.dart';
import 'package:farax/utils/network_utils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../all_translations.dart';
import 'package:provider/provider.dart';
import 'package:farax/services/connectivity.dart';
import '../../components/offline_notification.dart';
import 'home_shop.dart';


class CashedOutScreen extends StatefulWidget {
  @override
  _CashedOutScreenState createState() => _CashedOutScreenState();
}

class _CashedOutScreenState extends State<CashedOutScreen> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
	Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences _sharedPreferences;
  bool isOffline;
  var account;
  @override
	void initState() {
		super.initState();
	}

  Future _getCashedOutBills() async {
    _sharedPreferences = await _prefs;
    String authToken = AuthUtils.getToken(_sharedPreferences);
    String endPoint = '/api/Orders/cashed-out';
    return  NetworkUtils.fetch(authToken, endPoint);
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

    var now = new DateTime.now();
    int _month = now.month;
    return DefaultTabController(
      initialIndex: _month - 1,
        length: 12,
        child: Scaffold(
          key: _scaffoldKey,
          body: Container(
            child:  Column(
              children: <Widget>[
                GradientAppBar(title: allTranslations.text('cashed_out_bills_title'), hasBackIcon: true,),
               PreferredSize(
                child: TabBar(
                    isScrollable: true,
                    unselectedLabelColor: Colors.black12.withOpacity(0.2),
                    labelColor: Colors.black,
                    indicatorColor: HexColor('#0099CC'),
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorWeight: 2.5,
                    tabs: [
                      Tab(
                        child: Text('January'),
                      ),
                      Tab(
                        child: Text('February'),
                      ),
                      Tab(
                        child: Text('March'),
                      ),
                      Tab(
                        child: Text('April'),
                      ),
                      Tab(
                        child: Text('May'),
                      ),
                      Tab(
                        child: Text('June'),
                      ),
                      Tab(
                        child: Text('July'),
                      ),
                      Tab(
                        child: Text('August'),
                      ),
                      Tab(
                        child: Text('September'),
                      ),
                      Tab(
                        child: Text('October'),
                      ),
                      Tab(
                        child: Text('November'),
                      ),
                      Tab(
                        child: Text('December'),
                      ),
                    ]),
                preferredSize: Size.fromHeight(30.0)),
                Expanded(
                  flex: 1,
                  child: isOffline? OfflineNotification():Container(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    width: double.infinity,
                    color: Color.fromRGBO(242, 242, 242, 1),
                    child: FutureBuilder(
                      future: _getCashedOutBills(),
                      builder:(BuildContext context, AsyncSnapshot snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.none:
                            return Text(allTranslations.text('something_wrong'));
                          case ConnectionState.waiting:
                            return Center(child: CircularProgressIndicator(),);
                          case ConnectionState.active:
                            return Text('');
                          case ConnectionState.done: {
                            if(snapshot.hasData) {
                              List<Widget> _list = new List<Widget>();
                              for(var i = 0; i < snapshot.data.length; i++) {
                                dynamic bill = snapshot.data[i];
                                if(bill['count'] == 0) {
                                  _list.add(NoCashedOutBills());
                                } else {
                                  _list.add(CashedOutBills(bill: bill));
                                }
                              }
                              return TabBarView(
                                children: _list,
                              );

                              
                            } else {
                              return TabBarView(
                                children: <Widget>[
                                  NoCashedOutBills(),
                                  NoCashedOutBills(),
                                  NoCashedOutBills(),
                                  NoCashedOutBills(),
                                  NoCashedOutBills(),
                                  NoCashedOutBills(),
                                  NoCashedOutBills(),
                                  NoCashedOutBills(),
                                  NoCashedOutBills(),
                                  NoCashedOutBills(),
                                  NoCashedOutBills(),
                                  NoCashedOutBills(),
                                ],
                              );
                            }
                          }
                        }
                      }
                    )
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }
}

class CashedOutBills extends StatefulWidget {
  const CashedOutBills({
    Key key,
    @required this.bill
  }) : super(key: key);

  final dynamic bill;

  @override
  _CashedOutBillsState createState() => _CashedOutBillsState();
}

class _CashedOutBillsState extends State<CashedOutBills> {
  List<ShopOrder> _orders = new List<ShopOrder>();
  
  @override
	void initState() {
		super.initState();
    SearchResult orders = SearchResult.fromJson(widget.bill['orders']);
    if(mounted) {
      setState(() {
        _orders = orders.items;
      });
    } else {
      _orders = orders.items;
    }
	}

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Align(
        alignment: Alignment.centerLeft,
        child: Row(
          children: <Widget>[
            Text(allTranslations.text('total') + ':', textAlign: TextAlign.start,),
            Text(widget.bill['count'].toString(), style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),)
          ],
        )
      ),
      Expanded(
        flex: 1,
        child: SearchResultWidget(items: _orders, fromCashedOut: true),
      )
    ],);
  }
}

class NoCashedOutBills extends StatefulWidget {
  NoCashedOutBills({Key key}) : super(key: key);

  _NoCashedOutBillsState createState() => _NoCashedOutBillsState();
}

class _NoCashedOutBillsState extends State<NoCashedOutBills> {
  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Color(0xFFF9F9F9),
      body: SingleChildScrollView(
        child: Container(
          height: _height - 170,
          width: double.infinity,
          child: ListView(
            children: <Widget>[_transaction()],
          ),
        ),
      ),
    );
  }

  ///
  /// Box don't have transaction
  ///
  Widget _transaction() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15.0,
                  spreadRadius: 0.0)
            ]),
        child: Padding(
          padding: const EdgeInsets.only(
              left: 12.0, right: 12.0, top: 15.0, bottom: 15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 20.0,
              ),
              Text(
                allTranslations.text('no_cashed_out_bills_in_this_month'),
                style: TextStyle(
                    color: Colors.black,
                    fontFamily: "Popins",
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 15.0,
              ),
              Image.asset(
                "icons/no-billing.png",
                height: 250.0,
              ),
              SizedBox(
                height: 15.0,
              ),
              Text(
                allTranslations.text('create_new_order_from_cashed_out'),
                style: TextStyle(
                  color: Colors.black54,
                  fontFamily: "Popins",
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 15.0,
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    new PageRouteBuilder(
                      pageBuilder: (BuildContext context, _, __) {
                        return CreatePackage();
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
                  child: new Center(child: Text(allTranslations.text('create_order').toUpperCase(), style: TextStyle(color: HexColor('#FF9933'), fontSize: 14, fontWeight: FontWeight.bold),),),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
