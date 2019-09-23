import 'dart:convert';

import 'package:farax/pages/delivery_customer.dart';
import 'package:farax/pages/delivery_warehouse.dart';
import 'package:farax/pages/order_detail.dart';
import 'package:farax/utils/auth_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../all_translations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/network_utils.dart';
import 'package:date_format/date_format.dart';

class OrderItem extends StatefulWidget {
  const OrderItem({
    Key key,
    @required this.order,
    this.isGoToDeliveringPage,
  }) : super(key: key);

  final dynamic order;

  final bool isGoToDeliveringPage;

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> with TickerProviderStateMixin {
  final Widget dashline = new SvgPicture.asset(
    'icons/dash-line.svg',
    semanticsLabel: 'Dash Line'
  );

  final int maximumMinutes = 45 * 60;
  double percents = 0;
  bool _isChosen = false;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences _sharedPreferences;
  replaceTAndZ(String time) => time.replaceAll('T',' ').replaceAll('Z', ' ').substring(0, time.length - 5);

  AnimationController animationController;

  String get timerString {
    Duration duration =
        animationController.duration * animationController.value;
        duration.inHours;
    return '${duration.inHours}:${(duration.inMinutes % 60)}:${(duration.inSeconds % 60)
        .toString()
        .padLeft(2, '0')}';
  }

