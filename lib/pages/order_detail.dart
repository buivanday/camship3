import 'package:farax/components/order_detail_item.dart';
import 'package:farax/pages/confirm_pending.dart';
import 'package:farax/pages/package_information.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../all_translations.dart';
import '../components/gradient_appbar.dart';
import 'package:date_format/date_format.dart';

class OrderDetail extends StatefulWidget {
  const OrderDetail({
    Key key,
    @required this.order,
    this.isPending = false,

  }) : super(key: key);

  final dynamic order;
  final bool isPending ;

  @override
  _OrderDetailState createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetail> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  replaceTAndZ(String time) => time.replaceAll('T',' ').replaceAll('Z', ' ').substring(0, time.length - 5);

  String convertDateFromString(String strDate){
    DateTime todayDate = DateTime.parse(strDate);
    return formatDate(todayDate, [dd, '/', mm, '/', yyyy, ', ', hh, ':', nn]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomPadding: false,
      body: Column(
        children: <Widget>[
          GradientAppBar(title: widget.order['shop']['fullName'],hasBackIcon: true),
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: <Widget>[
                  Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                          children: <Widget>[
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  new BoxShadow(
                                      color: Color.fromRGBO(0, 0, 0, 0.4),
                                      blurRadius: 5,
                                      spreadRadius: 1
                                  )
                                ],
                                borderRadius: BorderRadius.all(Radius.circular(5)),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 1,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(allTranslations.text('time_admin_assign'), style: TextStyle(color: Color.fromRGBO(160, 176, 185, 1)),),
                                          Text(convertDateFromString(replaceTAndZ(widget.order['timeAdminAssigned'])), style: TextStyle(color: Color.fromRGBO(54, 72, 81, 1), fontWeight: FontWeight.bold),)
                                        ],
                                      ),
                                    ),

                                    Expanded(
                                      flex: 1,
                                      child: Column(
                                        children: <Widget>[
                                          Text(allTranslations.text('time_shop_book'), style: TextStyle(color: Color.fromRGBO(160, 176, 185, 1)),),
                                          Text(convertDateFromString(replaceTAndZ(widget.order['timeShopBook'])), style: TextStyle(color: Color.fromRGBO(54, 72, 81, 1), fontWeight: FontWeight.bold),)
                                        ],
                                      ),
                                    )
                                  ]
                              ),
                            ),
                            SizedBox(height: 25),
                            OrderDetailItem(order: widget.order, isReturnToWareHouse: false,),
                            SizedBox(height: 25),
                            Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    new BoxShadow(
                                        color: Color.fromRGBO(0, 0, 0, 0.4),
                                        blurRadius: 5,
                                        spreadRadius: 1
                                    )
                                  ],
                                  borderRadius: BorderRadius.all(Radius.circular(5)),
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                    children: <Widget>[
                                      Container(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        decoration: BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(
                                                width: 1,
                                              )
                                          ),
                                        ),
                                        child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Text(allTranslations.text('delivery_to'), style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold))
                                            ]
                                        ),
                                      ),
                                      SizedBox(height: 8,),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Expanded(
                                            flex: 1,
                                            child: Text(allTranslations.text('name') + ':', style: TextStyle(color: Color.fromRGBO(196, 206, 211, 1), fontSize: 14),),
                                          ),
                                          Flexible(
                                              flex: 3,
                                              fit: FlexFit.loose,
                                              child: Text(widget.order['shop']['fullName'], style: TextStyle(color: Color.fromRGBO(92, 111, 119, 1), fontSize: 14), textAlign: TextAlign.left)
                                          )
                                        ],
                                      ),
                                      SizedBox(height: 8,),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Expanded(
                                            flex: 1,
                                            child: Text(allTranslations.text('address') + ':', style: TextStyle(color: Color.fromRGBO(196, 206, 211, 1), fontSize: 14),),
                                          ),
                                          Flexible(
                                              flex: 3,
                                              fit: FlexFit.loose,
                                              child: Text(widget.order['shop']['address'], style: TextStyle(color: Color.fromRGBO(92, 111, 119, 1), fontSize: 14), textAlign: TextAlign.left)
                                          )
                                        ],
                                      ),
                                      SizedBox(height: 8,),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Expanded(
                                            flex: 1,
                                            child: Text(allTranslations.text('phone') + ':', style: TextStyle(color: Color.fromRGBO(196, 206, 211, 1), fontSize: 14),),
                                          ),
                                          Flexible(
                                              flex: 3,
                                              fit: FlexFit.loose,
                                              child: Text(widget.order['shop']['phoneNumber'], style: TextStyle(color: Color.fromRGBO(92, 111, 119, 1), fontSize: 14), textAlign: TextAlign.left)
                                          )
                                        ],
                                      ),

                                    ]
                                )
                            ),
                            SizedBox(height: 25),
                            !widget.isPending? Column(
                              children: <Widget>[
                                Align(
                              alignment: Alignment.centerLeft,
                              child: Text(allTranslations.text('incase_does_not_pickup'), style: TextStyle(color: Color.fromRGBO(102, 125, 138, 1)),),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => new ConfirmPending(order: widget.order,)
                                ));
                              },
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(allTranslations.text('click_here'), style: TextStyle(color: Color.fromRGBO(17, 134, 193, 1), decoration: TextDecoration.underline),),
                              ),
                            ),
                              ],
                            ): Container(),
                            SizedBox(height: 25,),
                          ]
                      )
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: RaisedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => PackageInformation(order: widget.order)
                ));
              },
              color: Color.fromRGBO(253, 134, 39, 1),
              textColor: Colors.white,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10))
                ),
                child: Center(
                  child: Text(allTranslations.text('check_your_package_information').toUpperCase(), style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                ),
              ),
            )
          ),
        ],
      )
    );
  }
}