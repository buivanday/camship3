import 'package:farax/blocs/shop_api.dart';
import 'package:farax/components/gradient_appbar.dart';
import 'package:farax/components/hex_color.dart';
import 'package:farax/utils/auth_utils.dart';
import 'package:farax/utils/network_utils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../all_translations.dart';
import 'create_package_detail.dart';
import 'create_package_sharepreference.dart';
import 'package:provider/provider.dart';
import 'package:farax/services/connectivity.dart';



class CreatePackageBill extends StatefulWidget {
  const CreatePackageBill({
    Key key,
    this.shopInformation,
    this.receiverInformation,
    this.zoneInformation,
    this.isSaveContact = false,
    this.packageInformation,
    this.deliveryTime,
    this.totalShippingPrice = 0,
    this.totalCOD = 0,
    this.valueOfOrder = 0,
    this.shopNotes
  }) : super(key: key);

  final Map<String, dynamic> shopInformation;
  final Map<String, dynamic> receiverInformation;
  final Map<String, dynamic> zoneInformation;
  final bool isSaveContact;
  final Map<String, dynamic> packageInformation;
  final String deliveryTime;
  final double totalShippingPrice;
  final double totalCOD;
  final double valueOfOrder;
  final String shopNotes;
  
  @override
  _CreatePackageBillState createState() => _CreatePackageBillState();
}

class _CreatePackageBillState extends State<CreatePackageBill> {
  bool isClickCod = false;
  bool isClickExpress = false;
  bool isClickShop = false;
  bool isClickCustomer = false;
  bool _isValid = true;
  bool _showWaiting = false;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
	Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences _sharedPreferences;
  List<Widget> codItems = new List<Widget>();
  CreatePackageSharePreference _pref;
  String packageType = '';
  var network;
  bool isOffline = false;
  bool isWaiting = false;
  @override
	void initState() {
		super.initState();
		_fetchSessionAndNavigate();
	}

  _fetchSessionAndNavigate() async {
		_sharedPreferences = await _prefs;
    
    await _sharedPreferences.setBool("isBillExist", true);
		String authToken = AuthUtils.getToken(_sharedPreferences);

		if(authToken == null) {
			_logout();
		}
	}

  _addItem() {
    
    setState(() {
      codItems.add(new CodItem(index: codItems.length + 1,));
    });
  }

  _handleChangePackageType(value) {
    setState(() {
      packageType = value;
    });
  }

