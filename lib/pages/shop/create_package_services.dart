import 'dart:collection';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:farax/components/gradient_appbar.dart';
import 'package:farax/components/hex_color.dart';
import 'package:farax/utils/auth_utils.dart';
import 'package:farax/utils/network_utils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../all_translations.dart';
import 'create_package.dart';
import 'create_package_bill.dart';
import 'create_package_information.dart';
import '../../utils/lodash.dart';
import 'create_package_sharepreference.dart';

class CreatePackageServices extends StatefulWidget {
  const CreatePackageServices({
    Key key,
   // this.shopInformation,
   // this.receiverInformation,
    this.zoneInformation,
   // this.isSaveContact = false,
   // this.packageInformation,
   // this.deliveryTime,
   // this.totalShippingPrice = 0,
   // this.shopNotes
  }) : super(key: key);

  // final Map<String, dynamic> shopInformation;
  // final Map<String, dynamic> receiverInformation;
   final Map<String, dynamic> zoneInformation;
  // final bool isSaveContact;
  // final String shopNotes;
  // final Map<String, dynamic> packageInformation;
  // final String deliveryTime;
  // final double totalShippingPrice;

  @override
  _CreatePackageServicesState createState() => _CreatePackageServicesState();
}

class _CreatePackageServicesState extends State<CreatePackageServices> {
  bool isClickCod = false;
  bool isClickExpress = false;
  bool isClickShop = false;
  bool isClickCustomer = false;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
	Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences _sharedPreferences;
  List<Widget> codItems = new List<Widget>();
  List<CodItem> lsCodItems = new List<CodItem>();
  List<TextEditingController> codItemControllers = new List<TextEditingController>();
  var totalController = new TextEditingController();
  var promotionCodeController = new TextEditingController();
  Lodash _ = Lodash();
  List<String> itemsName;
  static List<String> itemsAmount;
  static List<String> itemsPrice;
  dynamic itemsInfo;
  int i=0;
  CreatePackageSharePreference createPackageInformationSharePreference = new CreatePackageSharePreference();
 

   Map<String, dynamic> shopInformation;
   Map<String, dynamic> receiverInformation;
  //Map<String, dynamic> zoneInformation;
   bool isSaveContact;
   Map<String, dynamic> packageInformation;
   String deliveryTime;
   double totalShippingPrice;
   double totalCOD;
   double totalExpress;
   double valueOfOrder;
   String shopNotes;

   FocusNode fcBtnSubmit = new FocusNode();
   FocusNode fcAmountItem = new FocusNode();
   FocusNode fcPriceItem = new FocusNode();
  @override
	void initState() {
		super.initState();
		_fetchSessionAndNavigate();
  //  _prefInit();
	}

  _fetchSessionAndNavigate() async {
		_sharedPreferences = await _prefs;
    await _sharedPreferences.setBool("isBillExist", false);
		String authToken = AuthUtils.getToken(_sharedPreferences);

		if(authToken == null) {
			_logout();
		}
    createPackageInformationSharePreference.setPageThreeExist(true);
	}
  
  
  _addItem() async{
    TextEditingController nameController = new TextEditingController();
    TextEditingController priceController = new TextEditingController();
    TextEditingController amountController = new TextEditingController();
    int id= codItems.length;
      codItemControllers.add(nameController);
      codItemControllers.add(amountController);
      codItemControllers.add(priceController);    
    setState(() { 
      codItems.add( new CodItem(index: id+1, nameController: nameController, priceController: priceController, amountController: amountController,onDelete: (){_onDelete(id);},));
    });
  }

  void _onDelete(int index)async{
    setState(() {         
        codItems.removeAt(index);
      if(codItemControllers.isNotEmpty) {
        codItemControllers.removeRange(index * 3, index * 3 + 3);
      }
    });
      
  }

  bool _valid() {
    return ((isClickCod) || (isClickExpress && _isValid(totalController.text))) && (isClickShop || isClickCustomer);
  }

  bool _isValid(String variable) {
    return variable != null && variable != '' && variable.isNotEmpty;
  }