  Future _callPhoneNumber() async {
    final String phoneNumber = widget.isGoToDeliveringPage == true ? widget.order['receiver']['phoneNumber'] : widget.order['shop']['phoneNumber'];
    final String url = 'tel:' + phoneNumber;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future _openMap() async {
    final String latlng = widget.isGoToDeliveringPage == true ? widget.order['receiver']['lat'].toString() + ',' + widget.order['receiver']['lng'].toString() : 
    widget.order['shop']['lat'].toString() + ',' + widget.order['shop']['lng'].toString();
    final String url = "google.navigation:q=" + latlng;
    String appleUrl = "comgooglemaps://?saddr=" + latlng + "&zoom=10";
    if (await canLaunch(url)) {
      await launch(url);
    } else if(await canLaunch(appleUrl)) {
      await launch(appleUrl);
    } else {
      throw 'Could not launch map';
    }
  }

  String convertDateFromString(String strDate){
    DateTime todayDate = DateTime.parse(strDate);
    return formatDate(todayDate, [dd, '/', mm, '/', yyyy, ', ', hh, ':', nn]);
  }

  @override
  void initState() {
    super.initState();
    if(mounted) {
      setState(() {
        _isChosen = widget.order['isChosen'];
      });
    } else {
      _isChosen = widget.order['isChosen'];
    }
    if(widget.isGoToDeliveringPage == true) {
      if(widget.order['timeReceived'] != null) {
        final acceptedTime = DateTime.parse(replaceTAndZ(widget.order['timeReceived'])).add(new Duration(hours: 7));
        final date2 = DateTime.now();
        final difference = date2.difference(acceptedTime).inMinutes;
        final int deliveryTime = widget.order['delivery']['time'] * 60;
        animationController = AnimationController(vsync: this, duration: Duration(minutes: difference < deliveryTime ? (deliveryTime - difference) : difference));
        animationController.addListener(() {
          Duration duration =
              animationController.duration * animationController.value;
          double newPercents = duration.inSeconds / (deliveryTime * 60);
          if(newPercents < 1.0) {
            setState(() {
              percents = duration.inSeconds / (deliveryTime * 60);
            });
          }
        });

        if(difference > deliveryTime) {
          animationController.forward(from: animationController.value);
          // animationController.
        } else {
          animationController.reverse(from: animationController.value == 0.0 ? 1.0 : animationController.value);
        }
      } else {
        animationController = AnimationController(vsync: this, duration: Duration(minutes: widget.order['delivery']['time'] * 60));
        animationController.addListener(() {
          Duration duration =
              animationController.duration * animationController.value;
          setState(() {
            percents = duration.inSeconds / (widget.order['delivery']['time'] * 60 * 60);
          });
        });

        animationController.reverse(from: animationController.value == 0.0 ? 1.0 : animationController.value);
      }
    } else {
      if(widget.order['currentStatusValue'] == 15) {
        if(widget.order['timePending'] != null) {
          final acceptedTime = DateTime.parse(replaceTAndZ(widget.order['timePending'])).add(new Duration(hours: 7));
          final date2 = DateTime.now();
          final difference = date2.difference(acceptedTime).inMinutes;
          final int deliveryTime = 24 * 2 * 60;
          animationController = AnimationController(vsync: this, duration: Duration(minutes: difference < deliveryTime ? (deliveryTime - difference) : difference));
          animationController.addListener(() {
            Duration duration =
                animationController.duration * animationController.value;
            double newPercents = duration.inSeconds / (deliveryTime * 60);
            if(newPercents < 1.0) {
              setState(() {
                percents = duration.inSeconds / (deliveryTime * 60);
              });
            }
          });

          if(difference > deliveryTime) {
            animationController.forward(from: animationController.value);
            // animationController.
          } else {
            animationController.reverse(from: animationController.value == 0.0 ? 1.0 : animationController.value);
          }
        } else {
          animationController = AnimationController(vsync: this, duration: Duration(minutes: 24 * 2 * 60));
          animationController.addListener(() {
            Duration duration =
                animationController.duration * animationController.value;
            setState(() {
              percents = duration.inSeconds / (24 * 2 * 60 * 60);
            });
          });

          animationController.reverse(from: animationController.value == 0.0 ? 1.0 : animationController.value);
        }
      } else {
        if(widget.order['timeShipperAccepted'] != null) {
          final acceptedTime = DateTime.parse(replaceTAndZ(widget.order['timeShipperAccepted'])).add(new Duration(hours: 7));
          final date2 = DateTime.now();
          final difference = date2.difference(acceptedTime).inMinutes;
          animationController = AnimationController(vsync: this, duration: Duration(minutes: difference < 45.0 ? (45 - difference) : difference));
          animationController.addListener(() {
            Duration duration =
                animationController.duration * animationController.value;
            double newPercents = duration.inSeconds / maximumMinutes;
            if(newPercents < 1.0) {
              setState(() {
                percents = duration.inSeconds / maximumMinutes;
              });
            }
          });

          if(difference > 45.0) {
            animationController.forward(from: 20.0);
            // animationController.
          } else {
            animationController.reverse(from: animationController.value == 0.0 ? 1.0 : animationController.value);
          }
        } else {
          animationController = AnimationController(vsync: this, duration: Duration(minutes: 45));
          animationController.addListener(() {
            Duration duration =
                animationController.duration * animationController.value;
            setState(() {
              percents = duration.inSeconds / maximumMinutes;
            });
          });

          animationController.reverse(from: animationController.value == 0.0 ? 1.0 : animationController.value);
        }
      }
    }
    
  }

  Future _choose() async {
    
    _sharedPreferences = await _prefs;
    String authToken = AuthUtils.getToken(_sharedPreferences);
    var response = await NetworkUtils.post(authToken, '/api/Orders/${widget.order['id']}/delivering/choose');
    if(response != null) {
      print(response);
      setState(() {
        _isChosen = !_isChosen;
      });
    }
  }

  @override
  void dispose() {
    animationController.stop();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(
            width: 2,
            color: Color.fromRGBO(20, 156, 206, 1)
          )
        ),
        boxShadow: [
          new BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.4),
            blurRadius: 5,
            spreadRadius: 1
          )
        ],
      ),
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(left: 8, top: 8, right: 8),
            child: Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color.fromRGBO(231, 235, 238, 1))
                    )
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(children: <Widget>[
                        Text(allTranslations.text('order_id')),
                        SizedBox(width: 12),
                        Text(widget.order['orderId'] != null ? widget.order['orderId'].toUpperCase() : 'CAMSHIP', style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black
                        ))
                      ],),
                      Row(
                        children: <Widget>[
                          InkWell(
                            onTap: _choose,
                            child: Icon(Icons.star, color: _isChosen ? Colors.red : Colors.black,),
                          ),
                          SizedBox(width: 8.0),
                          InkWell(
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(245, 245, 245, 1),
                                borderRadius: BorderRadius.all(Radius.circular(4.0))
                              ),
                              child: Text(widget.order['currentStatusValue'] == 11 ? allTranslations.text('return') : widget.order['delivery']['time'].toString() + 'h', style: TextStyle(color: Color.fromRGBO(97, 184, 101, 1)),),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(height: 25),
                new OrderInformation(shopInformation: widget.order['shop'], delivery: widget.order['delivery'], currentStatusValue: widget.order['currentStatusValue'],
                isGoToDeliveringPage: widget.isGoToDeliveringPage, receiverInformation: widget.isGoToDeliveringPage == true ? widget.order['receiver'] : null),
                widget.order['currentStatusValue'] != 11 ? SizedBox(height: 25) : Opacity(opacity: 0.0,),
                widget.order['currentStatusValue'] != 11 ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(allTranslations.text('time_left'), style: TextStyle(
                      color: Color.fromRGBO(177, 190, 197, 1)
                    )),
                    AnimatedBuilder(
                      animation: animationController,
                      builder: (_, Widget child) {
                        return Text(
                          timerString,
                          style: TextStyle(
                            color: widget.order['currentStatusValue'] == 15 ? Color.fromRGBO(177, 190, 197, 1) : Color.fromRGBO(63, 164, 63, 1),
                            fontWeight: FontWeight.bold
                          ),
                        );
                      }
                    )
                  ],
                ) : Opacity(opacity: 0.0,),
                widget.order['currentStatusValue'] != 11 ? Row(
                  children: <Widget>[
                    LinearPercentIndicator(
                      width: MediaQuery.of(context).size.width - 50,
                      lineHeight: 6.0,
                      percent: percents,
                      progressColor: widget.order['currentStatusValue'] == 15 ? Color.fromRGBO(177, 190, 197, 1) : Color.fromRGBO(63, 164, 63, 1),
                    )
                  ],
                ) : Opacity(opacity: 0.0,)
              ],
            )
          ),
          SizedBox(height: 25),
          Row(
            children: <Widget>[
              Expanded(
                flex: 2,
                child: RaisedButton(
                  color: Color.fromRGBO(223, 249, 253, 1),
                  textColor: Color.fromRGBO(74, 212, 234, 1),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => widget.isGoToDeliveringPage == false ? (
                        widget.order['currentStatusValue'] == 15 ? (widget.order['lastStatusValue'] == 6 ? DeliveryCustomer(order: widget.order,isPending: true,) : 
                        (widget.order['lastStatusValue'] == 5 ? DeliveryWarehouse(order: widget.order) : OrderDetail(order: widget.order,isPending: true,))) : OrderDetail(order: widget.order,isPending: false,)
                      ) : 
                      widget.order['currentStatusValue'] == 11 || (widget.order['currentStatusValue'] == 15 && widget.order['lastStatusValue'] == 11) ? DeliveryCustomer(order: widget.order, isReturned: true,) : (widget.order['delivery']['time'] < 24 ? DeliveryCustomer(order: widget.order) : widget.order['currentStatusValue'] == 6 ? DeliveryCustomer(order: widget.order,) : DeliveryWarehouse(order: widget.order))
                    ));
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Text(allTranslations.text('view_detail'), textAlign: TextAlign.center,),
                  )
                ),
              ),
              Expanded(
                flex: 1,
                child: RaisedButton(
                  color: Color.fromRGBO(223, 249, 253, 1),
                  textColor: Color.fromRGBO(74, 212, 234, 1),
                  onPressed: _callPhoneNumber,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.call, size: 16,),
                        SizedBox(width: 3,),
                        Text(allTranslations.text('call'), textAlign: TextAlign.center)
                      ]
                    ) 
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: RaisedButton(
                  color: Color.fromRGBO(223, 249, 253, 1),
                  textColor: Color.fromRGBO(74, 212, 234, 1),
                  onPressed: _openMap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.map, size: 16,),
                        SizedBox(width: 1,),
                        Text(allTranslations.text('map'), textAlign: TextAlign.center)
                      ]
                    ),
                  )
                ),
              )
            ], 
          )
        ],
      ),
    );
  }
}

