import 'package:farax/components/hex_color.dart';
import 'package:farax/pages/delivering_orders.dart';
import 'package:farax/services/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/order_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/auth_utils.dart';
import '../utils/network_utils.dart';
import '../all_translations.dart';

class ShopScreen extends StatefulWidget {
  ShopScreen(this.setShopQuantity);

  Function(int) setShopQuantity;

  @override
  _ShopScreenState createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
	Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences _sharedPreferences;
	var _authToken, _confirmOrders, _processingOrders, _deliveringOrders;

  @override
	void initState() {
		super.initState();
		_fetchSessionAndNavigate();
	}

  _fetchSessionAndNavigate() async {
		_sharedPreferences = await _prefs;
		String authToken = AuthUtils.getToken(_sharedPreferences);
    var network = Provider.of<ConnectionStatus>(context);
    if(network == ConnectionStatus.offline) {
      NetworkUtils.showSnackBar(_scaffoldKey, allTranslations.text('you_are_offline'));
    } else {
      if(mounted) {
        setState(() {
          _authToken = authToken;
        });
      }

      if(_authToken == null) {
        _logout();
      } else {

      var responseJson = await NetworkUtils.fetch(authToken, '/api/Orders/shop');
      if(responseJson == null) {

        NetworkUtils.showSnackBar(_scaffoldKey, allTranslations.text('something_went_wrong'));

      } else if(responseJson == 'NetworkError') {

        NetworkUtils.showSnackBar(_scaffoldKey, null);

      } else if(responseJson['error'] != null) {

        print(responseJson['error']);

      } else {
      
          if(responseJson['confirm'].length > 0) {
            await showDialog<String>(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) => new DialogConfirmOrder(order: responseJson['confirm'][0], 
              length: responseJson['confirm'].length, 
              authToken: authToken, scaffoldKey: _scaffoldKey, 
              sharedPreferences: _sharedPreferences)
            );
          }
          widget.setShopQuantity(responseJson['orders'].length);

          if(mounted) {
            setState(() {
              _confirmOrders = responseJson['confirm'];
              _processingOrders = responseJson['orders'];
              _deliveringOrders = responseJson['deliverings'];
            });
          }
        }
      }
    }
	}

  Future<dynamic> _getShopOrders() async {
    _sharedPreferences = await _prefs;
		String authToken = AuthUtils.getToken(_sharedPreferences);
    return NetworkUtils.fetch(authToken, '/api/Orders/shop');
    
  }

  _logout() {
		NetworkUtils.logoutUser(_scaffoldKey.currentContext, _sharedPreferences);
	}

  Future<void> _refreshListOrder() async {
    _fetchSessionAndNavigate();
  }

  @override
  Widget build(BuildContext context) {
    var network = Provider.of<ConnectionStatus>(context);
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        color: Color.fromRGBO(242, 242, 242, 1),
        child: network == ConnectionStatus.offline ? Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              decoration: BoxDecoration(
                color: Colors.black
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(allTranslations.text('you_are_offline'), style: TextStyle(color: Colors.white),), 
                  SizedBox(
                    child: CircularProgressIndicator(strokeWidth: 2.0,),
                    height: 16.0,
                    width: 16.0,
                  ),
                ],
              )
            )
          ],
        ) :FutureBuilder(
          future: _getShopOrders(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return Text(allTranslations.text('something_wrong'));
              case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator(),);
              case ConnectionState.active:
                return Text('');
              case ConnectionState.done:
                if(snapshot.hasError) {

                } else {
                  dynamic responseJson = snapshot.data;
                  if(responseJson == 'NetworkError') {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    _confirmOrders = responseJson['confirm'];
                    _processingOrders = responseJson['orders'];
                    _deliveringOrders = responseJson['deliverings'];
                    return RefreshIndicator(
                      onRefresh: () {
                        _refreshListOrder();
                      },
                        child: Column(
                        children: <Widget>[
                          _deliveringOrders != null && _deliveringOrders.length > 0 ? Container(
                            padding: const EdgeInsets.only(left: 16, right: 16),
                            child: Column(
                              children: <Widget>[
                                SizedBox(height: 24,),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(Radius.circular(3)),
                                    boxShadow: [
                                      new BoxShadow(
                                        color: Color.fromRGBO(0, 0, 0, 0.2),
                                        blurRadius: 5,
                                        spreadRadius: 2
                                      )
                                    ],
                                  ),
                                  
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(_scaffoldKey.currentContext, MaterialPageRoute(
                                        builder: (context) => DeliveringOrders(_deliveringOrders)
                                      ));
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Text(allTranslations.text('delivering') + '...'),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Navigator.push(_scaffoldKey.currentContext, MaterialPageRoute(
                                              builder: (context) => DeliveringOrders(_deliveringOrders)
                                            ));
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Row(
                                            children: <Widget>[
                                              Text(_deliveringOrders.length.toString() + ' ' + allTranslations.text(_deliveringOrders.length == 1 ? 'order' : 'orders'), style: TextStyle(color: HexColor('#0099CC')),),
                                              SizedBox(width: 12,),
                                              Icon(Icons.arrow_forward_ios, size: 14, color:  HexColor('#0099CC'),)
                                            ],
                                          )
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                )
                              ],
                            ),
                          ) : IgnorePointer(
                            ignoring: true,
                            child: Opacity(
                              opacity: 0.0,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              padding: const EdgeInsets.only(left: 16, right: 11),
                              child: _processingOrders != null && !_processingOrders.isEmpty ? RefreshIndicator(
                                child: ListView.builder(
                                  itemCount: _processingOrders.length,
                                  itemBuilder: (context, position) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 30, right: 5),
                                      child: OrderItem(order: _processingOrders[position], isGoToDeliveringPage: false,),
                                    );
                                  }
                                ),
                                onRefresh: () {
                                  setState(() {});
                                },
                              ) : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Image.asset('icons/no-order.png'),
                                    SizedBox(height: 16),
                                    Text(allTranslations.text('no_order_text'))
                                  ]
                                )
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  }
                }
            }
          },
        )
      ),
    );
  }
}