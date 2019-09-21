import 'package:farax/blocs/search_bloc.dart';
import 'package:farax/blocs/search_state.dart';
import 'package:farax/blocs/shop_api.dart';
import 'package:farax/components/fab_bar.dart';
import 'package:farax/components/hex_color.dart';
import 'package:farax/components/search_loading_widget.dart';
import 'package:farax/pages/shop/profile_shop.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:farax/services/connectivity.dart';

import '../../all_translations.dart';
import '../../components/gradient_appbar.dart';
import 'cod_screen.dart';
import 'create_package.dart';
import 'create_package_detail.dart';
import 'notification_screen.dart';
import 'package:date_format/date_format.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/offline_notification.dart';

class HomeShop extends StatefulWidget {
  final ShopApi api;
  HomeShop({Key key, ShopApi api})
      : this.api = api ?? ShopApi(),
        super(key: key);

  @override
  _HomeShopState createState() => _HomeShopState();
}


class _HomeShopState extends State<HomeShop> {
  int _selectedIndex = 0;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var _searchOrderController = new TextEditingController();
  SearchBloc _searchBloc;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences _sharedPreferences;
  bool isOffline;
  @override
	void initState() {
		super.initState();

    _searchBloc = SearchBloc(widget.api);
    _deletePref();
	}
  _deletePref()async{
    _sharedPreferences = await _prefs;
   _sharedPreferences.remove('Deliverytime');
                    
                     _sharedPreferences.remove('HeightNumber');
                    _sharedPreferences.remove('LengthNumber');
                    _sharedPreferences.remove('NoteTxt');
                     _sharedPreferences.remove('packageType');
                    _sharedPreferences.remove('isPageTwoExist');
                     _sharedPreferences.remove('isPageThreeExist');
                  
                     _sharedPreferences.remove('PromptionCode');
                     _sharedPreferences.remove('Service');
                     _sharedPreferences.remove('TotalService');
                     _sharedPreferences.remove('Weight');
                     _sharedPreferences.remove('WeightNumber');
                    _sharedPreferences.remove('WhoPay');
                    _sharedPreferences.remove('WidthNumber');
                   _sharedPreferences.remove('dataPageOne');

                     _sharedPreferences.setBool("isPageTwoExist", false);
                     _sharedPreferences.setBool("isPageThreeExist", false);
    
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
  
  @override
  void dispose() {
    _searchBloc.dispose();
    super.dispose();
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
                GradientAppBar(title: allTranslations.text('home_title')),
                Expanded(
                  child: isOffline ? OfflineNotification() :  Container(
                    color: Color.fromRGBO(242, 242, 242, 1),
                    padding: const EdgeInsets.all(16),
                    child: StreamBuilder(
                      stream: _searchBloc.state,
                      initialData: SearchAll(),
                      builder: (BuildContext context, AsyncSnapshot<SearchState> snapshot) {
                        final state = snapshot.data;
                        if(state is SearchAll) {
                          _searchBloc.onTextChanged.add('all');
                        }
                        return Column(
                          children: <Widget>[
                            Container(
                              height: 42.0,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(Radius.circular(4))
                              ),
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: allTranslations.text('search_placeholder'),
                                  hintStyle: TextStyle(color: HexColor('#B0BEC5'), fontSize: 14),
                                  prefixIcon: Icon(Icons.search, color: HexColor('#0099CC'),),
                                  disabledBorder: InputBorder.none,
                                  border: InputBorder.none,
                                ),
                                controller: _searchOrderController,
                                onChanged: (term) {
                                  _searchBloc.onTextChanged.add(term);
                                },
                              ),
                            ),
                            // EmptyWidget(visible: state is SearchEmpty),
                            Expanded(
                              flex:1,
                              child: Stack(
                                children: <Widget>[
                                  LoadingWidget(visible: state is SearchLoading),
                                  EmptyWidget(visible: state is SearchEmpty),
                                  SearchResultWidget(
                                    items: state is SearchPopulated ? state.result.items : [],
                                  ),
                                  // SearchErrorWidget(visible: state is SearchError),
                                ],
                              ),
                            )
                          ],
                        );
                      },
                    )
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
            selectedIndex: 0,
            items: [
              FABBottomAppBarItem(iconData: Icons.home, text: allTranslations.text('home_tab')),
              FABBottomAppBarItem(iconData: Icons.account_balance_wallet, text: allTranslations.text('cod_tab')),
              FABBottomAppBarItem(iconData: Icons.notifications, text: allTranslations.text('notification_tab')),
              FABBottomAppBarItem(iconData: Icons.more_horiz, text: allTranslations.text('more_tab')),
            ],
          )
        )
      ),
    );
  }
}

