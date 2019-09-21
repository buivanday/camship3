import 'package:farax/blocs/shop_api.dart';
import 'package:farax/pages/shop/create_package_detail.dart';
import 'package:flutter/material.dart';
import '../all_translations.dart';
import 'order_item.dart';
import 'package:date_format/date_format.dart';

class AlmostDoneItem extends StatelessWidget {
  const AlmostDoneItem({
    Key key,
    @required this.order,
  }) : super(key: key);

  final dynamic order;

  replaceTAndZ(String time) => time.replaceAll('T',' ').replaceAll('Z', ' ').substring(0, time.length - 5);

  String convertDateFromString(String strDate){
    DateTime todayDate = DateTime.parse(strDate).toUtc();
    return formatDate(todayDate, [dd, '/', mm, '/', yyyy, ', ', hh, ':', nn]);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> list = new List<Widget>();
    for(var i = 0; i < order['orderPackages']['items'].length; i ++) {
      dynamic orderItems = order['orderPackages']['items'][i];
      orderItems['index'] = i;
      list.add(new ReturnedOrderItem(item: orderItems));
    }
    return InkWell(
      onTap: () {
        ShopOrder o = ShopOrder.fromJson(order);
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => CreatePackageDetail(order: o, isFromShipperHistory: true,)
        ));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            left: BorderSide(
              width: 2,
              color: Color.fromRGBO(253, 134, 39, 1)
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
              padding: const EdgeInsets.all(8),
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
                        Chip(label: Text(allTranslations.text(order['currentStatusValue'] == 7 || order['currentStatusValue'] == 14 ? 'almost_done' : 'money_back'), 
                        style: TextStyle(color: Color.fromRGBO(38, 154, 202, 1))), 
                        backgroundColor: Color.fromRGBO(223, 243, 249, 1),),
                        Text(convertDateFromString(replaceTAndZ(order['updatedOn'])), style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black
                        ))
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: <Widget>[
                      Text(allTranslations.text('order_id'), style: TextStyle(color: Color.fromRGBO(160, 176, 185, 1)),),
                      SizedBox(width: 12),
                      Text(order['orderId'].toUpperCase(), style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black
                      ))
                    ],
                  ),
                  SizedBox(height: 16),
                  new OrderInformation( shopInformation: order['shop'], delivery: order['delivery'],),
                ],
              )
            ),
            order['currentStatusValue'] != 14 ? IgnorePointer(
              ignoring: true,
              child: Opacity(
                opacity: 0.0,
              ),
            ) : order['orderPackages']['extraService'] == 'express' ? 
            SizedBox(height: 25) : ExpansionTile(
              title: Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text(allTranslations.text('items_title'), style: TextStyle(color: Color.fromRGBO(96, 191, 223, 1), fontSize: 14),),),
              children: list,
            ), 
          ],
        ),
      ),
    );
  }
}

class ReturnedOrderItem extends StatelessWidget {
  const ReturnedOrderItem({
    Key key,
    @required this.item,
  }) : super(key: key);

  final dynamic item;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: item['index'] % 2 == 0 ? Color.fromRGBO(248, 248, 248, 1) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(item['name'], style: TextStyle(color: Color.fromRGBO(80, 101, 110, 1)),),
                SizedBox(height: 10,),
                Text(item['price'].toString() + ' ' + allTranslations.text('usd_per_item'), style: TextStyle(color: Color.fromRGBO(146, 165, 174, 1)),)
              ],
            ),
            Text('x' + item['amount'].toString())
          ],
        ),
      ),
    );
  }
}