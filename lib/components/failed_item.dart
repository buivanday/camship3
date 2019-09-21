import 'package:farax/blocs/shop_api.dart';
import 'package:farax/components/hex_color.dart';
import 'package:farax/pages/shop/create_package_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../all_translations.dart';
import 'order_item.dart';
import 'package:date_format/date_format.dart';

class FailedItem extends StatelessWidget {
  const FailedItem({
    Key key,
    @required this.order,
  }) : super(key: key);

  final dynamic order;

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

    return STATUSES[order['currentStatusValue'] - 1]['name'];
  }

  @override
  Widget build(BuildContext context) {
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
                        Chip(label: Text(_getStatusName(), 
                        style: TextStyle(color: HexColor('#FF3333'))), 
                        backgroundColor: Color.fromRGBO(255, 229, 230, 1),),
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
                  new OrderInformation(shopInformation: order['shop'], delivery: order['delivery'],),
                ],
              )
            )]
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
                Text(item['title'], style: TextStyle(color: Color.fromRGBO(80, 101, 110, 1)),),
                SizedBox(height: 10,),
                Text(item['subTitle'], style: TextStyle(color: Color.fromRGBO(146, 165, 174, 1)),)
              ],
            ),
            Text('x' + item['quantity'].toString())
          ],
        ),
      ),
    );
  }
}