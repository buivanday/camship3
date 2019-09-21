import 'package:farax/blocs/billing_history_api.dart';
import 'package:farax/blocs/billing_history_bloc.dart';
import 'package:farax/blocs/search_state.dart';
import 'package:farax/blocs/shop_api.dart';
import 'package:farax/components/gradient_appbar.dart';
import 'package:farax/components/hex_color.dart';
import 'package:farax/components/search_loading_widget.dart';
import 'package:farax/pages/shop/show_modal_bottom_sheet.dart';
import 'package:farax/utils/auth_utils.dart';
import 'package:farax/utils/network_utils.dart';
import 'package:flutter/material.dart';
import './calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../all_translations.dart';
import 'create_package_detail.dart';

class BillingHistory extends StatefulWidget {
  final BillingHistoryApi api;
  BillingHistory({Key key, BillingHistoryApi api})
      : this.api = api ?? BillingHistoryApi(),
        super(key: key);
  @override
  _BillingHistoryState createState() => _BillingHistoryState();
}

class _BillingHistoryState extends State<BillingHistory> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
	Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences _sharedPreferences;
  bool _hasBilling = false;
  BillingHistoryBloc _billingHistoryBloc;
  String dateRange = '';
  int _position = new DateTime.now().weekday;
  List<bool> hasOrders = [];

  @override
	void initState() {
		super.initState();
		_fetchSessionAndNavigate();

    _billingHistoryBloc = BillingHistoryBloc(widget.api);
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

  _onSelectedRangeChange(range) {
    dateRange = "${range.item1}_${range.item2}_";
    _billingHistoryBloc.onDateChanged.add(dateRange);
  }

  _onSelectedDate(date) {
    print("${date.toString()}");
  }

  _onDaySelected(position) {
    if(mounted) {
      setState(() {
        _position = position;
      });
    } else {
      _position = position;
    }
  }

  @override
  void dispose() {
    _billingHistoryBloc.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        child: Column(
          children: <Widget>[
            GradientAppBar(title: allTranslations.text('billing_history'), hasBackIcon:true),
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.only(top: 20.0, left: 16.0, right: 16.0),
                width: double.infinity,
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: StreamBuilder(
                      stream: _billingHistoryBloc.state,
                        initialData: SearchAll(),
                        builder: (BuildContext context, AsyncSnapshot<SearchState> snapshot) {
                          final state = snapshot.data;
                          if(state is SearchAll) {
                            _billingHistoryBloc.onDateChanged.add(dateRange);
                          }
                          if(state is SearchBillingPopulated) {
                            hasOrders = state.result.items.map((BillingHistoryModel _billing) {
                              return _billing.orders.isNotEmpty;
                            }).toList();

                          }
                          return Column(
                            children: <Widget>[
                              Calendar(showCalendarPickerIcon: true, onSelectedRangeChange: _onSelectedRangeChange, onDateSelected: _onSelectedDate, onDaySelected: _onDaySelected, hasOrders: hasOrders),
                              Expanded(
                                flex: 1,
                                child: Stack(
                                  children: <Widget>[
                                    LoadingWidget(visible: state is SearchLoading),
                                    EmptyBillingHistoryWidget(visible: state is SearchEmpty),
                                    BillingHistoryWidget(
                                      items: state is SearchBillingPopulated ? state.result.items : [],
                                      position: _position
                                    ),
                                  ],
                                ),
                              )
                            ],
                          );
                        }
                      )
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyBillingHistoryWidget extends StatelessWidget {
  final bool visible;

  const EmptyBillingHistoryWidget({Key key, this.visible}) : super(key: key);

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
            Image.asset('icons/no-billing.png'),
            SizedBox(height: 16),
            Text(allTranslations.text('no_billing_quotes'), style: TextStyle(color: HexColor('#78909C'), ),)
          ]
        ),
      ),
    );
  }
}

class BillingHistoryWidget extends StatefulWidget {
  final bool visible;
  final List<BillingHistoryModel> items;
  final int position;

  BillingHistoryWidget({Key key, @required this.items, bool visible, this.position}) 
      : this.visible = visible ?? items.isNotEmpty,
        super(key: key);

  @override
  _BillingHistoryWidgetState createState() => _BillingHistoryWidgetState();
}

class _BillingHistoryWidgetState extends State<BillingHistoryWidget> {
  
  @override
  Widget build(BuildContext context) {
    int _position = widget.position;
    if(widget.position == 7) {
      _position = 0;
    } 
    return widget.items.isNotEmpty && widget.items[_position].orders.isNotEmpty ? SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: <Widget>[
          SizedBox(height: 23.0,),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: HexColor('#FF9933'),
              ),
              borderRadius: BorderRadius.all(Radius.circular(4.0))
            ),
            child: Column(
              children: <Widget>[
                new BillingHistoryReportGeneralItem(title: 'order_completed', value: widget.items[_position].totalCompleted, hasUSD: false),
                SizedBox(height: 10.0,),
                new BillingHistoryReportGeneralItem(title: 'order_failed', value: widget.items[_position].totalFailed, hasUSD: false),
                SizedBox(height: 10.0,),
                new BillingHistoryReportGeneralItem(title: 'total_cod', value: widget.items[_position].totalCOD,),
                SizedBox(height: 10.0,),
                new BillingHistoryReportGeneralItem(title: 'total_shipping_fee', value: widget.items[_position].totalShippingFee,),
              ],
            ),
          ),
          ListBillingHistoryOrders(orders: widget.items[_position].orders)
        ],
      ),
    ) : EmptyBillingHistoryWidget(visible: true,);
  }
}

