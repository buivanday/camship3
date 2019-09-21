import 'package:farax/components/hex_color.dart';
import 'package:farax/pages/delivery_customer.dart';
import 'package:farax/pages/delivery_warehouse.dart';
import 'package:flutter/material.dart';
import '../all_translations.dart';
import '../components/gradient_appbar.dart';
import '../utils/network_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/auth_utils.dart';

class PackageSize extends StatefulWidget {
  const PackageSize({
    Key key,
    @required this.order
  }) : super(key: key);

  final dynamic order;

  @override
  _PackageSizeState createState() => _PackageSizeState();
}

class _PackageSizeState extends State<PackageSize> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
	SharedPreferences _sharedPreferences;
  bool isClickLeftButton = false;

  Future _showDialog() async {
    _sharedPreferences = await _prefs;
		String authToken = AuthUtils.getToken(_sharedPreferences);
    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => new DialogConfirmOrder(order: widget.order,
      authToken: authToken, scaffoldKey: _scaffoldKey,
      isClickLeftButton: isClickLeftButton,
      sharedPreferences: _sharedPreferences)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomPadding: false,
        body: Column(
          children: <Widget>[
            GradientAppBar(title: allTranslations.text('package_size'),hasBackIcon: true),
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
                                  child: Column(
                                      children: <Widget>[
                                        Container(
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          width: MediaQuery.of(context).size.width * 0.85,
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
                                                Text(allTranslations.text('package_size'), style: TextStyle(fontSize: 16, color: HexColor('#263238'), fontWeight: FontWeight.bold))
                                              ]
                                          ),
                                        ),
                                        SizedBox(height: 8,),
                                        Container(
                                          child: widget.order['orderPackages']['typeOfCalWeight'] == 'actualWeight' ? Column(
                                            children: <Widget>[
                                              Container(
                                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: <Widget>[
                                                    Text(allTranslations.text('weight'), style: TextStyle(color: HexColor('#455A64')),),
                                                    Text(widget.order['orderPackages']['weight'].toString() + 'kg', style: TextStyle(color: HexColor('#455A64')),)
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ) : Column(
                                            children: <Widget>[
                                              Container(
                                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: <Widget>[
                                                    Text(allTranslations.text('height'), style: TextStyle(color: HexColor('#455A64')),),
                                                    Text(widget.order['orderPackages']['packageSize']['height'].toString() + 'cm', style: TextStyle(color: HexColor('#455A64')),)
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                                decoration: BoxDecoration(
                                                  color: HexColor('#F8F8F8')
                                                ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: <Widget>[
                                                    Text(allTranslations.text('length'), style: TextStyle(color: HexColor('#455A64')),),
                                                    Text(widget.order['orderPackages']['packageSize']['length'].toString() + 'cm', style: TextStyle(color: HexColor('#455A64')),)
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: <Widget>[
                                                    Text(allTranslations.text('width'), style: TextStyle(color: HexColor('#455A64')),),
                                                    Text(widget.order['orderPackages']['packageSize']['width'].toString() + 'cm', style: TextStyle(color: HexColor('#455A64')),)
                                                  ],
                                                )
                                              ),
                                            ],
                                          ),
                                        )
                                      ]
                                  )
                              ),
                              SizedBox(height: 24),
                              Container(
                                child: IntrinsicHeight(
                                  child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 1,
                                      child: Container()
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            isClickLeftButton = !isClickLeftButton;
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: isClickLeftButton == false ? HexColor('#DFE4EA') : HexColor('#0099CC'),
                                            ),
                                            borderRadius: BorderRadius.all(Radius.circular(5))
                                          ),
                                          child: Center(
                                            child: Text(allTranslations.text('incorrect_size_not_edit'), textAlign: TextAlign.center,),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 11,),
                                    Expanded(
                                      flex: 1,
                                      child: Container()
                                    )
                                  ],
                                ),
                                )
                              ),
                              SizedBox(height: 16,),
                              isClickLeftButton == true ? Text(allTranslations.text('incorrect_size_not_edit_quote')) : SizedBox(width: 0,),
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
                onPressed: _showDialog,
                color: Color.fromRGBO(253, 134, 39, 1),
                textColor: Colors.white,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10))
                  ),
                  child: Center(
                    child: Text(allTranslations.text('confirm').toUpperCase(), style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            )
          ],
        )
    );
  }
}