class DialogConfirmOrder extends StatelessWidget {
  const DialogConfirmOrder({
    Key key,
    @required this.order,
    this.length,
    @required this.authToken,
    @required this.scaffoldKey,
    @required this.sharedPreferences
  }) : super(key: key);

  final dynamic order;
  final int length;
  final String authToken;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final SharedPreferences sharedPreferences;

  Future _rejectOrder(BuildContext context) async {
    var responseJson = await NetworkUtils.post(authToken, '/api/Orders/${order['id']}/reject');
     if(responseJson == null) {

        NetworkUtils.showSnackBar(scaffoldKey, allTranslations.text('something_went_wrong'));

      } else if(responseJson == 'NetworkError') {

        NetworkUtils.showSnackBar(scaffoldKey, null);

      } else if(responseJson['errors'] != null) {
        _logout();
      }

      Navigator.of(context).popAndPushNamed('/main');
  }

  Future _acceptOrder(BuildContext context) async {
    var responseJson = await NetworkUtils.post(authToken, '/api/Orders/${order['id']}/accept');
     if(responseJson == null) {

        NetworkUtils.showSnackBar(scaffoldKey, allTranslations.text('something_went_wrong'));

      } else if(responseJson == 'NetworkError') {

        NetworkUtils.showSnackBar(scaffoldKey, null);

      } else if(responseJson['errors'] != null) {
        _logout();
      }

      Navigator.of(context).popAndPushNamed('/main');
  }

