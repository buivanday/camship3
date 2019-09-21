import 'package:farax/components/almost_done_item.dart';
import 'package:farax/components/warehouse_item.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/auth_utils.dart';
import '../utils/network_utils.dart';
import '../all_translations.dart';
import 'package:farax/components/hex_color.dart';
import '../pages/shipper/almost_done_orders.dart';

class WarehouseScreen extends StatefulWidget {
  WarehouseScreen(this.setWarehouseQuantity);

  Function(int) setWarehouseQuantity;
  @override
  _WarehouseScreenState createState() => _WarehouseScreenState();
}

class _WarehouseScreenState extends State<WarehouseScreen> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences _sharedPreferences;
  var _authToken, _confirmOrders, _processingOrders, _deliveringOrders;
  @override
  void initState() {
    super.initState();
  }

  Future _getWarehouseOrders() async {
    _sharedPreferences = await _prefs;
    String authToken = AuthUtils.getToken(_sharedPreferences);

    return NetworkUtils.fetch(authToken, '/api/Orders/warehouse');
  }

  Future _getAlmostDoneOrders() async {
    _sharedPreferences = await _prefs;
    String authToken = AuthUtils.getToken(_sharedPreferences);

    return NetworkUtils.fetch(authToken, '/api/Orders/almost-done');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
          padding: const EdgeInsets.only(left: 16, right: 11),
          child: Column(
            children: <Widget>[
              Container(
                constraints: BoxConstraints(
                  maxHeight: 100
                ),
                child: FutureBuilder(
                  future: _getAlmostDoneOrders(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                        return Text(allTranslations.text('something_wrong'));
                      case ConnectionState.waiting:
                        return Center(
                         // child: CircularProgressIndicator(),
                        );
                      case ConnectionState.active:
                        return Text('');
                      case ConnectionState.done:
                        if (snapshot.hasError) {
                          return Text('error');
                        } else {
                          if (snapshot.hasData) {
                            if (snapshot.data.length > 0) {
                              return Container(
                                padding:
                                    const EdgeInsets.only(left: 16, right: 16),
                                child: Column(
                                  children: <Widget>[
                                    SizedBox(
                                      height: 24,
                                    ),
                                    Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(3)),
                                          boxShadow: [
                                            new BoxShadow(
                                                color: Color.fromRGBO(
                                                    0, 0, 0, 0.2),
                                                blurRadius: 5,
                                                spreadRadius: 2)
                                          ],
                                        ),
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                                _scaffoldKey.currentContext,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        AlmostDoneOrders(
                                                            snapshot.data['orders'])));
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                child: Text(allTranslations
                                                        .text('money_back') +
                                                    '...'),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  Navigator.push(
                                                      _scaffoldKey
                                                          .currentContext,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              AlmostDoneOrders(
                                                                  snapshot
                                                                      .data['orders'])));
                                                },
                                                child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    child: Row(
                                                      children: <Widget>[
                                                        Text(
                                                          "${snapshot.data['total']} orders ", //_deliveringOrders.length.toString() + ' ' + allTranslations.text(_deliveringOrders.length == 1 ? 'order' : 'orders'),
                                                          style: TextStyle(
                                                              color: HexColor(
                                                                  '#0099CC')),
                                                        ),
                                                        SizedBox(
                                                          width: 12,
                                                        ),
                                                        Icon(
                                                          Icons
                                                              .arrow_forward_ios,
                                                          size: 14,
                                                          color: HexColor(
                                                              '#0099CC'),
                                                        )
                                                      ],
                                                    )),
                                              )
                                            ],
                                          ),
                                        ))
                                  ],
                                ),
                              );
                            } else {
                              return Container();
                            }
                          } else {
                            return Container();
                          }
                        }
                    }
                  }),
              ),
              Expanded(
                flex: 1,
                child: FutureBuilder(
                    future: _getWarehouseOrders(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                          return Text(allTranslations.text('something_wrong'));
                        case ConnectionState.waiting:
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        case ConnectionState.active:
                          return Text('');
                        case ConnectionState.done:
                          if (snapshot.hasError) {
                            return Text('error');
                          } else {
                            var _orders = snapshot.data;
                            if (_orders == 'NetworkError') {
                              return Center(
                                child: CircularProgressIndicator(
                                  semanticsValue: 'Network error',
                                ),
                              );
                            } else {
                              List<Widget> _almostDones = new List<Widget>();
                              for(var i = 0; i < _orders.length; i ++) {
                                _almostDones.add(AlmostDoneItem(order: _orders[i],));
                                _almostDones.add(SizedBox(
                                      height: 24,
                                    ),);
                              }
                              return RefreshIndicator(
                                onRefresh: _getWarehouseOrders,
                                child: Container(
                                  padding: const EdgeInsets.only(
                                      left: 16, right: 11),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: _almostDones,
                                    )
                                  )
                                ),
                                
                              );
                            }
                          }
                      }
                    }),
              )
            ],
          )),
    );
  }
}