  _logout() {
		NetworkUtils.logoutUser(_scaffoldKey.currentContext, _sharedPreferences);
	}
  _infoBill(double total,List<Map<String,dynamic>>items) async{
   
  }
  Future<bool>_backPageWillPop()async{
    _backPage();
    return false;
  }
  _backPage(){
     Navigator.of(context).push(new PageRouteBuilder(
            pageBuilder: (BuildContext context, _, __) {
              return CreatePackageInformation(
                zoneInformation: widget.zoneInformation
              );
            },
          ));
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _backPageWillPop,
      child :Scaffold(
      key: _scaffoldKey,
      body: Container(
        color: Color.fromRGBO(242, 242, 242, 1),
        child: Column(
          children: <Widget>[
            GradientAppBar(title: allTranslations.text('create_package_title'), hasBackIcon: true,backToCreatePackageInfo: true,),
            Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                },
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Container(
                    padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new StepLastActive(index: 1,current: 3,),
                            new DashActive(),
                            new DashActive(),
                            new StepLastActive(index: 2,current: 3,),
                            new DashActive(),
                            new DashActive(),
                            new StepActive(index: 3,),
                          ],
                        ),
                        SizedBox(height: 20.0,),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(4.0)),
                            color: Colors.white
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              new CreatePackageTitle(icon: 'icons/service-icon.png', title: 'services'),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(allTranslations.text('who_pays'), style: TextStyle(color: HexColor('#455A64'), fontWeight: FontWeight.bold),),
                                    SizedBox(height: 10.0,),
                                    IntrinsicHeight(
                                        child: Row(
                                        children: <Widget>[
                                          new CreatePackageButton(title: allTranslations.text('shop'), isClicked: isClickShop, onTap:  () {
                                            setState(() {
                                              isClickShop = true;
                                              isClickCustomer = false;
                                              
                                            });
                                            createPackageInformationSharePreference.setWhoPay(1);
                                          },),
                                          SizedBox(width: 11.0),
                                          new CreatePackageButton(title: allTranslations.text('customer'), isClicked: isClickCustomer, onTap:  () {
                                            setState(() {
                                              isClickShop = false;
                                              isClickCustomer = true;
                                              
                                            });
                                            createPackageInformationSharePreference.setWhoPay(2);
                                          },),
                                        ],
                                      )
                                    ),
                                    SizedBox(height: 30.0,),
                                    Text(allTranslations.text('extra_services'), style: TextStyle(color: HexColor('#455A64'), fontWeight: FontWeight.bold),),
                                    SizedBox(height: 10.0,),
                                    IntrinsicHeight(
                                        child: Row(
                                        children: <Widget>[
                                          new CreatePackageButton(title: allTranslations.text('cod').toUpperCase(), isClicked: isClickCod, onTap:  () {
                                            setState(() {
                                              isClickCod = true;
                                              isClickExpress = false;
                                              
                                            });
                                            createPackageInformationSharePreference.setService(1);
                                            codItems.length<= 0 ? _addItem() :'';
                                          },),
                                          SizedBox(width: 11.0,),
                                          new CreatePackageButton(title: allTranslations.text('express'), isClicked: isClickExpress, onTap:  () {
                                            setState(() {
                                              isClickCod = false;
                                              isClickExpress = true;
                                              
                                            });
                                            createPackageInformationSharePreference.setService(2);
                                          },),
                                        ],
                                      )
                                    ),
                                    isClickCod ? Column(
                                      children: <Widget>[
                                        SizedBox(height: 30.0,),
                                        Column(
                                          children: 
                                           codItems
                                          ,
                                        ),
                                        InkWell(
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
                                        ),
                                        SizedBox(height: 30.0,),
                                      ],
                                    ) : IgnorePointer(
                                      ignoring: true,
                                      child: Opacity(opacity: 0.0,),
                                    ),
                                    isClickExpress ? Theme(
                                      data: new ThemeData(
                                        hintColor: HexColor('#DFE4EA')
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(bottom: 30.0),
                                        child: TextField(
                                          decoration: InputDecoration(
                                            labelText: allTranslations.text('total'),
                                            labelStyle: TextStyle(color: HexColor('#90A4AE'), fontSize: 14),
                                            hintText: allTranslations.text('total'),
                                          ),
                                          controller: totalController,
                                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                                          onChanged: (value){                                             
                                                createPackageInformationSharePreference.setTotalService(double.parse(value));                                              
                                          },
                                        ),
                                      ),
                                    ) : IgnorePointer(
                                      ignoring: true,
                                      child: Opacity(opacity: 0.0,),
                                    ),
                                    SizedBox(height: 30.0,),
                                    Text(allTranslations.text('promotion_code'), style: TextStyle(color: HexColor('#455A64'), fontWeight: FontWeight.bold),),
                                    TextField(
                                      controller: promotionCodeController,
                                      onChanged: (value){                                      
                                          createPackageInformationSharePreference.setPromptionCode(value);                                       
                                      },
                                      decoration: InputDecoration(
                                      
                                        hintText: allTranslations.text('enter_promotion_code'),
                                        hintStyle: TextStyle(
                                          color: HexColor('#90A4AE'),
                                          fontSize: 14.0
                                        ),
                                        suffix: Container(
                                          width: 71.0,
                                          height: 36.0,
                                          decoration: BoxDecoration(
                                            color: HexColor('#0099CC'),
                                            borderRadius: BorderRadius.all(Radius.circular(4.0))
                                          ),
                                          child: Center(
                                            child: Text(allTranslations.text('verify').toUpperCase(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                                          ),
                                        )
                                      ),
                                    ),
                                    SizedBox(height: 15.0,),
                                    Padding(
                                    padding: const EdgeInsets.all(1),
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          flex: 1,
                                          child: RaisedButton(
                                            onPressed: () {
                                              //createPackageInformationSharePreference.setPageThreeExist(true);
                                              //Navigator.of(context).pop();
                                              _backPage();
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
                                            focusNode: fcBtnSubmit,
                                            onPressed: _valid() ? () async {
                                              var itemsArr = _.chunk(array: codItemControllers, size: 3);
                                              var items = itemsArr.map((item) {
                                                return {
                                                  'name': item[0].text,
                                                  'amount': item[1].text,
                                                  'price': item[2].text
                                                };
                                              }).toList();
                                  
                                              bool hasError = false;
                                              double total = 0;
                                              double totalCOD = 0;
                                              if(isClickExpress) {
                                              } else {
                                                items.forEach((item) {
                                                  if(item['price'] == '' || item['amount'] == '' || item['name'] == '') {
                                                    hasError = true;
                                                  } else {
                                                    //double _price = double.parse(item['price'].toString());
                                                    total += double.parse(item['price'].toString()) * double.parse(item['amount'].toString());
                                                  }
                                                });

                                                if(total >= 100) {
                                                  totalCOD = total * 0.5 / 100;
                                                } 
                                              }
                                              if(hasError) {
                                                Fluttertoast.showToast(
                                                  msg: allTranslations.text('please_enter_full_items'),
                                                  toastLength: Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.CENTER,
                                                  timeInSecForIos: 1,
                                                  backgroundColor: Colors.red,
                                                  textColor: Colors.white,
                                                  fontSize: 16.0
                                                );
                                              } else {
                                                createPackageInformationSharePreference.setPageThreeExist(true);
                                                //_infoBill(total, items);
                                                SharedPreferences pref = await _prefs;
                                                var jsonDataPageOne =  pref.getString('dataPageOne');
                                                var jsonDataPageTwo = pref.getString('dataPageTwo');
                                                
                                                if(jsonDataPageOne==null|| jsonDataPageTwo==null) return;
                                                var obj = jsonDecode(jsonDataPageOne);
                                                var dataPage2 =jsonDecode(jsonDataPageTwo);
                                                var information=dataPage2['packageInformation'];

                                                shopInformation= obj['shopInformation'];
                                                receiverInformation=obj['receiverInformation'];
                                                isSaveContact =obj['isSaveContact'];
                                                packageInformation= {
                                                  'packageTypeId': information['packageTypeId'],
                                                  'weight': information['weight'],
                                                  'packageSize': {
                                                      'length': information['packageSize']['length'],
                                                      'height': information['packageSize']['height'],
                                                      'width': information['packageSize']['width'],
                                                  },
                                                  'items': isClickExpress ? [
                                                    {
                                                      'amount': 1,
                                                      'price': 0,
                                                      'name': ''
                                                      }
                                                      ] : items,
                                                  'isShopPaid': isClickShop ? 'true' : 'false',
                                                  'extraService': isClickExpress ? 'express' : 'cod',
                                                  'total': isClickExpress ? totalController.text : total,
                                                  'typeOfCalWeight': information['typeOfCalWeight'],
                                                  "price":information['price'],
                                                  'currencyId':'5ca479e13ba7381850a0d2d7',
                                                };
                                              
                                                totalShippingPrice= dataPage2['totalShippingPrice'];
                                                
                                                deliveryTime= dataPage2['deliveryTime'];
                                                totalCOD= isClickCod ? totalCOD : 0;
                                                totalExpress =isClickExpress ? totalExpress : 0 ;
                                                valueOfOrder=isClickCod ? total : 0;
                                                shopNotes= dataPage2['shopNotes'];
                                              
                                              
                                              FocusScope.of(context).requestFocus(fcBtnSubmit);  
                                                Navigator.of(context).push(
                                                  new PageRouteBuilder(
                                                    pageBuilder: (BuildContext context, _, __) {
                                                      return CreatePackageBill(
                                                        shopInformation: shopInformation,
                                                        receiverInformation: receiverInformation,
                                                        zoneInformation: widget.zoneInformation,
                                                        isSaveContact: isSaveContact,
                                                        packageInformation: packageInformation,
                                                        totalShippingPrice: totalShippingPrice,
                                                        deliveryTime: deliveryTime,
                                                        totalCOD: isClickCod ? totalCOD : 0,
                                                        valueOfOrder: isClickCod ? total : 0,
                                                        shopNotes: shopNotes
                                                      );
                                                    },
                                                  )
                                                );
                                              }
                                            } : null,
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
                                                child: Text(allTranslations.text('submit').toUpperCase(), style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold)),
                                              ),
                                            ),
                                          ),
                                        )//1
                                      ],
                                    ),
                                  )//1
                                    //
                                  ]
                                ),
                              )
                            ]
                          ),
                        ),
                      ],
                    ),
                  )
                ),
              )
            ),
           
          ]
        )
      )
    ));
  }
}

