import 'package:cached_network_image/cached_network_image.dart';
import 'package:farax/blocs/shop_api.dart';
import 'package:farax/components/gradient_appbar.dart';
import 'package:farax/components/hex_color.dart';
import 'package:farax/utils/auth_utils.dart';
import 'package:farax/utils/network_utils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../all_translations.dart';
import '../choose_on_map.dart';
import '../package_information.dart';
import 'create_package_information.dart';
import 'create_package_services.dart';
import 'delivery_status.dart';
import 'package:date_format/date_format.dart';
import '../../utils/lodash.dart';

class CreatePackageDetail extends StatefulWidget {
  CreatePackageDetail({
    Key key,
    this.hasNavbar = true,
    this.order,
    this.isCreatePackage = false,
    this.isFromShipperHistory = false,
    this.fromCashedOut = false
  }) : super(key: key);

  final bool hasNavbar;
  final bool isCreatePackage;
  final ShopOrder order;
  final isFromShipperHistory;
  final bool fromCashedOut;
  @override
  _CreatePackageDetailState createState() => _CreatePackageDetailState();
}

class _CreatePackageDetailState extends State<CreatePackageDetail> {
  bool _isValid = true;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
	Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences _sharedPreferences;
  List<CodItem> codItems = new List<CodItem>();
  List<CodItem> codItemCurrent = new List<CodItem>();
  bool _isClickEditReceiver = false;
  bool _isClickEditPackage = false;
  var _fullNameCustomerController = new TextEditingController();
  var _phoneNumberCustomerController = new TextEditingController();
  var _addressCustomerController = new TextEditingController();
  var _weightController = new TextEditingController();
  var _valueOfOrderController = new TextEditingController();
  final FocusNode _fullNameFocusNode = FocusNode(); 
  final FocusNode _phoneNumberFocusNode = FocusNode();
  var lengthController = new TextEditingController();
  var widthController = new TextEditingController();
  var heightController = new TextEditingController();
  double _weight = 0;
  double totalShippingPrice = 0;
  List<TextEditingController> codItemControllers = new List<TextEditingController>();
  List<TextEditingController> codItemControllersCurrent = new List<TextEditingController>();
  bool isLoaded = false;
  dynamic selectedZone;
  double lat;
  double lng;
  bool isClickLeftButton;
  bool isClickRightButton;
  String packageType = '';
  bool isShopPaid;
  int deliveryTimeId;
  String _authToken = '';
  Future<List<dynamic>> _packageTypes;
  bool _isWaiting = false;
  double shippingPrice = 0;
  FocusNode _lengthFocusNode = new FocusNode();
  FocusNode _widthFocusNode = new FocusNode();
  FocusNode _heightFocusNode = new FocusNode();
   Lodash _ = Lodash();

  @override
	void initState() {
		super.initState();
		_fetchSessionAndNavigate();
	}

  _fetchSessionAndNavigate() async {
		_sharedPreferences = await _prefs;
		String authToken = AuthUtils.getToken(_sharedPreferences);
		if(authToken == null) {
			_logout();
		} else {
      _fullNameCustomerController.text = widget.order.receiver['fullName'];
      _addressCustomerController.text = widget.order.receiver['address'];
      totalShippingPrice = double.parse((widget.order.shippingCost ?? 0).toString());
      _phoneNumberCustomerController.text = widget.order.receiver['phoneNumber'];
      _weightController.text = widget.order.orderPackages['weight'].toString();
      packageType = widget.order.orderPackages['packageTypeId'];
      isShopPaid = widget.order.orderPackages['isShopPaid'];
      isClickLeftButton = widget.order.orderPackages['typeOfCalWeight'] == 'actualWeight';
      isClickRightButton = widget.order.orderPackages['typeOfCalWeight'] != 'actualWeight';
      deliveryTimeId = widget.order.delivery['time'];
      _valueOfOrderController.text = widget.order.valueOfOrder.toString();
      var now = new DateTime.now().millisecondsSinceEpoch;  
      
      for(var i = 0; i < widget.order.orderPackages['items'].length; i ++) {
        TextEditingController nameController = new TextEditingController(text: widget.order.orderPackages['items'][i]['name']);
        TextEditingController priceController = new TextEditingController(text: widget.order.orderPackages['items'][i]['price'].toString());
        int amount = int.parse(widget.order.orderPackages['items'][i]['amount'].toString()) - int.parse(widget.order.orderPackages['items'][i]['returnAmount'].toString()) ;
        TextEditingController amountController = new TextEditingController(text: amount.toString());
        codItemControllers.add(nameController);
        codItemControllers.add(amountController);
        codItemControllers.add(priceController);
        var now = new DateTime.now().millisecondsSinceEpoch + i;  
      //   codItems.add(new CodItem(index: codItems.length + 1, nameController: nameController, priceController: priceController, timeStamp: now, amountController: amountController, onDelete: () {_onDelete(now);},));
      // }
        
        codItemControllersCurrent.add(nameController);
        codItemControllersCurrent.add(amountController);
        codItemControllersCurrent.add(priceController);
        int id =codItems.length;
        int id2 = codItemCurrent.length;
        codItemCurrent.add(new CodItem(index: codItemCurrent.length + 1, nameController: nameController, priceController: priceController, timeStamp: now, amountController: amountController, onDelete: () {_onDelete(id2);},));
        codItems.add(new CodItem(index: codItems.length + 1, nameController: nameController, priceController: priceController, timeStamp: now, amountController: amountController, onDelete: () {_onDelete(id);},));
      }   
    }
	}

  _handleChangePackageType(value) {
    setState(() {
      packageType = value;
    });
  }

  _resetItems() {
    codItems.clear();
    for(var i = 0; i < widget.order.orderPackages['items'].length; i ++) {
      TextEditingController nameController = new TextEditingController(text: widget.order.orderPackages['items'][i]['name']);
      TextEditingController priceController = new TextEditingController(text: widget.order.orderPackages['items'][i]['price'].toString());
      TextEditingController amountController = new TextEditingController(text: widget.order.orderPackages['items'][i]['amount'].toString());
      codItemControllers.add(nameController);
      codItemControllers.add(amountController);
      codItemControllers.add(priceController);
      var now = new DateTime.now().millisecondsSinceEpoch + i;  
      codItems.add(new CodItem(index: codItems.length + 1, nameController: nameController, priceController: priceController, timeStamp: now, amountController: amountController, onDelete: () {_onDelete(now);},));
      
    }

    setState(() {
      codItems = codItems;  
    });
  }

  _handleChangeDeliveryTime(value) {
    setState(() {
      deliveryTimeId = value;
    });
  }

  _handleChangeisShopPaid(value) {
    setState(() {
      isShopPaid = value;
    });
  }

  _logout() {
		NetworkUtils.logoutUser(_scaffoldKey.currentContext, _sharedPreferences);
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

    return STATUSES[widget.order.currentStatusValue - 1]['name'];
  }

  replaceTAndZ(String time) => time.replaceAll('T',' ').replaceAll('Z', ' ').substring(0, time.length - 5);

  String convertDateFromString(String strDate){
    DateTime todayDate = DateTime.parse(strDate).toUtc();
    return formatDate(todayDate.add(new Duration(hours: 7)), [dd, '/', mm, '/', yyyy, ', ', hh, ':', nn]);
  }

