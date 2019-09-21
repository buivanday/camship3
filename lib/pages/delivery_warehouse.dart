import 'package:farax/components/hex_color.dart';
import 'package:farax/components/order_detail_item.dart';
import 'package:farax/pages/confirm_pending.dart';
import 'package:farax/pages/delivery_customer.dart';
import 'package:farax/pages/package_information.dart';
import 'package:flutter/material.dart';
import '../all_translations.dart';
import '../components/gradient_appbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/auth_utils.dart';

class DeliveryWarehouse extends StatefulWidget {
  const DeliveryWarehouse({
    Key key,
    @required this.order
  }) : super(key: key);

  final dynamic order;

  @override
  _DeliveryWarehouseState createState() => _DeliveryWarehouseState();
}

class _DeliveryWarehouseState extends State<DeliveryWarehouse> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isClickLeftButton = false;
  bool isClickRightButton = false;
  
  @override
  void initState() {
    super.initState();
  }

  Future _fetch() async {
    Navigator.push(_scaffoldKey.currentContext, MaterialPageRoute(
      builder: (context) => PackageInformation(order: widget.order)
    ));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomPadding: false,
        body: Column(
          children: <Widget>[
            GradientAppBar(title: allTranslations.text('delivering'),hasBackIcon: true, backToHome: true),
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
                              Image.asset('icons/Group.png'),
                              SizedBox(height: 24,),
                              Text(allTranslations.text('you_are_delivering_to_warehouse'), style: TextStyle(color: HexColor('#0099CC'), fontSize: 18), textAlign: TextAlign.center,)
                            ],
                          ),
                        ),
                      ),
                      Container(
                          padding: const EdgeInsets.all(16),
                          child: OrderDetailItem(order: widget.order, isReturnToWareHouse: true,),
                      ),
                    ],
                  ),
                )
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