class DialogConfirmOrder extends StatefulWidget {
  const DialogConfirmOrder({
    Key key,
    @required this.order,
    @required this.authToken,
    @required this.scaffoldKey,
    @required this.sharedPreferences,
    this.isClickLeftButton
  }) : super(key: key);

  final dynamic order;
  final String authToken;
  final isClickLeftButton;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final SharedPreferences sharedPreferences;

  @override
  _DialogConfirmOrderState createState() => _DialogConfirmOrderState();
}

class _DialogConfirmOrderState extends State<DialogConfirmOrder> {
  bool _isWaiting = false;
  Future _confirmInShop() async {
    setState(() {
      _isWaiting = true;
    });
    if(widget.isClickLeftButton == true) {
      var responseJson = await NetworkUtils.post(widget.authToken, '/api/Orders/${widget.order['id']}/shipping-failed');
      setState(() {
          _isWaiting = false;
        });
      if(responseJson == null) {
        NetworkUtils.showSnackBar(widget.scaffoldKey, allTranslations.text('something_went_wrong'));
      } else if(responseJson == 'NetworkError') {
        NetworkUtils.showSnackBar(widget.scaffoldKey, null);
      } else if(responseJson['error'] != null) {
        NetworkUtils.logoutUser(widget.scaffoldKey.currentContext, widget.sharedPreferences);
      } else {
        Navigator.pushReplacementNamed(widget.scaffoldKey.currentContext, '/main');
      }
    } else {
      var responseJson = await NetworkUtils.post(widget.authToken, '/api/Orders/${widget.order['id']}/shop-confirmed');
      setState(() {
        _isWaiting = false;
      });
      if(responseJson == null) {
        NetworkUtils.showSnackBar(widget.scaffoldKey, allTranslations.text('something_went_wrong'));
      } else if(responseJson == 'NetworkError') {
        NetworkUtils.showSnackBar(widget.scaffoldKey, null);
      } else if(responseJson['error'] != null) {
        // NetworkUtils.logoutUser(_scaffoldKey.currentContext, _sharedPreferences);
      } else {
        Navigator.pushReplacement(widget.scaffoldKey.currentContext, MaterialPageRoute(
          builder: (context) => widget.order['delivery']['time'] < 24 ? DeliveryCustomer(order: widget.order) : DeliveryWarehouse(order: widget.order)
        ));
      }
    }
    
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
              Text(allTranslations.text('confirm') + ' ' + allTranslations.text('order'),
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
                Text(allTranslations.text('you_have_an_order_need_confirm'), style: TextStyle(
                  color: Color.fromRGBO(92, 111, 119, 1),
                  fontSize: 13,
                )),
              ],
            ),
          ),
          actions: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.7,
              child: Stack(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child:  InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: new Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: new BoxDecoration(
                              color: Colors.white,
                              border: new Border.all(color: Color.fromRGBO(20, 156, 206, 1), width: 1.0),
                              borderRadius: new BorderRadius.circular(3.0),
                            ),
                            child: new Center(child: new Text(allTranslations.text('cancel').toUpperCase(), style: new TextStyle(fontSize: 14.0, color: Color.fromRGBO(20, 156, 206, 1), fontWeight: FontWeight.bold),),),
                          ),
                        ),
                      ),
                      SizedBox(width: 8,),
                      Expanded(
                        flex: 1,
                        child:  RaisedButton(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(allTranslations.text('confirm').toUpperCase()),
                          color: Color.fromRGBO(253, 134, 39, 1),
                          textColor: Colors.white,
                          onPressed: () {
                            _confirmInShop();
                          },
                        ),
                      ),
                    ],
                  ),
                  _isWaiting ? Center(
                    child: CircularProgressIndicator(),
                  ) : Opacity(opacity: 0.0,)
                ],
              )
            )
          ],
        ),
      ),
    );
  }
}