class CodItem extends StatefulWidget {
   CodItem({
    Key key,
    this.index,
    this.nameController,
    this.priceController,
    this.amountController,
    this.onDelete,
    this.timeStamp
  }) : super(key: key);

  int index;
  int timeStamp;
  final TextEditingController nameController ;
  final TextEditingController priceController;
  final TextEditingController amountController;
  Function onDelete;

  @override
  _CodItemState createState() => _CodItemState();
}

class _CodItemState extends State<CodItem> {
 
  CreatePackageSharePreference prefs = new CreatePackageSharePreference();
  
  List<String> itemsName=[];
  static List<String> itemsAmount=[];
  static List<String> itemsPrice=[];
  var focusNodeName = new FocusNode();
  var focusNodeAmount = new FocusNode();
  var focusNodePrice = new FocusNode();
  int id;
  @override
  void initState() {
    
    super.initState();
    
  }
  @override
  void dispose() {
    
    super.dispose();
    focusNodeName.dispose();
    focusNodeAmount.dispose();
    focusNodePrice.dispose();
  }

  _fieldFocusChange(BuildContext context, FocusNode currentFocus,FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);  
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.lens, size: 10, color: HexColor('#FF9933'),),
                SizedBox(width: 8.0,),
                Text((allTranslations.text('item') + ' ' + widget.index.toString()).toUpperCase(), style: TextStyle(color: HexColor('#78909C'), fontSize: 12, fontWeight: FontWeight.bold),),
              ],
            ),
            InkWell(
              onTap: widget.onDelete,
              child: Icon(Icons.delete, color: Colors.red,),
            )
          ],
        ),
        Theme(
          data: new ThemeData(
            hintColor: HexColor('#DFE4EA')
          ),
          child: TextField(
            autofocus: false,//widget.nameController.text.isEmpty? false : true,
            onChanged: (value){          
                
            },
            onSubmitted: (value){
            _fieldFocusChange(context, focusNodeName, focusNodeAmount);
           
            },
            focusNode: focusNodeName,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: allTranslations.text('name'),
              hintStyle: TextStyle(color: HexColor('#90A4AE'), fontSize: 14),
            ),
            controller: widget.nameController,
          ),
        ),
        SizedBox(height: 20.0,),
        Theme(
          data: new ThemeData(
            hintColor: HexColor('#DFE4EA')
          ),
          child: TextField(
            onChanged: (value){
               // prefs.setItemAmount(value);
            },
            onSubmitted: (value){
               _fieldFocusChange(context, focusNodeAmount, focusNodePrice);
            },
            focusNode: focusNodeAmount,
            textInputAction: TextInputAction.next,
            inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: allTranslations.text('quantity'),
              hintStyle: TextStyle(color: HexColor('#90A4AE'), fontSize: 14),
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true,signed: false),
            controller: widget.amountController,
          ),
        ),
        SizedBox(height: 20.0,),
        Theme(
          data: new ThemeData(
            hintColor: HexColor('#DFE4EA')
          ),
          child: TextField(
            onChanged: (value){
             // prefs.setItemPrice(value);
            },
            onSubmitted: (value){
              focusNodePrice.unfocus();
              
            },
            focusNode: focusNodePrice,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: allTranslations.text('price') + ' (' + allTranslations.text('usd').toUpperCase() + ')',
              hintStyle: TextStyle(color: HexColor('#90A4AE'), fontSize: 14),
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            controller: widget.priceController,
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