class ListBillingHistoryOrders extends StatefulWidget {
  const ListBillingHistoryOrders({
    Key key,
    this.orders,
  }) : super(key: key);

  final List<ShopOrder> orders;
  @override
  _ListBillingHistoryOrdersState createState() => _ListBillingHistoryOrdersState();
}

class _ListBillingHistoryOrdersState extends State<ListBillingHistoryOrders> {
  @override
  Widget build(BuildContext context) {
    List<Widget> list = new List<Widget>();
    for(var i = 0; i < widget.orders.length; i ++) {
      ShopOrder order = widget.orders[i];
      list.add(new BillingHistoryOrder(order: order));
    }
    return Column(
      children: list,
    );
  }
}

class BillingHistoryOrder extends StatefulWidget {
  const BillingHistoryOrder({
    Key key,
    this.order,
  }) : super(key: key);

  final ShopOrder order;

  @override
  _BillingHistoryOrderState createState() => _BillingHistoryOrderState();
}

class _BillingHistoryOrderState extends State<BillingHistoryOrder> {
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

  @override
  Widget build(BuildContext context) {
    double total = 0;
    String extraService = widget.order.orderPackages['extraService'];
    bool isShopPaid = widget.order.orderPackages['isShopPaid'];
    dynamic valueOfOrder = widget.order.valueOfOrder;
    dynamic shippingCost = widget.order.shippingCost;
    dynamic totalCOD = widget.order.totalCOD;
    if(extraService == 'cod') {
      if(isShopPaid) {
        total += shippingCost + valueOfOrder + totalCOD;
      } else {
        total += valueOfOrder + shippingCost;
      }
    } else {
      total += shippingCost;
    }
    return Column(
      children: <Widget>[
        InkWell(
          onTap: (){
            showModalBottomSheetApp<void>(context: context,
              builder: (BuildContext context) {
                return Container(
                  child: CreatePackageDetail(hasNavbar: false, order: widget.order,isFromShipperHistory: true),
                );
              },
              
            );
          },
          child: Container(
          child: Column(
            children: <Widget>[
              SizedBox(height: 20.0,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(allTranslations.text('order_id'), style: TextStyle(color: HexColor('#78909C')),),
                      SizedBox(width:10.0,),
                      Text(widget.order.orderId, style: TextStyle(color: HexColor('#0099CC'), fontSize: 14.0, height: 16.0/14.0, fontWeight: FontWeight.bold),)
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
              ),
              SizedBox(height: 16.0,),
              Image.asset('icons/Line.png', width: double.infinity, fit: BoxFit.fitWidth,),
              SizedBox(height: 16.0,),
              new BillingHistoryOrderDetailItem(title: 'to', 
                subtitle: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(widget.order.receiver['fullName'], style: TextStyle(color: HexColor('#263238'), fontWeight: FontWeight.bold, fontSize: 14.0, height: 16.0/14.0),),
                    SizedBox(height: 4.0,),
                    Text(widget.order.receiver['address'], )
                  ],
                ),
              ),
              SizedBox(height: 10.0,),
              new BillingHistoryOrderDetailItem(title: 'pick_up', 
                subtitle: Text(widget.order != null && widget.order.timeReceived != null ? widget.order.timeReceived : '', style: TextStyle(color: HexColor('#455A64')),),
              ),
              SizedBox(height: 10.0,),
              new BillingHistoryOrderDetailItem(title: 'total', 
                subtitle: Text(total.toStringAsFixed(2) + ' ' + allTranslations.text('usd').toUpperCase(), style: TextStyle(color: HexColor('#263238'), fontWeight: FontWeight.bold, fontSize: 14.0, height: 16.0/14.0),),
              ),
            ],
          ),
        ),
        ),
        SizedBox(height: 20.0,),
        Container(
          width: double.infinity,
          height: 10.0,
          color: HexColor('#F5F5F5'),
        )
      ],
    );
  }
}

class BillingHistoryReportGeneralItem extends StatelessWidget {
  const BillingHistoryReportGeneralItem({
    Key key,
    this.title,
    this.value,
    this.hasUSD = true
  }) : super(key: key);

  final String title;
  final double value;
  final bool hasUSD;

  @override
  Widget build(BuildContext context) {
    dynamic total;
    if(!hasUSD) {
      total = value.toInt();
    } else {
      total = value;
    }
    return Row(
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Text(allTranslations.text(title), style: TextStyle(color: HexColor('#B0BEC5'), fontSize: 14.0),),
        ),
        Expanded(
          flex: 3,
          child: Text(total.toString() + ' ' + (hasUSD ? allTranslations.text('usd').toUpperCase() : ''), style: TextStyle(color: HexColor('#455A64'), fontSize: 14.0),),
        )
      ],
    );
  }
}

class BillingHistoryOrderDetailItem extends StatelessWidget {
  const BillingHistoryOrderDetailItem({
    Key key,
    this.title,
    this.subtitle,
    this.hasUSD = true
  }) : super(key: key);

  final String title;
  final Widget subtitle;
  final bool hasUSD;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Text(allTranslations.text(title), style: TextStyle(color: HexColor('#B0BEC5'), fontSize: 14.0),),
        ),
        Expanded(
          flex: 3,
          child: subtitle
        )
      ],
    );
  }
}