  _fieldFocusChange(BuildContext context, FocusNode currentFocus,FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);  
  }

  Future _showDialog() async {
    _sharedPreferences = await _prefs;
		String authToken = AuthUtils.getToken(_sharedPreferences);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await showDialog<String>(
        context: context,
        builder: (BuildContext context) => new DialogDeletePackage(
        authToken: authToken, scaffoldKey: _scaffoldKey, 
        orderId: widget.order.id,
        sharedPreferences: _sharedPreferences)
      );
    });
  }

  Future _saveReceiver() async {
    setState(() {
      _isWaiting = true;
    });
    var receiver = {
      'fullName': _fullNameCustomerController.text,
      'phoneNumber': _phoneNumberCustomerController.text,
      'address': _addressCustomerController.text,
      'lat': lat,
      'lng': lng
    };
    _sharedPreferences = await _prefs;
    String authToken = AuthUtils.getToken(_sharedPreferences);

    var responseJson = await NetworkUtils.putWithBody(authToken, '/api/Orders/' + widget.order.id + '/receiver', receiver);
    setState(() {
      _isWaiting = false;
    });
    if(responseJson != null) {
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => CreatePackageDetail(order: ShopOrder.fromJson(responseJson)),)
      );
    }
  }
bool _isValidate(String variable) {
    return variable != null && variable != '' && variable.isNotEmpty;
  }
  int  _valid(){
     
    if(isClickLeftButton && !_isValidate(_weightController.text)){
      return 1;
    }
    else if(!isClickLeftButton)
    {
        if(!_isValidate(lengthController.text))
          return 2;
        else if(!_isValidate(widthController.text))
          return 3;
        else if(!_isValidate(heightController.text))
          return 4;
      }
    else return 0;
    return 0;
  }
  Future _savePackageInformation() async {
    var items;
    int err= _valid();
    String strErr='' ;
    switch (err) {
      case 1:
        strErr ="please_input_weight";
        break;
      case 2:
        strErr = "please_input_length";
        break;
      case 3:
        strErr ="please_input_width";
        break;
      case 4 :
        strErr ="please_input_height";
        break;
      default:
    }
    var itemsArr = _.chunk(array: codItemControllers, size: 3);
    items= itemsArr.map((item) {
       return {
         'name': item[0].text,
          'amount': item[1].text,
           'price': item[2].text
           };
          }).toList();
         bool hasError = false;
          double total = 0;
          double totalCOD = 0;
          items.forEach((item) {
             if(item['price'] == '' || item['amount'] == '' || item['name'] == '') {
               hasError = true;
               strErr = "please_input_item_infomation";
               return;
             } else {          
               total += double.parse(item['price'].toString()) * double.parse(item['amount'].toString());
            }
         });

    if(total >= 100) {
      totalCOD = total * 0.08 / 100;
    }
    if(err!=0 || hasError) {
       Fluttertoast.showToast(
         msg: allTranslations.text(strErr),
         toastLength: Toast.LENGTH_SHORT,
         gravity: ToastGravity.CENTER,
         timeInSecForIos: 1,
         backgroundColor: Colors.red,
          textColor: Colors.white,
         fontSize: 16.0
       );
       
     }else{
    setState(() {
      _isWaiting = true;
    });
    var packageInformation = {
      'typeOfCalWeight': isClickLeftButton == true ? 'actualWeight' : 'convertedFromSize',
      'packageSize': isClickLeftButton == false ? {
        'length': lengthController.text,
        'width': widthController.text,
        'height': heightController.text
      } : {
        'length': widget.order.orderPackages['length'], 
        'width': widget.order.orderPackages['width'],
        'height': widget.order.orderPackages['height']
      },
      'weight': _weightController.text,
      'deliveryTime': deliveryTimeId,
      'caution': packageType,
      'isShopPaid': isShopPaid,
      'items' : items,
    };

    
    _sharedPreferences = await _prefs;
    String authToken = AuthUtils.getToken(_sharedPreferences);

    var responseJson = await NetworkUtils.putWithBody(authToken, '/api/Orders/' + widget.order.id + '/package-information', packageInformation);
    if(mounted)
      setState(() {
        _isWaiting = false;
      });
    if(responseJson != null) {
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => CreatePackageDetail(order: ShopOrder.fromJson(responseJson)),)
      );
    }
     }
  }

   _onDelete(int timestamp) async {
    _sharedPreferences = await _prefs;
		String authToken = AuthUtils.getToken(_sharedPreferences);
    bool isDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => new DialogDeletePackageItem(
      authToken: authToken, scaffoldKey: _scaffoldKey, 
      sharedPreferences: _sharedPreferences)
    );
    if(isDelete) {
      int index = timestamp;

      List<CodItem> temp = new List<CodItem>();

      setState(() {
       codItems.removeAt(index);
      if(codItemControllers.isNotEmpty) {
          codItemControllers.removeRange(index * 3, index * 3 + 3);
      } 
      });
      for(int i =0 ;i<codItems.length;i++){
        temp.add(new CodItem(
          index: i+1,
          nameController: codItems[i].nameController,
          amountController: codItems[i].amountController,
          priceController: codItems[i].priceController,
          timeStamp: codItems[i].timeStamp,
          onDelete: () {_onDelete(i);},
          ));
          print("cod["+i.toString()+"] "+temp[i].index.toString());
      }
      codItems.clear();
     // setState(() {
       codItems = temp; 
       print(codItems.length);
     // });
      // print(codItems.length);
      // for(int i =0;i<codItems.length;i++){
      //   print("item["+i.toString()+"] "+codItems[i].timeStamp.toString());
      // }
      // for (var item in codItems) {
      //   if(item.timeStamp == timestamp) {
      //     index = codItems.indexOf(item);
      //     break;
      //   }
      // }
      // setState(() {
      //   codItems.removeAt(index);
      //   print(index);
      //    if(codItemControllers.isNotEmpty) {
      //       codItemControllers.removeRange(index * 3, index * 3 + 3);
      //   codItems = codItems.map((item) {
      //     int idx = codItems.indexOf(item);
         
      //     if(item.index == idx + 1) {

      //     } else {
      //       item.index = idx + 1;
      //       item.onDelete =(){_onDelete(item.index);};
      //     }
      //     return item;
      //   }).toList();
          
      // }
      // });
    }
  }

  Widget _deliveryRadio(int time) {
    return InkWell(
      onTap: () {
        _handleChangeDeliveryTime(time);
      },
      child: Row(
        children: <Widget>[
          Radio(
            groupValue: deliveryTimeId,
            value: time,
            onChanged: _handleChangeDeliveryTime,
            activeColor: HexColor('#0099CC'),
          ),
          Text(time.toString() + ' ' + allTranslations.text('hours') + ' - ' + (widget.order.zone['${time}h'].toString() + ' ' + allTranslations.text('usd')).toUpperCase(), style: TextStyle(color: HexColor('#455A64')),)
        ],
      ),
    );
  }

  String _calculateWeight() {
    String length = lengthController.text;
    String width = widthController.text;
    String height = heightController.text;
    double weight = (double.parse(length == '' ? '0' : length) * double.parse(width == '' ? '0' : width) * double.parse(height == '' ? '0' : height)) / 5000;
    _weightController.text = weight.toString();
    setState(() {
      _weight = weight;
      totalShippingPrice = weight >= 3 ? (shippingPrice + (weight - 3) * 0.25) : shippingPrice;
    });
    return weight.toString();
  }
  _addItem() async{
    TextEditingController nameController = new TextEditingController();
    TextEditingController priceController = new TextEditingController();
    TextEditingController amountController = new TextEditingController();
    int id= codItems.length;
      codItemControllers.add(nameController);
      codItemControllers.add(amountController);
      codItemControllers.add(priceController);
    var now = new DateTime.now().millisecondsSinceEpoch;  
   
    setState(() { 
      codItems.add( new CodItem(index: id+1, nameController: nameController, timeStamp: now, priceController: priceController, amountController: amountController,onDelete: (){_onDelete(id);},));
    });
  }
  @override
  Widget build(BuildContext context) {
    final dynamic orderPackages = widget.order.orderPackages;
    List<Widget> list = new List<Widget>();
    List<Widget> _returnedList = new List<Widget>();
    for(var i = 0; i < orderPackages['items'].length; i ++) {
      list.add(new PackageOrderItem(item: orderPackages['items'][i]));
      if(orderPackages['items'][i]['returnAmount'] > 0) {
        _returnedList.add(new ReturnedOrderItem(item: orderPackages['items'][i]));
      } 
    }

    double total = 0;
    if(widget.order != null) {
      String extraService = widget.order.orderPackages['extraService'];
      bool isShopPaid = widget.order.orderPackages['isShopPaid'];
      dynamic valueOfOrder = widget.order.valueOfOrder;
      
      dynamic shippingCost = widget.order.shippingCost ?? 0;
      dynamic totalCOD = widget.order.totalCOD ?? 0;
      if(extraService == 'cod') {
        if(isShopPaid) {
          total = (valueOfOrder - (shippingCost + totalCOD)).toDouble();
        } else {
          total = (valueOfOrder - totalCOD + (widget.isFromShipperHistory ? shippingCost : 0)).toDouble();
        }
      } else {
        if(isShopPaid) {
          total -= shippingCost;
        } else {
          total += (widget.isFromShipperHistory ? shippingCost : 0);
        }
      }
    }
    return WillPopScope(
      child: Scaffold(
        key: _scaffoldKey,
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Container(
            decoration: BoxDecoration(
              color: Color.fromRGBO(242, 242, 242, 1),
            ),
            child: Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                  widget.hasNavbar ? GradientAppBar(title: allTranslations.text('detail'), hasBackIcon: true, backtoShopHome: !widget.fromCashedOut && !widget.isFromShipperHistory,) : Container(),
                    Expanded(
                      flex: 1,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Container(
                          padding: widget.hasNavbar ? const EdgeInsets.all(16.0) : EdgeInsets.zero,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              widget.hasNavbar == false ? Container(
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(108, 108, 108, 1)
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 38.0, horizontal: 16.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(35.0),topRight: Radius.circular(35.0))
                                  ),
                                  child: Column(
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Text(allTranslations.text('order_id'), style: TextStyle(color: HexColor('#78909C')),),
                                          SizedBox(width:10.0,),
                                          Text(widget.order.orderId, style: TextStyle(color: HexColor('#0099CC'), fontSize: 14.0, height: 16.0/14.0, fontWeight: FontWeight.bold),)
                                        ],
                                      ),
                                      SizedBox(height: 16.0,),
                                      Image.asset('icons/Line.png', width: double.infinity, fit: BoxFit.fitWidth),
                                      SizedBox(height: 16.0,),
                                      Row(
                                        children: <Widget>[
                                          Expanded(
                                            flex: 1,
                                            child: Text(allTranslations.text('time_create') + ':', style: TextStyle(color: HexColor('#B0BEC5'), fontSize: 14.0),),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Text(widget.order.createdOn, style: TextStyle(color: HexColor('#455A64'), fontSize: 14.0),),
                                          )
                                        ],
                                      ),
                                      SizedBox(height: 10.0,),
                                      Row(
                                        children: <Widget>[
                                          Expanded(
                                            flex: 1,
                                            child: Text(allTranslations.text('pick_up') + ':', style: TextStyle(color: HexColor('#B0BEC5'), fontSize: 14.0),),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Text('05/01/2019 - 16:20', style: TextStyle(color: HexColor('#455A64'), fontSize: 14.0),),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ) : Container(),
                              widget.hasNavbar ? Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(Radius.circular(4.0))
                                ),
                                child: widget.order != null ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(allTranslations.text('order_id'), style: TextStyle(color: HexColor('#78909C'), fontSize: 12.0),),
                                    SizedBox(height: 4.0,),
                                    widget.order.orderId != null ? Text(widget.order.orderId.toUpperCase(), style: TextStyle(color: HexColor('#455A64'), fontSize: 18.0, fontWeight: FontWeight.bold),) : Container(),
                                    SizedBox(height: 16.0,),
                                    Image.asset('icons/Line.png', width: double.infinity, fit: BoxFit.fitWidth),
                                    SizedBox(height: 16.0,),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          flex: 1,
                                          child: Text(allTranslations.text('time_create') + ':', style: TextStyle(color: HexColor('#B0BEC5'), fontSize: 14.0),),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: widget.order.createdOn != null ? Text(convertDateFromString(replaceTAndZ(widget.order.createdOn)), style: TextStyle(color: HexColor('#455A64'), fontSize: 14.0),) : Container(),
                                        )
                                      ],
                                    ),
                                    SizedBox(height: 10.0,),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          flex: 1,
                                          child: Text(allTranslations.text('status') + ':', style: TextStyle(color: HexColor('#B0BEC5'), fontSize: 14.0),),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: InkWell(
                                            onTap: widget.isFromShipperHistory ? null : () {
                                              Navigator.push(context, MaterialPageRoute(
                                                builder: (context) => DeliveryStatus(order: widget.order)
                                              ));
                                            }, 
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                Expanded(
                                                  flex: 1,
                                                  child: RichText(
                                                    text: TextSpan(text: _getStatusName() + ' ('+ convertDateFromString(replaceTAndZ(widget.order.updatedOn)) +')', style: TextStyle(color: HexColor('#0099CC'), fontSize: 14.0),),
                                                    softWrap: true,
                                                  ),
                                                ),
                                                widget.isFromShipperHistory ? IgnorePointer(ignoring: true, child: Opacity(opacity: 0.0,),) : Icon(Icons.chevron_right, color: HexColor('#0099CC'),)
                                              ],
                                            )
                                          )
                                        ),
                                        
                                      ],
                                    ),
                                    widget.order.pendingReason != null && widget.order.pendingReason != '' ? SizedBox(height: 10.0,) : Container(),
                                    widget.order.pendingReason != null && widget.order.pendingReason != '' ?  Row(
                                      children: <Widget>[
                                        Expanded(
                                          flex: 1,
                                          child: Text(allTranslations.text('pending_reason') + ':', style: TextStyle(color: HexColor('#B0BEC5'), fontSize: 14.0),),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: InkWell(
                                            onTap: widget.isFromShipperHistory ? null : () {
                                              Navigator.push(context, MaterialPageRoute(
                                                builder: (context) => DeliveryStatus(order: widget.order)
                                              ));
                                            }, 
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                Expanded(
                                                  flex: 1,
                                                  child: RichText(
                                                    text: TextSpan(text: widget.order.pendingReason, style: TextStyle(color: HexColor('#0099CC'), fontSize: 14.0),),
                                                    softWrap: true,
                                                  ),
                                                ),
                                              ],
                                            )
                                          )
                                        ),
                                        
                                      ],
                                    ) : Container(),
                                    widget.order.failedReasonFull != null && widget.order.failedReasonFull != '' ? SizedBox(height: 10.0,) : Container(),
                                    widget.order.failedReasonFull != null && widget.order.failedReasonFull != '' ?  Row(
                                      children: <Widget>[
                                        Expanded(
                                          flex: 1,
                                          child: Text(allTranslations.text('fail_reason') + ':', style: TextStyle(color: HexColor('#B0BEC5'), fontSize: 14.0),),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: InkWell(
                                            onTap: widget.isFromShipperHistory ? null : () {
                                              Navigator.push(context, MaterialPageRoute(
                                                builder: (context) => DeliveryStatus(order: widget.order)
                                              ));
                                            }, 
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                Expanded(
                                                  flex: 1,
                                                  child: RichText(
                                                    text: TextSpan(text: widget.order.failedReasonFull, style: TextStyle(color: HexColor('#0099CC'), fontSize: 14.0),),
                                                    softWrap: true,
                                                  ),
                                                ),
                                              ],
                                            )
                                          )
                                        ),
                                        
                                      ],
                                    ) : Container(),
                                    widget.order.returnedReason != null && widget.order.returnedReason != '' ? SizedBox(height: 10.0,) : Container(),
                                    widget.order.returnedReason != null && widget.order.returnedReason != '' ?  Row(
                                      children: <Widget>[
                                        Expanded(
                                          flex: 1,
                                          child: Text(allTranslations.text('returned_reason') + ':', style: TextStyle(color: HexColor('#B0BEC5'), fontSize: 14.0),),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: InkWell(
                                            onTap: widget.isFromShipperHistory ? null : () {
                                              Navigator.push(context, MaterialPageRoute(
                                                builder: (context) => DeliveryStatus(order: widget.order)
                                              ));
                                            }, 
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                Expanded(
                                                  flex: 1,
                                                  child: RichText(
                                                    text: TextSpan(text: widget.order.returnedReason, style: TextStyle(color: HexColor('#0099CC'), fontSize: 14.0),),
                                                    softWrap: true,
                                                  ),
                                                ),
                                              ],
                                            )
                                          )
                                        ),
                                        
                                      ],
                                    ) : Container(),
                                  ],
                                ) : Container()
                              ) : Container(),
                              SizedBox(height: widget.hasNavbar ? 10.0 : 4.0,),
                              widget.order.shipper != null ? new ShipperInformation(shipper: widget.order.shipper) : Container(),
                              widget.order.shipper != null ? SizedBox(height: widget.hasNavbar ? 10.0 : 4.0,) : SizedBox(),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(Radius.circular(4.0))
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(allTranslations.text('receiver').toUpperCase(), style: TextStyle(color: HexColor('#455A64'), fontSize: 18.0, fontWeight: FontWeight.bold),),
                                        widget.order.currentStatusValue < 4 ? !_isClickEditReceiver ? InkWell(
                                          onTap: () {
                                            setState(() {
                                              _isClickEditReceiver = true;
                                            });
                                          },
                                          child: Icon(
                                            Icons.edit,
                                            color: HexColor('#0099CC'),
                                          ),
                                        ) : Row(
                                          children: <Widget>[
                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  _isClickEditReceiver = false;
                                                });
                                              },
                                              child: Text(allTranslations.text('cancel').toUpperCase(), style: TextStyle(color: HexColor('#B0BEC5'), fontWeight: FontWeight.bold),),
                                            ),
                                            SizedBox(width: 20.0,),
                                            InkWell(
                                              onTap: _saveReceiver,
                                              child: Text(allTranslations.text('save').toUpperCase(), style: TextStyle(color: HexColor('#0099CC'), fontWeight: FontWeight.bold),),
                                            )
                                          ],
                                        ) : IgnorePointer(
                                          ignoring: true,
                                          child: Opacity(opacity: 0.0,),
                                        )
                                      ],
                                    ),
                                    SizedBox(height: 16.0,),
                                    _isClickEditReceiver ? Column(
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Theme(
                                            data: new ThemeData(
                                  hintColor: HexColor('#DFE4EA')
                                            ),
                                            child: TextFormField(
                                              decoration: InputDecoration(
                                                hintText: allTranslations.text('full_name'),
                                                hintStyle: TextStyle(color: HexColor('#90A4AE'), fontSize: 14),
                                                suffixIcon: Image.asset('icons/contact.png')
                                              ),
                                              textCapitalization: TextCapitalization.words,
                                              textInputAction: TextInputAction.next,
                                              focusNode: _fullNameFocusNode,
                                              onFieldSubmitted: (value) {
                                                _fieldFocusChange(context, _fullNameFocusNode, _phoneNumberFocusNode);
                                              },
                                              controller: _fullNameCustomerController,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 5.0,),
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Theme(
                                            data: new ThemeData(
                                              hintColor: HexColor('#DFE4EA')
                                            ),
                                            child: TextFormField(
                                              decoration: InputDecoration(
                                                hintText: allTranslations.text('form_phone_number'),
                                                hintStyle: TextStyle(color: HexColor('#90A4AE'), fontSize: 14),
                                              ),
                                              keyboardType: TextInputType.number,
                                              textInputAction: TextInputAction.next,
                                              focusNode: _phoneNumberFocusNode,
                                              onFieldSubmitted: (value) async {
                                                _phoneNumberFocusNode.unfocus();
                                                var result = await Navigator.of(context).push(
                                                  new PageRouteBuilder(
                                                    pageBuilder: (BuildContext context, _, __) {
                                                      return ChooseOnMap(isCreatePackage: true);
                                                    },
                                                  )
                                                );

                                                if(result != null ){
                                                  _addressCustomerController.text = result['chosenAddress'];
                                                  setState(() {
                                                    selectedZone = result['selectedZone'];
                                                    lat = result['lat'];
                                                    lng = result['lng'];
                                                  });
                                                }
                                              },
                                              controller: _phoneNumberCustomerController,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 5.0,),
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Theme(
                                            data: new ThemeData(
                                              hintColor: HexColor('#DFE4EA')
                                            ),
                                            child: TextField(
                                              decoration: InputDecoration(
                                                hintText: allTranslations.text('address'),
                                                hintStyle: TextStyle(color: HexColor('#90A4AE'), fontSize: 14),
                                                suffixIcon: Image.asset('icons/near-me.png')
                                              ),
                                              controller: _addressCustomerController,
                                              onTap: () async {
                                                var result = await Navigator.of(context).push(
                                                  new PageRouteBuilder(
                                                    pageBuilder: (BuildContext context, _, __) {
                                                      return ChooseOnMap(isCreatePackage: true);
                                                    },
                                                  )
                                                );

                                                if(result != null) {
                                                  _addressCustomerController.text = result['chosenAddress'];
                                                  setState(() {
                                                    selectedZone = result['selectedZone'];
                                                    lat = result['lat'];
                                                    lng = result['lng'];
                                                  });
                                                }

                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ) : Column(
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              flex: 1,
                                              child: Text(allTranslations.text('name') + ':', style: TextStyle(color: HexColor('#B0BEC5'), fontSize: 14.0),),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: widget.order.receiver != null ? Text(widget.order.receiver['fullName'], style: TextStyle(color: HexColor('#455A64'), fontSize: 14.0),) : Container(),
                                            )
                                          ],
                                        ),
                                        SizedBox(height: 10.0,),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Expanded(
                                              flex: 1,
                                              child: Text(allTranslations.text('address') + ':', style: TextStyle(color: HexColor('#B0BEC5'), fontSize: 14.0),),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: widget.order.receiver != null ? Text(widget.order.receiver['address'], style: TextStyle(color: HexColor('#455A64'), fontSize: 14.0),) : Container(),
                                            )
                                          ],
                                        ),
                                        SizedBox(height: 10.0,),
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              flex: 1,
                                              child: Text(allTranslations.text('phone') + ':', style: TextStyle(color: HexColor('#B0BEC5'), fontSize: 14.0),),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: widget.order.receiver != null ? Text(widget.order.receiver['phoneNumber'], style: TextStyle(color: HexColor('#455A64'), fontSize: 14.0),) : Container(),
                                            )
                                          ],
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(height: widget.hasNavbar ? 10.0 : 4.0,),
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(Radius.circular(4.0))
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(allTranslations.text('package').toUpperCase(), style: TextStyle(color: HexColor('#455A64'), fontSize: 18.0, fontWeight: FontWeight.bold),),
                                          widget.order.currentStatusValue < 4 ? !_isClickEditPackage ? InkWell(
                                            onTap: () {
                                              setState(() {
                                                _isClickEditPackage = true;
                                                lengthController.text = widget.order.orderPackages["packageSize"]['length'].toString();
                                                widthController.text  = widget.order.orderPackages["packageSize"]['width'].toString();
                                                heightController.text =widget.order.orderPackages["packageSize"]['height'].toString();
                                              });
                                            },
                                            child: Icon(
                                              Icons.edit,
                                              color: HexColor('#0099CC'),
                                            ),
                                          ) : Row(
                                            children: <Widget>[
                                              InkWell(
                                                onTap: () {
                                                  codItems.clear();
                                                  codItemControllers.clear();
                                                  setState(() {
                                                    _isClickEditPackage = false;
                                                    
                                                    
                                                    codItemCurrent.forEach((item){
                                                      codItems.add(item);
                                                    });
                                                    
                                                    codItemControllersCurrent.forEach((item){
                                                      codItemControllers.add(item);
                                                    });
                                                  });

                                                  _resetItems();
                                                },
                                                child: Text(allTranslations.text('cancel').toUpperCase(), style: TextStyle(color: HexColor('#B0BEC5'), fontWeight: FontWeight.bold),),
                                              ),
                                              SizedBox(width: 20.0,),
                                              InkWell(
                                                onTap: _savePackageInformation,
                                                child: Text(allTranslations.text('save').toUpperCase(), style: TextStyle(color: HexColor('#0099CC'), fontWeight: FontWeight.bold),),
                                              )
                                            ],
                                          ) : IgnorePointer(
                                            ignoring: true,
                                            child: Opacity(opacity: 0.0,),
                                          )
                                        ],
                                      ),
                                    ),
                                    !_isClickEditPackage ? Padding(
                                      padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 16.0),
                                      child: Column( 
                                        children: <Widget>[
                                          widget.order.orderPackages['typeOfCalWeight'] != 'actualWeight' ? Row(
                                            children: <Widget>[
                                              Expanded(
                                                flex: 2,
                                                child: Text(allTranslations.text('length') + ':', style: TextStyle(color: HexColor('#B0BEC5'), fontSize: 14.0),),
                                              ),
                                              Expanded(
                                                flex: 5,
                                                child: widget.order.orderPackages != null ?Text(widget.order.orderPackages['packageSize']['length'].toString() + ' (cm)', style: TextStyle(color: HexColor('#455A64'), fontSize: 14.0),) : Container(),
                                              )
                                            ],
                                          ) : Opacity(opacity: 0.0,),
                                          widget.order.orderPackages['typeOfCalWeight'] != 'actualWeight' ? SizedBox(height: 10.0,) : Opacity(opacity: 0.0,),
                                          widget.order.orderPackages['typeOfCalWeight'] != 'actualWeight' ? Row(
                                            children: <Widget>[
                                              Expanded(
                                                flex: 2,
                                                child: Text(allTranslations.text('width') + ':', style: TextStyle(color: HexColor('#B0BEC5'), fontSize: 14.0),),
                                              ),
                                              Expanded(
                                                flex: 5,
                                                child: widget.order.orderPackages != null ?Text(widget.order.orderPackages['packageSize']['width'].toString() + ' (cm)', style: TextStyle(color: HexColor('#455A64'), fontSize: 14.0),) : Container(),
                                              )
                                            ],
                                          ) : Opacity(opacity: 0.0,),
                                          widget.order.orderPackages['typeOfCalWeight'] != 'actualWeight' ? SizedBox(height: 10.0,) : Opacity(opacity: 0.0,),
                                          widget.order.orderPackages['typeOfCalWeight'] != 'actualWeight' ?  Row(
                                            children: <Widget>[
                                              Expanded(
                                                flex: 2,
                                                child: Text(allTranslations.text('height') + ':', style: TextStyle(color: HexColor('#B0BEC5'), fontSize: 14.0),),
                                              ),
                                              Expanded(
                                                flex: 5,
                                                child: widget.order.orderPackages != null ?Text(widget.order.orderPackages['packageSize']['height'].toString() + ' (cm)', style: TextStyle(color: HexColor('#455A64'), fontSize: 14.0),) : Container(),
                                              )
                                            ],
                                          ) : Opacity(opacity: 0.0,),
                                          widget.order.orderPackages['packageSize']['height'] != '0' ? SizedBox(height: 10.0,)  : Opacity(opacity: 0.0,),
                                          Row(
                                            children: <Widget>[
                                              Expanded(
                                                flex: 2,
                                                child: Text(allTranslations.text('weight') + ':', style: TextStyle(color: HexColor('#B0BEC5'), fontSize: 14.0),),
                                              ),
                                              Expanded(
                                                flex: 5,
                                                child: widget.order.orderPackages != null ?Text(widget.order.orderPackages['weight'].toString() + ' (' + allTranslations.text('kg') + ')', style: TextStyle(color: HexColor('#455A64'), fontSize: 14.0),) : Container(),
                                              )
                                            ],
                                          ),
                                          SizedBox(height: 10.0,),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Expanded(
                                                flex: 2,
                                                child: Text(allTranslations.text('delivery_time') + ':', style: TextStyle(color: HexColor('#B0BEC5'), fontSize: 14.0),),
                                              ),
                                              Expanded(
                                                flex: 5,
                                                child: widget.order.orderPackages != null ? Text(widget.order.delivery['time'].toString() +  ' ' +allTranslations.text('hours'), style: TextStyle(color: HexColor('#455A64'), fontSize: 14.0),) : Container(),
                                              )
                                            ],
                                          ),
                                          SizedBox(height: 10.0,),
                                          Row(
                                            children: <Widget>[
                                              Expanded(
                                                flex: 2,
                                                child: Text(allTranslations.text('caution') + ':', style: TextStyle(color: HexColor('#B0BEC5'), fontSize: 14.0),),
                                              ),
                                              Expanded(
                                                flex: 5,
                                                child: widget.order.orderPackages != null && widget.order.orderPackages['packageType'] != null ? Text(allTranslations.text(widget.order.orderPackages['packageType']['name']), style: TextStyle(color: HexColor('#455A64'), fontSize: 14.0),) : Container(),
                                              )
                                            ],
                                          ),
                                          SizedBox(height: 10.0,),
                                          Row(
                                            children: <Widget>[
                                              Expanded(
                                                flex: 2,
                                                child: Text(allTranslations.text('who_pays') + ':', style: TextStyle(color: HexColor('#B0BEC5'), fontSize: 14.0),),
                                              ),
                                              Expanded(
                                                flex: 5,
                                                child: widget.order.orderPackages != null ? Text(widget.order.orderPackages['isShopPaid'] == true ? 'Shop' : 'Customer', style: TextStyle(color: HexColor('#455A64'), fontSize: 14.0),) : Container(),
                                              )
                                            ],
                                          ),
                                          SizedBox(height: 10.0,),
                                          Row(
                                            children: <Widget>[
                                              Expanded(
                                                flex: 2,
                                                child: Text(allTranslations.text('total_cod').toUpperCase() + ':', style: TextStyle(color: HexColor('#B0BEC5'), fontSize: 14.0),),
                                              ),
                                              Expanded(
                                                flex: 5,
                                                child: Text((widget.order.orderPackages['extraService'] == 'cod' ? widget.order.valueOfOrder : 0).toStringAsFixed(2) + ' (' +allTranslations.text('usd').toUpperCase() + ')', style: TextStyle(color: HexColor('#455A64'), fontSize: 14.0),),
                                              )
                                            ],
                                          ),
                                          SizedBox(height: 10.0,),
                                          Row(
                                            children: <Widget>[
                                              Expanded(
                                                flex: 2,
                                                child: Text(allTranslations.text('cod_fee') + ':', style: TextStyle(color: HexColor('#B0BEC5'), fontSize: 14.0),),
                                              ),
                                              Expanded(
                                                flex: 5,
                                                child: Text(widget.order.totalCOD.toStringAsFixed(2) + ' (' +allTranslations.text('usd').toUpperCase() + ')', style: TextStyle(color: HexColor('#455A64'), fontSize: 14.0),),
                                              )
                                            ],
                                          ),
                                          SizedBox(height: 10.0,),
                                          Row(
                                            children: <Widget>[
                                              Expanded(
                                                flex: 2,
                                                child: Text(allTranslations.text('package_cost') + ':', style: TextStyle(color: HexColor('#B0BEC5'), fontSize: 14.0),),
                                              ),
                                              Expanded(
                                                flex: 5,
                                                child: Text((widget.order.shippingCost ?? 0).toStringAsFixed(2) + ' (' +allTranslations.text('usd').toUpperCase() + ')', style: TextStyle(color: HexColor('#455A64'), fontSize: 14.0),),
                                              )
                                            ],
                                          ),
                                          widget.order.shopNotes != '' ? SizedBox(height: 10.0,) : Container(),
                                          widget.order.shopNotes != '' ? Row(
                                            children: <Widget>[
                                              Expanded(
                                                flex: 2,
                                                child: Text(allTranslations.text('shop_notes') + ':', style: TextStyle(color: HexColor('#B0BEC5'), fontSize: 14.0),),
                                              ),
                                              Expanded(
                                                flex: 5,
                                                child: Text(widget.order.shopNotes.toString(), style: TextStyle(color: HexColor('#455A64'), fontSize: 14.0),),
                                              )
                                            ],
                                          ) : Opacity(opacity: 0.0,),
                                          SizedBox(height: 10.0,),
                                          Row(
                                            children: <Widget>[
                                              Expanded(
                                                flex: 2,
                                                child: Text(allTranslations.text('order_type') + ':', style: TextStyle(color: HexColor('#B0BEC5'), fontSize: 14.0),),
                                              ),
                                              Expanded(
                                                flex: 5,
                                                child: Text(widget.order.orderPackages != null ? widget.order.orderPackages['extraService'].toUpperCase() : '', style: TextStyle(color: HexColor('#455A64'), fontSize: 14.0)),
                                              )
                                            ],
                                          ),
                                          SizedBox(height: 10.0,),
                                          Row(
                                            children: <Widget>[
                                              Expanded(
                                                flex: 2,
                                                child: Text(allTranslations.text('total') + ':', style: TextStyle(color: HexColor('#B0BEC5'), fontSize: 14.0),),
                                              ),
                                              Expanded(
                                                flex: 5,
                                                child: Text(total.toStringAsFixed(2) + ' (' +allTranslations.text('usd').toUpperCase() + ')', style: TextStyle(color: HexColor('#455A64'), fontSize: 14.0)),
                                              )
                                            ],
                                          ),
                                        ],
                                      )
                                    ) : Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                          child: Container(
                                            child: IntrinsicHeight(
                                              child: Row(
                                              children: <Widget>[
                                                new CreatePackageButton(title: allTranslations.text('actual_weight'), isClicked: isClickLeftButton, onTap:  () {
                                                  setState(() {
                                                    isClickLeftButton = true;
                                                    isClickRightButton = false;
                                                  });
                                                },),
                                                SizedBox(width: 11,),
                                                new CreatePackageButton(title: allTranslations.text('weight_converted_from_size'), isClicked: isClickRightButton, onTap:  () {
                                                  setState(() {
                                                    isClickRightButton = true;
                                                    isClickLeftButton = false;
                                                  });
                                                },),
                                              ],
                                            ),
                                            )
                                          ),
                                        ),
                                        SizedBox(height: 16.0,),
                                        isClickRightButton == true ? Container(
                                          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 10),
                                          color: Colors.white,
                                          child: Form(
                                            onChanged: () {
                                              _calculateWeight();
                                            },
                                            child: Column(
                                              children: <Widget>[
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: <Widget>[
                                                          Text(allTranslations.text('length') + ' (cm)', style: TextStyle(color: HexColor('#B0BEC5')),),
                                                          TextFormField(
                                                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                                                            controller: lengthController,
                                                            textInputAction: TextInputAction.next,
                                                            focusNode: _lengthFocusNode,
                                                            onFieldSubmitted: (value) {
                                                              widthController.text = '';
                                                              _fieldFocusChange(context, _lengthFocusNode, _widthFocusNode);
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(width: 8,),
                                                    Expanded(
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: <Widget>[
                                                          Text(allTranslations.text('width') + ' (cm)', style: TextStyle(color: HexColor('#B0BEC5')),),
                                                          TextFormField(
                                                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                                                            controller: widthController,
                                                            textInputAction: TextInputAction.next,
                                                            focusNode: _widthFocusNode,
                                                            onFieldSubmitted: (value) {
                                                              heightController.text = '';
                                                              _fieldFocusChange(context, _widthFocusNode, _heightFocusNode);
                                                            },
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(width: 8,),
                                                    Expanded(
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: <Widget>[
                                                          Text(allTranslations.text('height') + ' (cm)', style: TextStyle(color: HexColor('#B0BEC5')),),
                                                          TextFormField(
                                                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                                                            controller: heightController,
                                                            textInputAction: TextInputAction.done,
                                                            focusNode: _heightFocusNode,
                                                            onFieldSubmitted: (value) {
                                                              _heightFocusNode.unfocus();
                                                            },
                                                          )
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                SizedBox(height: 16,),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Color.fromRGBO(234, 249, 254, 1),
                                                    borderRadius: BorderRadius.all(Radius.circular(4)),
                                                  ),
                                                  padding: const EdgeInsets.all(10),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: <Widget>[
                                                      Text(_calculateWeight() + '(' +allTranslations.text('kg') + ')', style: TextStyle(color: HexColor('#455A64'), fontSize: 14),),
                                                      Text(totalShippingPrice.toStringAsFixed(2) + ' ' + allTranslations.text('usd').toUpperCase(), style: TextStyle(color: HexColor('#FF9933'), fontSize: 14, fontWeight: FontWeight.bold),)
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ) : IgnorePointer(
                                          ignoring: true,
                                          child: Opacity(
                                            opacity: 0.0,
                                          ),
                                        ),
                                        isClickRightButton == false ? Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                          child: Text(allTranslations.text('weight') + ' (kg)', style: TextStyle(color: HexColor('#B0BEC5')),),
                                        ) : Container(),
                                        isClickRightButton == false ? Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                          child: TextField(
                                            decoration: InputDecoration(
                                              suffix: Container(
                                                width: 100.0,
                                                height: 36.0,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.all(Radius.circular(4.0)),
                                                  gradient: LinearGradient(
                                                    stops: [0.0, 1.3214],
                                                    colors: [HexColor('#00C9E8'), HexColor('#0099CC')]
                                                  )
                                                ),
                                                child: Center(
                                                  child: Text(totalShippingPrice.toStringAsFixed(2) + ' ' + allTranslations.text('usd').toUpperCase(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                                ),
                                              )
                                            ),
                                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                                            onChanged: (String value) {
                                              setState(() {
                                                totalShippingPrice = double.parse(value) >= 3 ? (shippingPrice + (double.parse(value) - 3) * 0.25) : shippingPrice;
                                                _weight = double.parse(value);
                                              });
                                            },
                                            controller: _weightController,
                                          ),
                                        ) : Container(),
                                        SizedBox(height: 16.0,),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                          child: Text(allTranslations.text('delivery_time'), style: TextStyle(color: HexColor('#455A64'), fontWeight: FontWeight.bold),),
                                        ),
                                        Column(children: <Widget>[
                                          _deliveryRadio(2),
                                          _deliveryRadio(4),
                                          _deliveryRadio(8),
                                          _deliveryRadio(24),
                                        ],),
                                        SizedBox(height: 16.0,),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                          child: Text(allTranslations.text('caution'), style: TextStyle(color: HexColor('#455A64'), fontWeight: FontWeight.bold),),
                                        ),
                                        FutureBuilder<List<dynamic>>(
                                          future: fetchPackageTypes(),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasError) print(snapshot.error);
                                            List<Widget> _list = new List<Widget>();
                                            if(snapshot.hasData) {
                                              for(var i = 0; i < snapshot.data.length; i++) {
                                                PackageType _packageType = snapshot.data[i];
                                                _list.add(InkWell(
                                                  onTap: () {
                                                    _handleChangePackageType(_packageType.id);
                                                  },
                                                  child: Row(
                                                    children: <Widget>[
                                                      Radio(
                                                        groupValue: packageType,
                                                        value: _packageType.id,
                                                        onChanged: _handleChangePackageType,
                                                        activeColor: HexColor('#0099CC'),
                                                      ),
                                                      Text(allTranslations.text(_packageType.name), style: TextStyle(color: HexColor('#455A64')),)
                                                    ],
                                                  )
                                                ));
                                              }
                                            }
                                            return snapshot.hasData
                                                ? Column(
                                                  children: _list,
                                                )
                                                : Center(child: CircularProgressIndicator());
                                          },
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                          child: Text(allTranslations.text('who_pays'), style: TextStyle(color: HexColor('#455A64'), fontWeight: FontWeight.bold),),
                                        ),
                                        SizedBox(height: 10.0,),
                                        Column(children: <Widget>[
                                          InkWell(
                                            onTap: () {
                                              _handleChangeisShopPaid(true);
                                            },
                                            child: Row(
                                              children: <Widget>[
                                                Radio(
                                                  groupValue: isShopPaid,
                                                  value: true,
                                                  onChanged: _handleChangeisShopPaid,
                                                  activeColor: HexColor('#0099CC'),
                                                ),
                                                Text(allTranslations.text('shop'), style: TextStyle(color: HexColor('#455A64')),)
                                              ],
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              _handleChangeisShopPaid(false);
                                            },
                                            child: Row(
                                              children: <Widget>[
                                                Radio(
                                                  groupValue: isShopPaid,
                                                  value: false,
                                                  onChanged: _handleChangeisShopPaid,
                                                  activeColor: HexColor('#0099CC'),
                                                ),
                                                Text(allTranslations.text('customer'), style: TextStyle(color: HexColor('#455A64')),)
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10.0,),
                                       widget.order.orderPackages['extraService'] == 'express' ?
                                      Column(children: <Widget>[
                                        Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                        child: Text(allTranslations.text('my_package_cost'), style: TextStyle(color: HexColor('#B0BEC5')),),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                        child: TextField(
                                          
                                          decoration: InputDecoration(
                                            
                                          ),
                                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                                          onChanged: (String value) {
                                            // setState(() {
                                            //   totalShippingPrice = double.parse(value) >= 3 ? (shippingPrice + (double.parse(value) - 3) * 0.25) : shippingPrice;
                                            //   _weight = double.parse(value);
                                            // });
                                          },
                                          controller: _valueOfOrderController,
                                        ),
                                      ),
                                      ],
                                      ):IgnorePointer(ignoring: true, child: Opacity(opacity: 0.0,),),
                                      SizedBox(height: 16.0,)
                                    ],
                                      
                                    )
                                  ],
                                ),
                              ),
                              widget.order.orderPackages['extraService'] == 'express' ? IgnorePointer(ignoring: true, child: Opacity(opacity: 0.0,),) : SizedBox(height: widget.hasNavbar ? 10.0 : 4.0,),
                              widget.order.orderPackages['extraService'] == 'express' ? IgnorePointer(ignoring: true, child: Opacity(opacity: 0.0,),) : Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(Radius.circular(4.0))
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(allTranslations.text('items_in_package').toUpperCase(), style: TextStyle(color: HexColor('#455A64'), fontSize: 18.0, fontWeight: FontWeight.bold),),
                                      ],
                                    ),
                                    SizedBox(height: 16.0,),
                                    Column(
                                      children:[
                                        Column(
                                          children: !_isClickEditPackage ? list : codItems
                                        ),
                                        _isClickEditPackage ? InkWell(
                                          onTap: _addItem,
                                          child: Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                color: HexColor('#DFE4EA'),
                                              ),
                                              borderRadius: BorderRadius.all(Radius.circular(5))
                                            ),
                                            child: Center(
                                              child: Text('+ ' + allTranslations.text('add_more_items'), textAlign: TextAlign.center, style: TextStyle(color:HexColor('#B0BEC5')),),
                                            ),
                                          ),
                                        ): Opacity(opacity: 0.0,),
                                        SizedBox(height: 30.0,),
                                      ] ,
                                    )
                                  ]
                                )
                              ),
                              SizedBox(height: widget.hasNavbar ? 10.0 : 4.0,),
                              _returnedList.length > 0 ? Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(Radius.circular(4.0))
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(allTranslations.text('returned_items_in_package').toUpperCase(), style: TextStyle(color: Colors.red, fontSize: 18.0, fontWeight: FontWeight.bold),),
                                      ],
                                    ),
                                    SizedBox(height: 16.0,),
                                    Column(
                                      children:[
                                        Column(
                                          children: _returnedList
                                        ),
                                        SizedBox(height: 30.0,),
                                      ] ,
                                    )
                                  ]
                                )
                              ) : Container(),
                              widget.hasNavbar ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: <Widget>[
                                widget.order.currentStatusValue > 4 ? IgnorePointer(ignoring: true, child: Opacity(opacity: 0.0,),) : InkWell(
                                  onTap: _showDialog,
                                  child: Center(
                                    child: Column(
                                      children: <Widget>[
                                        Text(allTranslations.text('delete_packages'), style: TextStyle(color: HexColor('#FF3333')),),
                                        SizedBox(height: 6.0,),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            )
                          )
                        ],
                      ),
                    ) : IgnorePointer(
                      ignoring: true,
                      child: Opacity(opacity: 0.0,),
                    )
                            ],
                          ),
                        )
                      ),
                    ),
                    
                  ]
                ),
                _isWaiting ? Center(
                  child: CircularProgressIndicator(),
                ) : IgnorePointer(
                  ignoring: true,
                  child: Opacity(opacity: 0.0,),
                )
              ],
            )
          ),
        )
      ),
      onWillPop: () async {
        print(widget.isCreatePackage);
        //widget.isFromShipperHistory ? Navigator.pop(context) : Navigator.pushReplacementNamed(context, '/main-shop');
        if(!widget.isFromShipperHistory || widget.isCreatePackage) {
          Navigator.pushReplacementNamed(context, '/main-shop');
        } else {
          return true;
        }
      },
    );
  }
}