class EmptyWidget extends StatelessWidget {
  final bool visible;

  const EmptyWidget({Key key, this.visible}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 300),
      opacity: visible ? 1.0 : 0.0,
      child: Container(
        alignment: FractionalOffset.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset('icons/no-order.png'),
            SizedBox(height: 16),
            Text(allTranslations.text('no_order_text'))
          ]
        ),
      ),
    );
  }
}

class SearchResultWidget extends StatelessWidget {
  final bool visible;
  final List<ShopOrder> items;

  SearchResultWidget({Key key, @required this.items, bool visible}) 
      : this.visible = visible ?? items.isNotEmpty,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 300),
      opacity: visible ? 1.0 : 0.0,
      child: ListView.separated(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return new ShopOrderWidget(order: items[index]);
        },
        separatorBuilder: (context, index) {
          return SizedBox(height: 16,);
        },
      ),
    );
  }
}

class ShopOrderWidget extends StatefulWidget {
  const ShopOrderWidget({
    Key key,
    this.order,
  }) : super(key: key);
  final ShopOrder order;

  @override
  _ShopOrderWidgetState createState() => _ShopOrderWidgetState();
}

class _ShopOrderWidgetState extends State<ShopOrderWidget> {
  ShopOrder order;


  @override
	void initState() {
		super.initState();

    order = widget.order;
	}

  replaceTAndZ(String time) => time.replaceAll('T',' ').replaceAll('Z', ' ').substring(0, time.length - 5);

  String convertDateFromString(String strDate){
    DateTime todayDate = DateTime.parse(strDate).toUtc();
    return formatDate(todayDate, [dd, '/', mm, '/', yyyy, ', ', hh, ':', nn]);
  }
  String _getStatusName() {
    final STATUSES = [{
        'name': allTranslations.text('processing'),
        'value': 1,
    }, {
        'name': allTranslations.text('processing'),
        'value': 2,
    }, {
        'name': allTranslations.text('on_receiving'),
        'value': 3
    }, {
        'name': allTranslations.text('received'),
        'value': 4
    }, {
        'name': allTranslations.text('on_warehosing'),
        'value': 5
    }, {
        'name': allTranslations.text('on_shipping'),
        'value': 6
    }, {
        'name': allTranslations.text('almost_done'),
        'value': 7
    }, {
        'name': allTranslations.text('money_back'),
        'value': 8
    }, {
        'name': allTranslations.text('shipping_failed'), // Failed order: 9, 12
        'value': 9
    }, {
        'name': allTranslations.text('returned_to_warehouse'),
        'value': 10
    }, {
        'name': allTranslations.text('on_returning'),
        'value': 11
    }, {
        'name': allTranslations.text('shop_received'),
        'value': 12
    }, {
        'name': allTranslations.text('lost_package'),
        'value': 13
    }, {
        'name': allTranslations.text('completed_return_some_items'), //'Completed, return some items'
        'value': 14
    }, {
        'name': allTranslations.text('pending'),
        'value': 15
    }, {
        'name': allTranslations.text('confirmed_package_lost'),
        'value': 16
    }, {
        'name': allTranslations.text('refunded'),
        'value': 17
    }, {
      'name': allTranslations.text('closed'),
      'value': 18
    }, {
      'name': allTranslations.text('warehouse_confirmed'),
      'value': 19
    }, {
      'name': allTranslations.text('cancelled'),
      'value': 20
    }];

    return STATUSES[widget.order.currentStatusValue - 1]['name'];
  }
  
