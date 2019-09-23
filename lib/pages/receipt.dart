import 'package:farax/components/hex_color.dart';
import 'package:farax/pages/congratulation.dart';
import 'package:flutter/material.dart';
import '../all_translations.dart';
import '../components/gradient_appbar.dart';
import '../utils/network_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/auth_utils.dart';

class Receipt extends StatefulWidget {
  const Receipt({
    Key key,
    @required this.order,
    this.isReturnedOrder,
    this.returnedOrders,
    this.reason
  }) : super(key: key);

  final dynamic order;

  final bool isReturnedOrder;

  final dynamic returnedOrders;

  final String reason;

  @override
  _ReceiptState createState() => _ReceiptState();
}

class _ReceiptState extends State<Receipt> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
	SharedPreferences _sharedPreferences;

  Future _confirmInShop() async {
    _sharedPreferences = await _prefs;
		String authToken = AuthUtils.getToken(_sharedPreferences);
    var responseJson = await NetworkUtils.post(authToken, '/api/Orders/${widget.order['id']}/completed');
    if(responseJson == null) {

      NetworkUtils.showSnackBar(_scaffoldKey, allTranslations.text('something_went_wrong'));

    } else if(responseJson == 'NetworkError') {

      NetworkUtils.showSnackBar(_scaffoldKey, null);

    } else if(responseJson['errors'] != null) {
      NetworkUtils.logoutUser(_scaffoldKey.currentContext, _sharedPreferences);
    } else {
      Navigator.of(context).pop();
      Navigator.push(context, MaterialPageRoute(
        builder: (context) => new Congratulation()
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    int deliveryTime = widget.order['delivery']['time'];
    String extraService = widget.order['orderPackages']['extraService'];
    bool isShopPaid = widget.order['orderPackages']['isShopPaid'];
    print(isShopPaid);
    double totalCOD = 0;
    double total = 0;
    double valueOfOrder = 0;
    if(extraService == 'cod') {
      totalCOD = widget.order['totalCOD'].toDouble();
      valueOfOrder = widget.order['valueOfOrder'].toDouble();
      total += (valueOfOrder + (isShopPaid ? 0 : widget.order['shippingCost'].toDouble()));
    } else {
      total += isShopPaid ? 0 : widget.order['shippingCost'].toDouble();
    }

    return Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomPadding: false,
        body: Column(
          children: <Widget>[
            GradientAppBar(title: allTranslations.text('receipt'), hasBackIcon: true,),
            Expanded(
              flex: 1,
              child: Container(
                color: Color.fromRGBO(241, 242, 242, 1),
                padding: const EdgeInsets.only(left: 24, top: 40, right: 24),
                child: Container(
                  child: Stack(
                    children: <Widget>[
                      ClipPath(
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.7,
                          color: Colors.white,
                          child: Column(
                            children: <Widget>[
                              Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.only(top: 45),
                                height: 99.0 + 15.0,
                                child: Column(
                                  children: <Widget>[
                                    Text(allTranslations.text('thank_you'), style: TextStyle(color: HexColor('#263238'), fontSize: 18, fontWeight: FontWeight.bold)),
                                    SizedBox(height: 4,),
                                    Text(allTranslations.text('your_transaction_was_successful'), style: TextStyle(color: HexColor('#78909C')),)
                                  ],
                                ),
                              ),
                              Image.asset('icons/Line.png'),
                              SizedBox(height: 24,),
                              Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                  children: <Widget>[
                                    Column(
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Text(allTranslations.text('shipping_fee').toUpperCase()),
                                              Text(widget.order['shippingCost'].toStringAsFixed(2) + ' ' + allTranslations.text('usd').toUpperCase())
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Text(allTranslations.text('order_type').toUpperCase()),
                                              Text(allTranslations.text(extraService).toUpperCase())
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Text(allTranslations.text('cod').toUpperCase()),
                                              Text(valueOfOrder.toStringAsFixed(2) + ' ' + allTranslations.text('usd').toUpperCase())
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Text(allTranslations.text('cod_fee').toUpperCase()),
                                              Text(totalCOD.toStringAsFixed(2) + ' ' + allTranslations.text('usd').toUpperCase())
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Text(allTranslations.text('who_pays').toUpperCase()),
                                              Text((isShopPaid ? allTranslations.text('shop') : allTranslations.text('customer')).toUpperCase())
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    
                                    Container(
                                      color: HexColor('#F5F5F5'),
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Expanded(
                                            flex: 1,
                                            child: Text(allTranslations.text('amount_collect_from_receiver'), style: TextStyle(color: HexColor('#455A64'), fontWeight: FontWeight.bold),),
                                          ),
                                          Expanded(
                                            flex: 1, 
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Text(total.toStringAsFixed(2) + ' ' + allTranslations.text('usd').toUpperCase(), style: TextStyle(fontSize: 20,color: HexColor('#FF9933'), fontWeight: FontWeight.bold),),
                                            )
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        clipper: BottomWaveClipper(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              color: Color.fromRGBO(241, 242, 242, 1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                  child: RaisedButton(
                    onPressed: _confirmInShop,
                    color: Color.fromRGBO(253, 134, 39, 1),
                    textColor: Colors.white,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10))
                      ),
                      child: Center(
                        child: Text(allTranslations.text('ok').toUpperCase(), style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ),
            )
          ],
        )
    );
  }
}

class BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = new Path();
    path.lineTo(0.0, 99.0 );
    var firstControlPoint = new Offset(15.0, 99.0 + 15.0);
    var firstEndPoint = new Offset(0.0, 99.0 + 30);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);
    path.lineTo(0.0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 99.0 + 30);
    var secondControlPoint = Offset(size.width - 15.0, 99.0 + 15.0);
    var secondEndPoint = Offset(size.width, 99.0);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, 0.0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}