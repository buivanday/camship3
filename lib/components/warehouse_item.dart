import 'package:farax/pages/delivery_warehouse.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../all_translations.dart';
import 'order_item.dart';

class WareHouseItem extends StatefulWidget {
  const WareHouseItem({
    Key key,
    @required this.order,
  }) : super(key: key);

  final dynamic order;

  @override
  _WareHouseItemState createState() => _WareHouseItemState();
}

class _WareHouseItemState extends State<WareHouseItem> {
  final Widget dashline = new SvgPicture.asset(
    'icons/dash-line.svg',
    semanticsLabel: 'Dash Line'
  );

  Future _callPhoneNumber() async {
    final String url = 'tel:+855 23 695 9999';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future _openMap() async {
    final String url = "google.navigation:q=" + '11.5548039,104.9145685';
    String appleUrl = "comgooglemaps://?saddr=" + '11.5548039,104.9145685' + "&zoom=10";
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
    return Container(
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
            padding: const EdgeInsets.only(left: 8, top: 8, right: 8),
            child: Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color.fromRGBO(231, 235, 238, 1))
                    )
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text(allTranslations.text('order_id'), style: TextStyle(color: Color.fromRGBO(160, 176, 185, 1)),),
                          SizedBox(width: 12),
                          Text(widget.order['orderId'].toUpperCase(), style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black
                          ))
                        ],
                      ),
                      // InkWell(
                      //   onTap: () {},
                      //   child: Container(
                      //     padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                      //     decoration: BoxDecoration(
                      //       color: Color.fromRGBO(245, 245, 245, 1),
                      //       borderRadius: BorderRadius.all(Radius.circular(4.0))
                      //     ),
                      //     child: Text(allTranslations.text('return'), style: TextStyle(color: Color.fromRGBO(97, 184, 101, 1)),),
                      //   ),
                      // )
                    ],
                  ),
                ),
                SizedBox(height: 16),
                new OrderWarehouseItem(),
              ],
            )
          ),
          SizedBox(height: 25),
          Row(
            children: <Widget>[
              Expanded(
                flex: 2,
                child: RaisedButton(
                  color: Color.fromRGBO(255, 245, 235, 1),
                  textColor: Color.fromRGBO(255, 153, 51, 1),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => DeliveryWarehouse(order: widget.order),
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
                  color: Color.fromRGBO(255, 245, 235, 1),
                  textColor: Color.fromRGBO(255, 153, 51, 1),
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
                  color: Color.fromRGBO(255, 245, 235, 1),
                  textColor: Color.fromRGBO(255, 153, 51, 1),
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

class OrderWarehouseItem extends StatelessWidget {
  const OrderWarehouseItem({
    Key key,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Image.asset('icons/order-direction-line-orange.png'),
        ),
        SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(allTranslations.text('your_location')),
            SizedBox(height: 12),
            Text(allTranslations.text('shop_address')),
            SizedBox(height: 13),
            Text('FARAX (CAMBODIA) Co.,Ltd', style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black
            )),
            SizedBox(height: 13),
            Container(
              child: Column(
                children: <Widget>[
                  Flexible(
                    child:
                  Text('St 157 #2AB Phnom Penh, 12312, Cambodia', textAlign: TextAlign.left,),
                  )
                ],
              )
            ),
            SizedBox(height: 13),
            Text('(+855) 23 695 9999')
          ],
        )
      ],
    );
  }
}