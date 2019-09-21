import 'package:farax/components/almost_done_item.dart';
import 'package:farax/components/order_item.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../all_translations.dart';

class OrderDetailItem extends StatelessWidget  {
  const OrderDetailItem({
    Key key,
    @required this.order,
    this.isReturnToWareHouse
  }) : super(key: key);

  final dynamic order;

  final bool isReturnToWareHouse;

  Future _callPhoneNumber() async {
    String phoneNumber = isReturnToWareHouse == true ? '+855 23 695 9999' : order['receiver']['phoneNumber'];
    final String url = 'tel:' + phoneNumber;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future _openMap() async {
    String latlng = isReturnToWareHouse == true ? '11.5548039,104.9145685' : order['receiver']['lat'].toString() + ',' + order['receiver']['lng'].toString(); 
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

  @override
  Widget build(BuildContext context) {
    List<Widget> list = new List<Widget>();
    for(var i = 0; i < order['orderPackages']['items'].length; i ++) {
      dynamic orderItems = order['orderPackages']['items'][i];
      orderItems['index'] = i;
      list.add(new ReturnedOrderItem(item: orderItems));
    }
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
                        Row(
                          children: <Widget>[
                            Text(allTranslations.text('order_id')),
                            SizedBox(width: 12),
                            Text(order['orderId'].toUpperCase(), style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black
                            )),
                          ],
                        ),
                        InkWell(
                          onTap: () {},
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(245, 245, 245, 1),
                              borderRadius: BorderRadius.all(Radius.circular(4.0))
                            ),
                            child: Text(order['currentStatusValue'] == 11 ? allTranslations.text('return') : order['delivery']['time'].toString() + 'h', style: TextStyle(color: Color.fromRGBO(97, 184, 101, 1)),),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 25),
                  new OrderInformation(shopInformation: order['shop'], delivery: order['delivery'], 
                  isGoToDeliveringPage: true, receiverInformation: order['receiver'], currentStatusValue: order['currentStatusValue']),
                ],
              )
          ),
          order['orderPackages']['extraService'] == 'express' ? 
          SizedBox(height: 25) : ExpansionTile(
            title: Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text(allTranslations.text('items_title'), style: TextStyle(color: Color.fromRGBO(96, 191, 223, 1), fontSize: 14),),),
            children: list,
          ), 
          Row(
            children: <Widget>[
              isReturnToWareHouse == false ? Expanded(
                flex: 1,
                child: RaisedButton(
                  color: Color.fromRGBO(223, 249, 253, 1),
                  textColor: Color.fromRGBO(74, 212, 234, 1),
                  onPressed: _callPhoneNumber,
                  child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.call, size: 16,),
                            SizedBox(width: 3,),
                            Text(allTranslations.text('call'), textAlign: TextAlign.center)
                          ]
                      )
                  ),
                ),
              ) : IgnorePointer(
                ignoring: true,
                child: Opacity(
                  opacity: 0.0
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.map, size: 16,),
                            SizedBox(width: 3,),
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