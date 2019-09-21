import 'dart:ui';

import 'package:farax/components/hex_color.dart';
import 'package:farax/components/order_detail_item.dart';
import 'package:farax/pages/confirm_pending.dart';
import 'package:farax/pages/fail_reason.dart';
import 'package:farax/pages/item_returned.dart';
import 'package:farax/pages/receipt.dart';
import 'package:flutter/material.dart';
import '../all_translations.dart';
import '../components/gradient_appbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/auth_utils.dart';
import '../utils/network_utils.dart';
import 'congratulation.dart';

class DeliveryCustomer extends StatefulWidget {
  const DeliveryCustomer({
    Key key,
    @required this.order,
    this.isReturned = false,
    this.isPending =false,
  }) : super(key: key);

  final dynamic order;
  final bool isReturned;
  final bool isPending;
  @override
  _DeliveryCustomerState createState() => _DeliveryCustomerState();
}

class _DeliveryCustomerState extends State<DeliveryCustomer> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences _sharedPreferences;
  bool isClickLeftButton = false;
  bool isClickRightButton = false;
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Future _fetch() async {
    _sharedPreferences = await _prefs;
    String authToken = AuthUtils.getToken(_sharedPreferences);
    int currentStatusValue = widget.order['currentStatusValue'];
    if(currentStatusValue == 15) {
      var responseJson = await NetworkUtils.post(authToken, '/api/Orders/${widget.order['id']}/continue-shipping');
      if(responseJson == null) {

        NetworkUtils.showSnackBar(_scaffoldKey, allTranslations.text('something_went_wrong'));

      } else if(responseJson == 'NetworkError') {

        NetworkUtils.showSnackBar(_scaffoldKey, null);

      } else if(responseJson['errors'] != null) {
        NetworkUtils.logoutUser(_scaffoldKey.currentContext, _sharedPreferences);
      } else {
        dynamic newOrder = widget.order;
        newOrder['currentStatusValue'] = responseJson['currentStatusValue'];
        newOrder['lastStatusValue'] = responseJson['lastStatusValue'];
        Navigator.pop(_scaffoldKey.currentContext);
        Navigator.push(_scaffoldKey.currentContext, MaterialPageRoute(
          builder: (context) => new DeliveryCustomer(order: newOrder)
        ));
      }
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await showDialog<String>(
          context: context,
          builder: (BuildContext context) => new DialogConfirmPackageOrder(order: widget.order,
          authToken: authToken, scaffoldKey: _scaffoldKey, 
          sharedPreferences: _sharedPreferences)
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomPadding: false,
        body: Column(
          children: <Widget>[
            GradientAppBar(title: allTranslations.text('delivering'),hasBackIcon: true,backToHome: true),
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Container(
                  color: Color.fromRGBO(242, 242, 242, 1),
                  child: Column(
                    children: <Widget>[
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 57.5),
                        child: Center(
                          child: Column(
                            children: <Widget>[
                              Image.asset('icons/icon.png'),
                              SizedBox(height: 24,),
                              Text(allTranslations.text(widget.isReturned ? 'you_are_return_to_shop' : 'you_are_delivering_to_customer'), style: TextStyle(color: HexColor('#0099CC'), fontSize: 18), textAlign: TextAlign.center,)
                            ],
                          ),
                        ),
                      ),
                      Container(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: <Widget>[
                              OrderDetailItem(order: widget.order, isReturnToWareHouse: false,),
                              SizedBox(height: 25),
                              !widget.isPending? Column(
                                children: <Widget>[
                                  Align(
                                alignment: Alignment.centerLeft,
                                child: Text(allTranslations.text('incase_receiver_does_not_pickup'), style: TextStyle(color: Color.fromRGBO(102, 125, 138, 1)),),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (context) => new ConfirmPending(order: widget.order)
                                  ));
                                },
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(allTranslations.text('click_here'), style: TextStyle(color: Color.fromRGBO(17, 134, 193, 1), decoration: TextDecoration.underline),),
                                ),
                              ),
                                ],
                              ): IgnorePointer(
                                ignoring: true,
                                child: Opacity(opacity: 0.0,),
                              ),
                                                SizedBox(height: 25,),
                            ]
                          )
                      ),
                    ],
                  ),
                )
              ),
            ),
            Container(
              color: Color.fromRGBO(242, 242, 242, 1),
              padding: const EdgeInsets.all(16),
              child: RaisedButton(
                onPressed: _fetch,
                color: Color.fromRGBO(253, 134, 39, 1),
                textColor: Colors.white,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10))
                  ),
                  child: Center(
                    child: Text(allTranslations.text(widget.order['currentStatusValue'] == 11 ? 'return_order' : (widget.order['currentStatusValue'] == 15 ? 'continue_to_delivery' : 'complete_order')).toUpperCase(), style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            )
          ],
        )
      ),
      onWillPop: () {
        Navigator.popAndPushNamed(context, '/main');
      },
    );
  }
}

class DialogConfirmPackageOrder extends StatefulWidget {
  const DialogConfirmPackageOrder({
    Key key,
    @required this.order,
    @required this.authToken,
    @required this.scaffoldKey,
    @required this.sharedPreferences
  }) : super(key: key);

  final dynamic order;
  final String authToken;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final SharedPreferences sharedPreferences;

