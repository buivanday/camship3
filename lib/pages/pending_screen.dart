import 'package:farax/components/order_item.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/auth_utils.dart';
import '../utils/network_utils.dart';
import '../all_translations.dart';

class PendingScreen extends StatefulWidget {
  PendingScreen(this.setPendingQuantity);

  Function(int) setPendingQuantity;
  
  @override
  _PendingScreenState createState() => _PendingScreenState();
}

class _PendingScreenState extends State<PendingScreen> {
	Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences _sharedPreferences;

  @override
	void initState() {
		super.initState();
	}

  Future _getPendingOrders() async {
    _sharedPreferences = await _prefs;
		String authToken = AuthUtils.getToken(_sharedPreferences);

    return NetworkUtils.fetch(authToken, '/api/Orders/pending');
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.only(left: 16, right: 11),
        child: FutureBuilder(
          future: _getPendingOrders(),
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
                  return Text('error');
                } else {
                  var _orders = snapshot.data;
                  if(_orders == 'NetworkError') {
                    return Center(child: CircularProgressIndicator(),);
                  } else {
                    return _orders != null && !_orders.isEmpty ? ListView.builder(
                      itemCount: _orders.length,
                      itemBuilder: (context, position) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 30, right: 5),
                          child: OrderItem(order: _orders[position], isGoToDeliveringPage: false,),
                        );
                      }
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
                    );
                  }
                }
            }
          }
        )
      ),
    );
  }
}