class ShipperInformation extends StatelessWidget {
  const ShipperInformation({
    Key key,
    this.shipper
  }) : super(key: key);

  final dynamic shipper;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(4.0))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(allTranslations.text('shipper').toUpperCase(), style: TextStyle(color: HexColor('#455A64'), fontSize: 18.0, fontWeight: FontWeight.bold),),
                  Text(' (' +allTranslations.text('delivering') + ')', style: TextStyle(color: HexColor('#B0BEC5')),)
                ],
              ),
            ],
          ),
          SizedBox(height: 16.0,),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  child:CachedNetworkImage(
                      imageUrl: shipper['avatar'] != null && shipper['avatar'] != '' ? "https://camships.com:3000/api/attachments/compressed/download/${shipper['avatar']}" : "https://camships.com:3000/api/attachments/compressed/download/logo.png",
                      placeholder: (context, url) => new Center(child: CircularProgressIndicator(),),
                      errorWidget: (context, url, error) => new Icon(Icons.error),
                  ),
                ),
              ),
              SizedBox(width: 20.0,),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 5.0,),
                    Text(shipper['fullName'], style: TextStyle(color: HexColor('#455A64'), fontWeight: FontWeight.bold, fontSize: 14.0),),
                    SizedBox(height: 5.0,),
                    Row(
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: Text(allTranslations.text('phone') + ':', style: TextStyle(color: HexColor('#B0BEC5'), fontSize: 14.0),),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(shipper['phoneNumber'], style: TextStyle(color: HexColor('#455A64'), fontSize: 14.0),),
                        )
                      ],
                    ),
                    SizedBox(height: 5.0,),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: Text(allTranslations.text('address') + ':', style: TextStyle(color: HexColor('#B0BEC5'), fontSize: 14.0),),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(shipper['address'], style: TextStyle(color: HexColor('#455A64'), fontSize: 14.0),),
                        )
                      ],
                    ),
                    
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class DialogDeletePackage extends StatelessWidget {
  const DialogDeletePackage({
    Key key,
    @required this.orderId,
    @required this.authToken,
    @required this.scaffoldKey,
    @required this.sharedPreferences
  }) : super(key: key);

  final String authToken;
  final String orderId;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final SharedPreferences sharedPreferences;


  Future _deletePackage(BuildContext context) async {
    var responseJson = await NetworkUtils.post(authToken, '/api/Orders/' + orderId + '/cancel');
    if(responseJson != null) {
      Navigator.pop(context);
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => CreatePackageDetail(order: ShopOrder.fromJson(responseJson)),)
      );
    }
  }

  Future _cancel(BuildContext context) async {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
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
              Image.asset('icons/remove-address.png'),
              SizedBox(width: 16),
              Text(allTranslations.text('title_alert_delete_package'),
              style: TextStyle(
                color: Color.fromRGBO(20, 156, 206, 1),
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 0.5
              )),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(allTranslations.text('confirm_alert_delete_package'), style: TextStyle(
                  color: HexColor('#455A64'),
                  fontSize: 12,
                  height: 16/14.0
                )),
                SizedBox(height: 20.0),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: () {_cancel(context);},
                        child: new Container(
                          padding: const EdgeInsets.symmetric(vertical: 12.5),
                          decoration: new BoxDecoration(
                            color: HexColor('#FFFFFF'),
                            border: Border.all(color: HexColor('#DFE4EA')),
                            borderRadius: BorderRadius.all(Radius.circular(4.0))
                          ),
                          child: new Center(child: new Text(allTranslations.text('cancel').toUpperCase(), style: new TextStyle(fontSize: 14.0, color: HexColor('#78909C'), fontWeight: FontWeight.bold),),),
                        ),
                      ),
                    ),
                    SizedBox(width: 11.0,),
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: () {_deletePackage(context);},
                        child: new Container(
                          padding: const EdgeInsets.symmetric(vertical: 12.5),
                          decoration: new BoxDecoration(
                            color: HexColor('#FF3333'),
                            borderRadius: BorderRadius.all(Radius.circular(4.0))
                          ),
                          child: new Center(child: new Text(allTranslations.text('delete').toUpperCase(), style: new TextStyle(fontSize: 14.0, color: Colors.white, fontWeight: FontWeight.bold),),),
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DialogDeletePackageItem extends StatelessWidget {
  const DialogDeletePackageItem({
    Key key,
    @required this.authToken,
    @required this.scaffoldKey,
    @required this.sharedPreferences
  }) : super(key: key);

  final String authToken;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final SharedPreferences sharedPreferences;


  Future _deletePackage(BuildContext context) async {
    Navigator.pop(context, true);
  }

  Future _cancel(BuildContext context) async {
    Navigator.pop(context, false);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
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
              Image.asset('icons/remove-address.png'),
              SizedBox(width: 16),
              Flexible(
                child:
              Text(allTranslations.text('title_alert_delete_package_item'),
            
              style: TextStyle(
                color: Color.fromRGBO(20, 156, 206, 1),
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 0.5
              )),)
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(allTranslations.text('confirm_alert_delete_package_item'), style: TextStyle(
                  color: HexColor('#455A64'),
                  fontSize: 12,
                  height: 16/14.0
                )),
                SizedBox(height: 20.0),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: () {_cancel(context);},
                        child: new Container(
                          padding: const EdgeInsets.symmetric(vertical: 12.5),
                          decoration: new BoxDecoration(
                            color: HexColor('#FFFFFF'),
                            border: Border.all(color: HexColor('#DFE4EA')),
                            borderRadius: BorderRadius.all(Radius.circular(4.0))
                          ),
                          child: new Center(child: new Text(allTranslations.text('cancel').toUpperCase(), style: new TextStyle(fontSize: 14.0, color: HexColor('#78909C'), fontWeight: FontWeight.bold),),),
                        ),
                      ),
                    ),
                    SizedBox(width: 11.0,),
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: () {_deletePackage(context);},
                        child: new Container(
                          padding: const EdgeInsets.symmetric(vertical: 12.5),
                          decoration: new BoxDecoration(
                            color: HexColor('#FF3333'),
                            borderRadius: BorderRadius.all(Radius.circular(4.0))
                          ),
                          child: new Center(child: new Text(allTranslations.text('delete').toUpperCase(), style: new TextStyle(fontSize: 14.0, color: Colors.white, fontWeight: FontWeight.bold),),),
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}