  @override
  _DialogConfirmPackageOrderState createState() => _DialogConfirmPackageOrderState();
}

class _DialogConfirmPackageOrderState extends State<DialogConfirmPackageOrder> {
  bool _isWaiting = false;

  Future _rejectOrder(BuildContext context) async {
    if(widget.order['currentStatusValue'] == 11) {
      String authToken = AuthUtils.getToken(widget.sharedPreferences);
      setState(() {
        _isWaiting = true;
      });
      var responseJson = await NetworkUtils.post(authToken, '/api/Orders/${widget.order['id']}/lost-package');
      setState(() {
        _isWaiting = false;
      });
      if(responseJson == null) {

        NetworkUtils.showSnackBar(widget.scaffoldKey, allTranslations.text('something_went_wrong'));

      } else if(responseJson == 'NetworkError') {

        NetworkUtils.showSnackBar(widget.scaffoldKey, null);

      } else if(responseJson['errors'] != null) {
        NetworkUtils.logoutUser(widget.scaffoldKey.currentContext, widget.sharedPreferences);
      } else {
        Navigator.of(context).pop();
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => new Congratulation()
        ));
      }
    } else {
      Navigator.of(context).pop();
      Navigator.push(context, MaterialPageRoute(
        builder: (context) => new FailReason(order: widget.order)
      ));
    }
  }

  Future _acceptOrder(BuildContext context) async {
    if(widget.order['currentStatusValue'] == 11) {
      String authToken = AuthUtils.getToken(widget.sharedPreferences);
      setState(() {
        _isWaiting = true;
      });
      var responseJson = await NetworkUtils.post(authToken, '/api/Orders/${widget.order['id']}/returned-to-shop');
      setState(() {
        _isWaiting = false;
      });
      if(responseJson == null) {

        NetworkUtils.showSnackBar(widget.scaffoldKey, allTranslations.text('something_went_wrong'));

      } else if(responseJson == 'NetworkError') {

        NetworkUtils.showSnackBar(widget.scaffoldKey, null);

      } else if(responseJson['errors'] != null) {
        NetworkUtils.logoutUser(widget.scaffoldKey.currentContext, widget.sharedPreferences);
      } else {
        Navigator.of(context).pop();
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => new Congratulation()
        ));
      }
    } else {
      Navigator.of(context).pop();
      Navigator.push(context, MaterialPageRoute(
        builder: (context) => new Receipt(order: widget.order)
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: Stack(
          children: <Widget>[
            AlertDialog(
              title: Row(
                children: <Widget>[
                  Image.asset('icons/Frame.png'),
                  SizedBox(width: 16),
                  Text(allTranslations.text(widget.order['currentStatusValue'] == 11 ? 'return_to_shop' : 'complete_your_order'),
                  style: TextStyle(
                    color: Color.fromRGBO(20, 156, 206, 1),
                    fontWeight: FontWeight.bold,
                    fontSize: 16
                  )),
                ],
              ),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(allTranslations.text(widget.order['currentStatusValue'] == 11 ? 'return_to_shop_text' :'complete_your_order_text'), style: TextStyle(
                      color: Color.fromRGBO(92, 111, 119, 1),
                      fontSize: 13,
                    )),
                    SizedBox(height: 8,),
                  ],
                ),
              ),
              actions: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child:  InkWell(
                              onTap: () {_rejectOrder(context);},
                              child: new Container(
                                width: 146,
                                height: 42,
                                decoration: new BoxDecoration(
                                  color: Colors.white,
                                  border: new Border.all(color: Color.fromRGBO(20, 156, 206, 1), width: 1.0),
                                  borderRadius: new BorderRadius.circular(3.0),
                                ),
                                child: new Center(child: new Text(allTranslations.text('fail').toUpperCase(), style: new TextStyle(fontSize: 14.0, color: Color.fromRGBO(20, 156, 206, 1), fontWeight: FontWeight.bold),),),
                              ),
                            ),
                          ),
                          SizedBox(width: 8,),
                          Expanded(
                            flex: 1,
                            child:  InkWell(
                                onTap: () {_acceptOrder(context);},
                                child: new Container(
                                  width: 146,
                                  height: 42,
                                  decoration: new BoxDecoration(
                                    color: HexColor('#FF9933'),
                                  ),
                                  child: new Center(child: new Text(allTranslations.text('success').toUpperCase(), style: new TextStyle(fontSize: 14.0, color: Colors.white, fontWeight: FontWeight.bold),),),
                                ),
                              ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10,),
                    widget.order['orderPackages']['extraService'] == 'express' || widget.order['currentStatusValue'] == 11 ? IgnorePointer(
                      ignoring: true,
                      child: Opacity(opacity: 0.0,),
                    ) : InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) => new ItemReturned(order: widget.order)
                        ));
                      },
                      child: Container(
                        child: Text(allTranslations.text('some_item_were_returned'), style: TextStyle(color: HexColor('#00C9E8')),),
                      )
                    ),
                    SizedBox(height: 10,)
                  ],
                )
              ],
            ),
            _isWaiting ? BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ) : IgnorePointer(
              ignoring: true,
              child: Opacity(opacity: 0.0,),
            )
          ],
        )
      ),
    );
  }
}