  _logout() {
		NetworkUtils.logoutUser(_scaffoldKey.currentContext, _sharedPreferences);
	}
  _valid(){
    return !isOffline;
  }
  void _showDialog() async {
    setState(() {
      _showWaiting = true;
    });
   
    _sharedPreferences = await _prefs;
		String authToken = AuthUtils.getToken(_sharedPreferences);
    int deliveryTime = int.parse(widget.deliveryTime.replaceAll('h', ''));
    if(deliveryTime == 3) {
      deliveryTime = 2;
    } else if(deliveryTime == 6) {
      deliveryTime = 4;
    } else if(deliveryTime == 12) {
      deliveryTime = 8;
    }
    final deliveryTimes = await NetworkUtils.fetch(authToken, '/api/DeliveryTimes?filter={"where": {"time": '+ deliveryTime.toString() +'}}');
    var createOrderResponse = await NetworkUtils.postWithBody(authToken, '/api/Orders', {
      'deliveryTimeId': deliveryTimes[0]['id'],
      'isSaveReceiver': widget.isSaveContact,
      'orderPackage': widget.packageInformation,
      'receiver': widget.receiverInformation,
      'shippingCost': widget.totalShippingPrice,
      'shopId': widget.shopInformation['id'],
      'totalCOD': widget.packageInformation['extraService'] == 'express' ? 0 : widget.totalCOD,
      'total': widget.packageInformation['price'],
      'valueOfOrder': widget.packageInformation['total'],
      'shopNotes': widget.shopNotes
    });
    
    if(createOrderResponse != null && createOrderResponse['orderId'] != '') {
      ShopOrder createdOrder = ShopOrder.fromJson(createOrderResponse);
      await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => new DialogConfirmPackageBill(order: createdOrder,
        authToken: authToken, scaffoldKey: _scaffoldKey, 
        sharedPreferences: _sharedPreferences)
      );
      isWaiting = true;
    } else { 
     
    }  
    
  }
 
  @override
  Widget build(BuildContext context) {
    double total = 0;
    bool isCOD = widget.packageInformation['extraService'] == 'cod';
    bool isShopPaid = widget.packageInformation['isShopPaid'] == 'true';
    dynamic shippingCost = widget.totalShippingPrice;
    dynamic totalCOD = widget.totalCOD;
    if(isCOD) {
      if(isShopPaid) {
        total += shippingCost + totalCOD;
      } else {
        total += totalCOD;
      }
    } else {
      if(isShopPaid) {
        total += shippingCost;
      } else {
        total = 0;
      }
    }
    var network = Provider.of<ConnectionStatus>(context);
    if(network==ConnectionStatus.offline){
      NetworkUtils.showSnackBar(_scaffoldKey, null);
      isOffline = true;
    }else{
      isOffline = false;
    }
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        color: Color.fromRGBO(242, 242, 242, 1),
        child: Column(
          children: <Widget>[
            GradientAppBar(title: allTranslations.text('create_package_bill_title'),hasBackIcon: true),
            Expanded(
              flex: 1,
              child: Stack(
                children: <Widget>[
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            color: Colors.white,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(height: 30.0,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(total.toStringAsFixed(2), style: TextStyle(color: HexColor('#FF9933'), fontWeight: FontWeight.bold, fontSize: 24.0),),
                                    SizedBox(width: 2.0,),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(allTranslations.text('usd').toUpperCase(), style: TextStyle(color: HexColor('#FF9933'), fontSize: 16.0, fontWeight: FontWeight.bold),),
                                    )
                                  ],
                                ),
                                SizedBox(height: 25.0,),
                                Image.asset('icons/Line-bill.png', fit: BoxFit.contain, width: double.infinity),
                                SizedBox(height: 20.0,),
                                Text(widget.packageInformation['extraService'] == 'express' ? allTranslations.text('package_information') : 'A leather wallet', style: TextStyle(color: HexColor('#455A64'), fontSize: 14.0, fontWeight: FontWeight.bold),),
                                SizedBox(height: 10.0,),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 3,
                                      child: Row(
                                        children: <Widget>[
                                          Text(allTranslations.text('weight') + ':', style: TextStyle(color: HexColor('#78909C'), fontSize: 14),),
                                          Text(widget.packageInformation['weight'].toString() + ' (' + allTranslations.text('kg') + ')', style: TextStyle(color: HexColor('#78909C'), fontSize: 14, fontWeight: FontWeight.bold))
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(widget.totalShippingPrice.toStringAsFixed(2) + ' ' + allTranslations.text('usd').toUpperCase(), style: TextStyle(color: HexColor('#455A64'), fontWeight: FontWeight.bold), textAlign: TextAlign.right,),
                                    )
                                  ],
                                ),
                                SizedBox(height: 10.0,),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 3,
                                      child: Row(
                                        children: <Widget>[
                                          Text(allTranslations.text('delivery_time') + ':', style: TextStyle(color: HexColor('#78909C'), fontSize: 14),),
                                          Text(' ' + widget.deliveryTime, style: TextStyle(color: HexColor('#78909C'), fontSize: 14, fontWeight: FontWeight.bold))
                                        ],
                                      ),
                                    ),
                                    // Expanded(
                                    //   flex: 1,
                                    //   child: Text(widget.zoneInformation[widget.deliveryTime].toString() + ' ' + allTranslations.text('usd').toUpperCase(), style: TextStyle(color: HexColor('#455A64'), fontWeight: FontWeight.bold), textAlign: TextAlign.right,),
                                    // )
                                  ],
                                ),
                                SizedBox(height: 10.0,),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 1,
                                      child: Row(
                                        children: <Widget>[
                                          Text(allTranslations.text('package_type') + ':', style: TextStyle(color: HexColor('#78909C'), fontSize: 14),),
                                          Text(' ' + widget.packageInformation['typeOfCalWeight'] == 'actualWeight' ? allTranslations.text('actual_weight') : allTranslations.text('actual_weight'),style: TextStyle(color: HexColor('#78909C'), fontSize: 14, fontWeight: FontWeight.bold))
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.0,),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 1,
                                      child: Row(
                                        children: <Widget>[
                                          Text(allTranslations.text('who_pays') + ':', style: TextStyle(color: HexColor('#78909C'), fontSize: 14),),
                                          Text(' ' + (widget.packageInformation['isShopPaid'] == 'true' ? 'Shop' : 'Customer'),style: TextStyle(color: HexColor('#78909C'), fontSize: 14, fontWeight: FontWeight.bold))
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20.0,),
                                Image.asset('icons/Line-bill.png', fit: BoxFit.contain, width: double.infinity),
                                SizedBox(height: 20.0,),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 3,
                                      child: Text(allTranslations.text('promotion_code') + ':', style: TextStyle(color: HexColor('#78909C'), fontSize: 14),),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text('0' + ' ' + allTranslations.text('usd').toUpperCase(), style: TextStyle(color: HexColor('#455A64'), fontWeight: FontWeight.bold), textAlign: TextAlign.right,),
                                    )
                                  ],
                                ),
                                SizedBox(height: 20.0,),
                                Image.asset('icons/Line-bill.png', fit: BoxFit.contain, width: double.infinity),
                                SizedBox(height: 20.0,),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 3,
                                      child: Text(allTranslations.text('total_shipping_price'), style: TextStyle(color: HexColor('#78909C'), fontSize: 14),),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text((widget.packageInformation['isShopPaid'] == 'false' ? '0' : widget.totalShippingPrice.toString()) + ' ' + allTranslations.text('usd').toUpperCase(), style: TextStyle(color: HexColor('#455A64'), fontWeight: FontWeight.bold), textAlign: TextAlign.right,),
                                    )
                                  ],
                                ),
                                SizedBox(height: 20.0,),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 3,
                                      child: Text(allTranslations.text('total_cod'), style: TextStyle(color: HexColor('#78909C'), fontSize: 14),),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text((widget.valueOfOrder).toStringAsFixed(2) + ' ' + allTranslations.text('usd').toUpperCase(), style: TextStyle(color: HexColor('#455A64'), fontWeight: FontWeight.bold), textAlign: TextAlign.right,),
                                    )
                                  ],
                                ),
                                SizedBox(height: 20.0,),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 3,
                                      child: Text(allTranslations.text('cod_fee'), style: TextStyle(color: HexColor('#78909C'), fontSize: 14),),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(widget.totalCOD.toStringAsFixed(2) + ' ' + allTranslations.text('usd').toUpperCase(), style: TextStyle(color: HexColor('#455A64'), fontWeight: FontWeight.bold), textAlign: TextAlign.right,),
                                    )
                                  ],
                                ),
                                SizedBox(height: 20.0,),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 3,
                                      child: Text(allTranslations.text('total'), style: TextStyle(color: HexColor('#78909C'), fontSize: 14),),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(total.toStringAsFixed(2) + ' ' + allTranslations.text('usd').toUpperCase(), style: TextStyle(color: HexColor('#455A64'), fontWeight: FontWeight.bold), textAlign: TextAlign.right,),
                                    )
                                  ],
                                ),
                                SizedBox(height: 30.0,),
                              ],
                            ),
                          )
                          ,Image.asset('icons/bill-bottom-line.png', fit: BoxFit.contain, width: double.infinity),
                        ],
                      ),
                    )
                  ),
                  _showWaiting||isOffline ? Center(
                    child: CircularProgressIndicator(strokeWidth: 6,),
                  ) : Opacity(opacity: 0.0,)
                ],
              )
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: RaisedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      color: Color.fromRGBO(242, 242, 242, 1),
                      textColor: HexColor('#78909C'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(4.0))
                        ),
                        child: Center(
                          child: Text(allTranslations.text('back').toUpperCase(), style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.0,),
                  Expanded(
                    flex: 2,
                    child: RaisedButton(
                      onPressed: _valid()&&_isValid && !_showWaiting ? _showDialog : null,
                      disabledColor: HexColor('#B0BEC5'),
                      disabledTextColor: Colors.white,
                      color: Color.fromRGBO(253, 134, 39, 1),
                      textColor: Colors.white,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10))
                        ),
                        child: Center(
                          child: Text(allTranslations.text('create_package').toUpperCase(), style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ]
        )
      )
    );
  }
}