  Widget get _header => (
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(allTranslations.text('order_id'), style: TextStyle(color: HexColor('#78909C')),),
            SizedBox(height: 4,),
            Text(order.orderId.toString(), style: TextStyle(color: HexColor('#455A64'), fontSize: 18, fontWeight: FontWeight.bold),)
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            widget.order.isCashedOut ? Text('Cashed Out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),) : Container(),
            SizedBox(height: 2,),
            Text(_getStatusName(), style: TextStyle(color: HexColor('#4CAF50'), fontSize: 12.0),)
          ],
        ),
      ],
    )
  );

  Widget get _address => (
    Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Text(allTranslations.text('address') + ':', style: TextStyle(color: HexColor('#B0BEC5'), fontSize: 14),),
        ),
        Expanded(
          flex: 2,
          child: Text(order.receiver['address'], style: TextStyle(color: HexColor('#455A64')),),
        )
      ],
    )
  );

  Widget get _phone => (
    Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Text(allTranslations.text('phone') + ':', style: TextStyle(color: HexColor('#B0BEC5'), fontSize: 14),),
        ),
        Expanded(
          flex: 2,
          child: Text(order.receiver['phoneNumber'], style: TextStyle(color: HexColor('#455A64')),),
        )
      ],
    )
  );

  Widget get _timeCreate => (
    Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Text(allTranslations.text('time_create') + ':', style: TextStyle(color: HexColor('#B0BEC5'), fontSize: 14),),
        ),
        Expanded(
          flex: 2,
          child: Text(convertDateFromString(replaceTAndZ(order.createdOn)), style: TextStyle(color: HexColor('#455A64')),),
        )
      ],
    )
  );

  Widget get _timeReceive => (
    Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Text(allTranslations.text('time_receive') + ':', style: TextStyle(color: HexColor('#B0BEC5'), fontSize: 14),),
        ),
        Expanded(
          flex: 2,
          child: Text(convertDateFromString(replaceTAndZ(order.updatedOn)), style: TextStyle(color: HexColor('#455A64')),),
        )
      ],
    )
  );

  Widget get _deliveryTime => (
    Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Text(allTranslations.text('delivery_time') + ':', style: TextStyle(color: HexColor('#B0BEC5'), fontSize: 14),),
        ),
        Expanded(
          flex: 2,
          child: Text(order.orderPackages['deliveryTime']['time'].toString() + ' ' + allTranslations.text('hours'), style: TextStyle(color: HexColor('#455A64')),),
        )
      ],
    )
  );

  Widget get _fullName => (
    order.receiver != null ? Text(order.receiver['fullName'], style: TextStyle(color: HexColor('#0099CC'), fontWeight: FontWeight.bold, fontSize: 14),) : Container()
  );

  @override
  Widget build(BuildContext context) {
    double total = 0;
    if(order != null) {
      String extraService = order.orderPackages['extraService'];
      bool isShopPaid = order.orderPackages['isShopPaid'];
      dynamic valueOfOrder = order.valueOfOrder ?? 0;
      
      dynamic shippingCost = order.shippingCost ?? 0;
      dynamic totalCOD = order.totalCOD ?? 0;
      if(extraService == 'cod') {
        if(isShopPaid) {
          total += shippingCost + valueOfOrder + totalCOD;
        } else {
          total += totalCOD;
        }
      } else {
        total += shippingCost;
      }
    }
    
    return order == null ? Center(child:CircularProgressIndicator()) : InkWell(
      onTap: () async {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => CreatePackageDetail(order: order,)
        ));
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(4))
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _header,
            SizedBox(height: 16.0,),
            Image.asset('icons/Line.png', fit: BoxFit.cover, width: double.infinity,),
            SizedBox(height: 16.0,),
            _fullName,
            SizedBox(height: 10,),
            _address,
            SizedBox(height: 10,),
            _phone,
            SizedBox(height: 10,),
            _timeCreate,
            SizedBox(height: 10,),
            _timeReceive,
            SizedBox(height: 10,),
            _deliveryTime,
            SizedBox(height: 10,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Text(allTranslations.text('total') + ':', style: TextStyle(color: HexColor('#B0BEC5'), fontSize: 14),),
                ),
                Expanded(
                  flex: 2,
                  child: Text(total.toStringAsFixed(2) + ' ' + allTranslations.text('usd').toUpperCase(), style: TextStyle(color: HexColor('#FF9933'), fontWeight: FontWeight.bold),),
                )
              ],
            )
          ],
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