  _logout() {
		NetworkUtils.logoutUser(scaffoldKey.currentContext, sharedPreferences);
	}

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        child: AlertDialog(
          title: Row(
            children: <Widget>[
              Image.asset('icons/Frame.png'),
              SizedBox(width: 16),
              Text(allTranslations.text('you_have') + ' ' + length.toString() + ' ' + allTranslations.text('order') + ' !',
              style: TextStyle(
                color: Color.fromRGBO(20, 156, 206, 1),
                fontWeight: FontWeight.bold,
                fontSize: 18
              )),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(allTranslations.text('you_have_a_order_at'), style: TextStyle(
                  color: Color.fromRGBO(92, 111, 119, 1),
                  fontSize: 13,
                )),
                SizedBox(height: 8,),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Text(allTranslations.text('shop_title') + ':', style: TextStyle(color: Color.fromRGBO(196, 206, 211, 1), fontSize: 14),),
                    ),
                    Flexible(
                      flex: 3,
                      fit: FlexFit.loose,
                      child: Text(order['shop']['fullName'], style: TextStyle(color: Color.fromRGBO(92, 111, 119, 1), fontSize: 14), textAlign: TextAlign.left)
                    )
                  ],
                ),
                SizedBox(height: 8,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Text(allTranslations.text('address') + ':', style: TextStyle(color: Color.fromRGBO(196, 206, 211, 1), fontSize: 14), textAlign: TextAlign.left,),
                    ),
                    Flexible(
                      flex: 3,
                      fit: FlexFit.loose,
                      child: Text(order['shop']['address'], style: TextStyle(color: Color.fromRGBO(92, 111, 119, 1), fontSize: 14), textAlign: TextAlign.left),
                    )
                  ],
                )
              ],
            ),
          ),
          actions: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.75,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child:  InkWell(
                      onTap: () {_rejectOrder(context);},
                      child: new Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: new BoxDecoration(
                          color: Colors.white,
                          border: new Border.all(color: Color.fromRGBO(20, 156, 206, 1), width: 1.0),
                          borderRadius: new BorderRadius.circular(3.0),
                        ),
                        child: new Center(child: new Text(allTranslations.text('reject').toUpperCase(), style: new TextStyle(fontSize: 14.0, color: Color.fromRGBO(20, 156, 206, 1), fontWeight: FontWeight.bold),),),
                      ),
                    ),
                  ),
                  SizedBox(width: 8,),
                  Expanded(
                    flex: 1,
                    child:  RaisedButton(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(allTranslations.text('accept').toUpperCase()),
                      color: Color.fromRGBO(253, 134, 39, 1),
                      textColor: Colors.white,
                      onPressed: () {
                        _acceptOrder(context);
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class  OrderInformation extends StatelessWidget {
  const OrderInformation({
    Key key,
    @required this.shopInformation,
    this.delivery,
    this.isGoToDeliveringPage,
    this.receiverInformation,
    this.currentStatusValue
  }) : super(key: key);

  final dynamic shopInformation;
  final dynamic delivery;
  final bool isGoToDeliveringPage;
  final dynamic receiverInformation;
  final int currentStatusValue;

  @override
  Widget build(BuildContext context) {
    Widget title;
    String fullName;
    String address;
    String phoneNumber;
    if(delivery['time'] == 24) {
      if(currentStatusValue == 3 || currentStatusValue == 11) {
        title = Text(allTranslations.text('shop_address'));
        fullName = shopInformation['fullName'];
        address = shopInformation['address'];
        phoneNumber = shopInformation['phoneNumber'];
      } else if(currentStatusValue == 6) {
        title = Text(allTranslations.text('customer_address'));
        fullName = receiverInformation['fullName'];
        address = receiverInformation['address'];
        phoneNumber = receiverInformation['phoneNumber'];
      } else {
        title = Text(allTranslations.text('warehouse_address'));
        fullName = 'FARAX (CAMBODIA) Co.,Ltd';
        address = 'St 157 #2AB Phnom Penh, 12312, Cambodia';
        phoneNumber = '+855 23 695 9999';
      }
    } else {
      if(isGoToDeliveringPage == true && currentStatusValue != 11) {
        title = Text(allTranslations.text('customer_address'));
        fullName = receiverInformation['fullName'];
        address = receiverInformation['address'];
        phoneNumber = receiverInformation['phoneNumber'];
      } else {
        title = Text(allTranslations.text('shop_address'));
        fullName = shopInformation['fullName'];
        address = shopInformation['address'];
        phoneNumber = shopInformation['phoneNumber'];
      }
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Image.asset('icons/order-direction-line.png'),
        ),
        SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(allTranslations.text('your_location')),
            SizedBox(height: 12),
            title,
            SizedBox(height: 13),
            Text(fullName, style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black
            )),
            SizedBox(height: 13),
           SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            child: Text(address, overflow: TextOverflow.fade)
            ),
            SizedBox(height: 13),
            Text(phoneNumber)
          ],
        )
      ],
    );
  }
}