class CodItem extends StatelessWidget {
  const CodItem({
    Key key,
    this.index
  }) : super(key: key);

  final int index;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(Icons.lens, size: 10, color: HexColor('#FF9933'),),
            SizedBox(width: 8.0,),
            Text((allTranslations.text('item') + ' ' + index.toString()).toUpperCase(), style: TextStyle(color: HexColor('#78909C'), fontSize: 12, fontWeight: FontWeight.bold),),
          ],
        ),
        Theme(
          data: new ThemeData(
            hintColor: HexColor('#DFE4EA')
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: allTranslations.text('name'),
              hintStyle: TextStyle(color: HexColor('#90A4AE'), fontSize: 14),
            ),
          ),
        ),
        SizedBox(height: 20.0,),
        Theme(
          data: new ThemeData(
            hintColor: HexColor('#DFE4EA')
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: allTranslations.text('price') + ' (' + allTranslations.text('usd').toUpperCase() + ')',
              hintStyle: TextStyle(color: HexColor('#90A4AE'), fontSize: 14),
            ),
          ),
        ),
        SizedBox(height: 20.0)
      ],
    );
  }
}

class CreatePackageTitle extends StatelessWidget {
  const CreatePackageTitle({
    Key key,
    this.icon,
    this.title
  }) : super(key: key);

