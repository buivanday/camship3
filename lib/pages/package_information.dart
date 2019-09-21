import 'package:farax/components/hex_color.dart';
import 'package:farax/pages/package_size.dart';
import 'package:flutter/material.dart';
import '../all_translations.dart';
import '../components/gradient_appbar.dart';


class PackageInformation extends StatefulWidget {
  const PackageInformation({
    Key key,
    @required this.order
  }) : super(key: key);

  final dynamic order;

  @override
  _PackageInformationState createState() => _PackageInformationState();
}

class _PackageInformationState extends State<PackageInformation> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  
  @override
  Widget build(BuildContext context) {
    final dynamic orderPackages = widget.order['orderPackages'];
    List<Widget> list = new List<Widget>();
    for(var i = 0; i < orderPackages['items'].length; i ++) {
      list.add(new PackageOrderItem(item: orderPackages['items'][i]));
    }
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomPadding: false,
      body: Column(
        children: <Widget>[
          GradientAppBar(title: allTranslations.text('package_information'), hasBackIcon: true),
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
                                child: Column(
                                    children: <Widget>[
                                      Container(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        decoration: BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(
                                                width: 1,
                                                color: HexColor('#ECEFF1')
                                              )
                                          ),
                                        ),
                                        child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Text(allTranslations.text('package_information'), style: TextStyle(fontSize: 16, color: HexColor('#263238'), fontWeight: FontWeight.bold))
                                            ]
                                        ),
                                      ),
                                      SizedBox(height: 8,),
                                      Align(
                                        alignment: Alignment.centerLeft,

                                        child: Text(allTranslations.text('general_package_information').toUpperCase(), style: TextStyle(fontSize: 14, color: HexColor('#0099CC'), fontWeight: FontWeight.bold), textAlign: TextAlign.left),
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Expanded(
                                            flex: 2,
                                            child: Text(allTranslations.text('delivery_time') + ':', style: TextStyle(color: Color.fromRGBO(196, 206, 211, 1), fontSize: 14),),
                                          ),
                                          Flexible(
                                              flex: 3,
                                              fit: FlexFit.loose,
                                              child: Text(widget.order['delivery']['time'].toString() + ' hours', style: TextStyle(color: HexColor('#FF9933'), fontSize: 14), textAlign: TextAlign.left)
                                          )
                                        ],
                                      ),
                                      SizedBox(height: 8,),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Expanded(
                                            flex: 2,
                                            child: Text(allTranslations.text('caution') + ':', style: TextStyle(color: Color.fromRGBO(196, 206, 211, 1), fontSize: 14),),
                                          ),
                                          Flexible(
                                              flex: 3,
                                              fit: FlexFit.loose,
                                              child: Text(orderPackages['packageType']['name'], style: TextStyle(color: HexColor('#455A64'), fontSize: 14), textAlign: TextAlign.left)
                                          )
                                        ],
                                      ),
                                      SizedBox(height: 8,),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Expanded(
                                            flex: 2,
                                            child: Text(allTranslations.text('who_pays') + ':', style: TextStyle(color: Color.fromRGBO(196, 206, 211, 1), fontSize: 14),),
                                          ),
                                          Flexible(
                                              flex: 3,
                                              fit: FlexFit.loose,
                                              child: Text(orderPackages['isShopPaid'] == true ? allTranslations.text('shop') : allTranslations.text('customer'), style: TextStyle(color:  HexColor('#455A64'), fontSize: 14), textAlign: TextAlign.left)
                                          )
                                        ],
                                      ),
                                      SizedBox(height: 12,),
                                      orderPackages['extraService'] == 'cod' ? Align(
                                        alignment: Alignment.centerLeft,

                                        child: Text(allTranslations.text('items_in_package').toUpperCase(), style: TextStyle(fontSize: 14, color: HexColor('#0099CC'), fontWeight: FontWeight.bold), textAlign: TextAlign.left),
                                      ) : IgnorePointer(
                                        ignoring: true,
                                        child: Opacity(
                                          opacity: 0.0,
                                        ),
                                      ),
                                      orderPackages['extraService'] == 'cod' ? Column(
                                        children: list,
                                      ) : IgnorePointer(
                                        ignoring: true,
                                        child: Opacity(
                                          opacity: 0.0,
                                        ),
                                      )
                                    ]
                                )
                            ),
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
                    builder: (context) => PackageSize(order: widget.order)
                ));
              },
              color: Color.fromRGBO(253, 134, 39, 1),
              textColor: Colors.white,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10))
                ),
                child: Center(
                  child: Text(allTranslations.text('check_your_package_size').toUpperCase(), style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          )
        ],
      )
    );
  }
}

class PackageOrderItem extends StatelessWidget {
  const PackageOrderItem({
    Key key,
    @required this.item,
  }) : super(key: key);

  final dynamic item;

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: item['index'] % 2 == 0 ? Color.fromRGBO(248, 248, 248, 1) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
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

class ReturnedOrderItem extends StatelessWidget {
  const ReturnedOrderItem({
    Key key,
    @required this.item,
  }) : super(key: key);

  final dynamic item;

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: item['index'] % 2 == 0 ? Color.fromRGBO(248, 248, 248, 1) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
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
            Text('x' + item['returnAmount'].toString())
          ],
        ),
      ),
    );
  }
}

class Item {
  final String name;
  final int price;
  final int amount;
  Item._({this.name, this.price, this.amount});
  factory Item.fromJson(Map<String, dynamic> json) {
    return new Item._(
      name: json['name'],
      price: json['price'],
      amount: json['amount']
    );
  }
}