  final String icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            maxRadius: 32.0,
            backgroundColor: Color.fromRGBO(0, 153, 204, 0.1),
            child: Center(
              child: Image.asset(icon),
            ),
          ),
          SizedBox(width: 20.0,),
          Text(allTranslations.text(title), style: TextStyle(color: HexColor('#455A64'), fontWeight: FontWeight.bold, fontSize: 18.0),),
        ],
      ),
    );
  }
}

class DialogConfirmPackageBill extends StatelessWidget {
  const DialogConfirmPackageBill({
    Key key,
    @required this.order,
    @required this.authToken,
    @required this.scaffoldKey,
    @required this.sharedPreferences
  }) : super(key: key);

  final ShopOrder order;
  final String authToken;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final SharedPreferences sharedPreferences;


  Future _acceptOrder(BuildContext context) async {
   
    Navigator.of(context).push(
      new PageRouteBuilder(
        pageBuilder: (BuildContext context, _, __) {
          return CreatePackageDetail(order: order, isCreatePackage: true);
        },
      )
    );
  }

  _logout() {
		NetworkUtils.logoutUser(scaffoldKey.currentContext, sharedPreferences);
	}
  _removePref() async{
    final SharedPreferences pref =await SharedPreferences.getInstance();
                    bool check;
                    check = await pref.remove('Deliverytime');
                    print('pfre'+check.toString());
                    check = await pref.remove('HeightNumber');
                    check = await pref.remove('LengthNumber');
                    check = await pref.remove('NoteTxt');
                    check = await pref.remove('packageType');
                    check = await pref.remove('isPageTwoExist');
                    check = await pref.remove('isPageThreeExist');
                  
                    check = await pref.remove('PromptionCode');
                    check = await pref.remove('Service');
                    check = await pref.remove('TotalService');
                    check = await pref.remove('Weight');
                    check = await pref.remove('WeightNumber');
                    check = await pref.remove('WhoPay');
                    check = await pref.remove('WidthNumber');
                    check = await pref.remove('dataPageOne');

                    await pref.setBool("isPageTwoExist", false);
                    await pref.setBool("isPageThreeExist", false);
  }
  @override
  Widget build(BuildContext context) {
   
    DateTime now = DateTime.now();
    print(now.hour);
    return WillPopScope(
      onWillPop: ()async=>false,
      child: Center(
      child: Container(
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4.0))
          ),
          contentPadding: const EdgeInsets.all(20.0),
          backgroundColor: Colors.white,
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Image.asset('icons/bill-alert-icon-title.png'),
              SizedBox(width: 16),
              Text(allTranslations.text('successfully') + '!',
              style: TextStyle(
                color: Color.fromRGBO(20, 156, 206, 1),
                fontWeight: FontWeight.bold,
                fontSize: 16
              )),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(allTranslations.text(now.hour > 18 ? 'create_package_bill_cofirm_content_late' : 'create_package_bill_cofirm_content'), style: TextStyle(
                  color: HexColor('#455A64'),
                  fontSize: 14,
                  height: 20/14.0
                )),
                SizedBox(height: 20.0),
                InkWell(
                  onTap: () async{                
                    _acceptOrder(context);
                    _removePref();              
                    },
                  child: new Container(
                    width: 146,
                    height: 42,
                    decoration: new BoxDecoration(
                      color: HexColor('#FF9933'),
                      borderRadius: BorderRadius.all(Radius.circular(4.0))
                    ),
                    child: new Center(child: new Text(allTranslations.text('ok').toUpperCase(), style: new TextStyle(fontSize: 14.0, color: Colors.white, fontWeight: FontWeight.bold),),),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ) 
      
      ,
    );
  
  }
}