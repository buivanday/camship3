import 'package:farax/components/gradient_appbar.dart';
import 'package:farax/components/hex_color.dart';
import 'package:farax/utils/auth_utils.dart';
import 'package:farax/utils/network_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../all_translations.dart';
import 'create_package.dart';
import 'create_package_services.dart';
import 'dart:async';
import 'dart:convert';
import 'create_package_sharepreference.dart';
import 'package:provider/provider.dart';
import 'package:farax/services/connectivity.dart';
class CreatePackageInformation extends StatefulWidget {
  const CreatePackageInformation({
    Key key,
    // this.shopInformation,
    // this.receiverInformation,
    this.zoneInformation,
   // this.isSaveContact = false
  }) : super(key: key);

  // final Map<String, dynamic> shopInformation;
  // final Map<String, dynamic> receiverInformation;
  final Map<String, dynamic> zoneInformation;
  //final bool isSaveContact;

  @override
  _CreatePackageInformationState createState() => _CreatePackageInformationState();
}

Future<List<PackageType>> fetchPackageTypes() async {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences _sharedPreferences = await _prefs;
  String accessToken = AuthUtils.getToken(_sharedPreferences);

  var packageTypes = await NetworkUtils.fetch(accessToken, '/api/PackageTypes');
  return parsePackageTypes(packageTypes);
}

// A function that converts a response body into a List<Photo>
List<PackageType> parsePackageTypes(List<dynamic> responseBody) {
  return responseBody.map<PackageType>((json) => PackageType.fromJson(json)).toList();
}

class PackageType {
  final String name;
  final String id;
  final int value;
  final dynamic createdOn;
  final dynamic updatedOn;

  PackageType({this.id, this.name, this.value, this.createdOn, this.updatedOn});

  factory PackageType.fromJson(Map<String, dynamic> json) {
    return PackageType(
      name: json['name'] as String,
      id: json['id'] as String,
      value: json['value'] as int,
      createdOn: json['createdOn'],
      updatedOn: json['updatedOn'],
    );
  }
}

class _CreatePackageInformationState extends State<CreatePackageInformation> {
  bool isClickLeftButton = false;
  bool isClickRightButton = false;
  bool isClick3h = false;
  bool isClick6h = false;
  bool isClick12h = false;
  bool isClick24h = false;
  double shippingPrice = 0;
  double totalShippingPrice = 0;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
	Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences _sharedPreferences;
  DateFormat dateFormat = new DateFormat.Hm();
  var lengthController = new TextEditingController();
  var widthController = new TextEditingController();
  var heightController = new TextEditingController();
  var weightController = new TextEditingController();
  var shopNoteController = new TextEditingController();
  FocusNode _lengthFocusNode = new FocusNode();
  FocusNode _widthFocusNode = new FocusNode();
  FocusNode _heightFocusNode = new FocusNode();
  FocusNode _weightFocusNode = new FocusNode();
  List<FocusNode> listFocusNode;
  double _weight = 0;
  double _actualWeight =0;
  String packageType = '';
  String _authToken = '';
  Future<List<dynamic>> _packageTypes;
  final maxLength = 5;
  int isClickActualWeight ;
  String textStepLastActive1 = '1';
  String textStepLastActive3 = '3';
  bool isOffline = false;
  bool _isReceiverPayIfNotReceived = false;

   //String _regExp='^\d{0,6}(\.\d{0,2})?\$';
  CreatePackageSharePreference createPackageInformationSharePreference = new CreatePackageSharePreference();


  @override
	void initState() {
		super.initState();
    _prefInit();
	}
  @override
  void dispose(){
    super.dispose();
  }
  _prefInit()async{

  bool isPageCrePacInf = await createPackageInformationSharePreference.isPageTwoExist();
  if(!isPageCrePacInf) return;

    await createPackageInformationSharePreference.setPageTwoExist(true);
    double _shippingPrice = await createPackageInformationSharePreference.getDeliverytime();
    int packageTypeStr = await createPackageInformationSharePreference.getWeight();
    double weightNumber = await createPackageInformationSharePreference.getWeightNumber();
    double lengthNumber = await createPackageInformationSharePreference.getLenghtNumber();
    double widthNumber = await createPackageInformationSharePreference.getWitdthNumber();
    double heightNumber = await createPackageInformationSharePreference.getHeightNumber();

    String packageType = await createPackageInformationSharePreference.getPackageType();
    String noteTxt = await createPackageInformationSharePreference.getNoteTxt();
  _deliverytimeCase(_shippingPrice);
  shippingPrice = _shippingPrice;
  _packageTypeCase(packageTypeStr);
  lengthController.text =lengthNumber==0.0? '' : lengthNumber.toString();
  widthController.text = widthNumber==0.0? '':widthNumber.toString();
  heightController.text = heightNumber==0.0?'' : heightNumber.toString();

   weightController.text= weightNumber==0.0 ? '' :weightNumber.toString() ;
   print(weightNumber==0);
   _actualWeight =weightNumber;
  //  totalShippingPrice = weightNumber >= 3 ? (shippingPrice + (weightNumber - 3) * 0.25) : shippingPrice;
  //  totalShippingPrice = _actualWeight >= 3 ? (shippingPrice + (_actualWeight - 3) * 0.25) : shippingPrice;

  _handleChangePackageType(packageType);
   shopNoteController.text =noteTxt;
   _calculateWeight();

  }

  void dataPage()async{
    createPackageInformationSharePreference.setDeliverytime(shippingPrice);
    createPackageInformationSharePreference.setPackageType(packageType);
     createPackageInformationSharePreference.setWeight(isClickActualWeight);
    createPackageInformationSharePreference.setWeightNumber(double.parse(weightController.text==''?'0' : weightController.text));
    createPackageInformationSharePreference.setLengthNumber(double.parse(lengthController.text==''?'0':lengthController.text));
    createPackageInformationSharePreference.setWidthNumber(double.parse(widthController.text==''?'0':widthController.text));
    createPackageInformationSharePreference.setHeightNumber(double.parse(heightController.text==''?'0':heightController.text));
    createPackageInformationSharePreference.setNoteTxt(shopNoteController.text);
    createPackageInformationSharePreference.setPageTwoExist(true);
  }
  _packageTypeCase(int type){
    isClickActualWeight = type;
    switch(type){
      case 1:
        isClickLeftButton= true ;
        isClickRightButton = false;
      break;
      case 2:
        isClickLeftButton= false;
        isClickRightButton = true;
      break;
    }

  }
  _deliverytimeCase(double shippingPrice){
    if(shippingPrice==2.0){
        isClick3h = true;
        isClick6h = false;
        isClick12h = false;
        isClick24h = false;
    }
    else if(shippingPrice==1.5)
    {
      isClick3h = false;
      isClick6h = true;
      isClick12h = false;
      isClick24h = false;
    }
    else if(shippingPrice==1.25)
    {
      isClick3h = false;
      isClick6h = false;
      isClick12h = true;
      isClick24h = false;
    }
    else if(shippingPrice==1){
      isClick3h = false;
      isClick6h = false;
      isClick12h = false;
      isClick24h = true;
    }
    else{
      isClick3h = false;
      isClick6h = false;
      isClick12h = false;
      isClick24h = false;
      }
  }

  _handleChangePackageType(value) {
    setState(() {
      packageType = value;
      //createPackageInformationSharePreference.setPackageType(value);
    });
  }

  _handleChangeRadioReceiverPay(value) {
    setState(() {
      _isReceiverPayIfNotReceived = value;
    });
  }

  _logout() {
		NetworkUtils.logoutUser(_scaffoldKey.currentContext, _sharedPreferences);
	}

  bool _valid() {
    String weight = weightController.text;
    //print(weight);

    return !isOffline && _isValid(packageType) && (isClick3h || isClick6h || isClick12h || isClick24h) && ((isClickLeftButton&& _isValid(weight) && double.parse(weight) > 0) || isClickRightButton) && totalShippingPrice > 0;
  }

  bool _isValid(String variable) {
    return variable != null && variable != '' && variable.isNotEmpty;
  }
  _validRanger(double value){
    if(value>999 || value <1)
      return "1-999";
  }
  String _calculateWeight() {
    String length = lengthController.text;
    String width = widthController.text;
    String height = heightController.text;
    double weight = (double.parse(length == ''? '0' : length) * double.parse(width == '' ? '0' : width) * double.parse(height == '' ? '0' : height)) / 5000;
    //weightController.text = weight.toString();


    setState(() {
      if(isClickLeftButton)
    {
      weightController.text = _actualWeight==0 ?'' : _actualWeight.toString();
      weight = _actualWeight;
    }
      _weight = weight;
      totalShippingPrice = weight >= 3 ? (shippingPrice + (weight - 3) * 0.25) : shippingPrice;
    });
    return weight.toString();
  }

  _fieldFocusChange(BuildContext context, FocusNode currentFocus,FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }
  Future<bool>_backPageWillPop() async{
    _backPage();
    return false;
  }
  _backPage(){
    dataPage();
      Navigator.of(context).pushReplacement(new PageRouteBuilder(
            pageBuilder: (BuildContext context, _,__ ){
              return CreatePackage(

              );
            }
          ));
  }

  @override
  Widget build(BuildContext context) {
    var network = Provider.of<ConnectionStatus>(context);
    if(network==ConnectionStatus.offline){
      NetworkUtils.showSnackBar(_scaffoldKey, null);
      isOffline= true;
    }else{
      isOffline = false;
    }
    return WillPopScope(
    onWillPop: _backPageWillPop,
    child:  Scaffold(
      key: _scaffoldKey,
      body: Container(
        color: Color.fromRGBO(242, 242, 242, 1),
        child: Column(
          children: <Widget>[
            PreferredSize(
              child: new Container(
                padding: new EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: IconButton(
                        icon: Icon(Icons.arrow_back),
                        color: Colors.white,
                        alignment: Alignment.centerLeft,
                        onPressed: () {
                          _backPage();
                        },
                      ),
                      flex: 1,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Align(
                          child: Text(allTranslations.text('create_package_title'), style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 18.0
                          ))
                        ),
                      ),
                      flex: 2,
                    ),
                    Expanded(
                      child: SizedBox(height: 0,width: 0,),
                      flex: 1,
                    )
                  ],
                ),
                decoration: new BoxDecoration(
                  gradient: new LinearGradient(
                    colors: [
                      Color.fromRGBO(0, 201, 232, 1),
                      Color.fromRGBO(0, 153, 204, 1)
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter
                  ),
                  boxShadow: [
                    new BoxShadow(
                      color: Colors.grey[500],
                      blurRadius: 20.0,
                      spreadRadius: 1.0,
                    )
                  ]
                ),
              ),
              preferredSize: new Size(
                MediaQuery.of(context).size.width,
                66.0
              ),
            ),
            Expanded(
              flex: 1,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
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
                           // new StepLastActive(index: 1,current: 2,),
                            InkWell(
                              onTap: () {
                                _backPage();

                              },
                              child: CircleAvatar(
                                backgroundColor: HexColor('#FF9933'),
                                maxRadius: 16.0,
                                child: Text(
                                  textStepLastActive1,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            new DashActive(),

                            new DashActive(),
                            new StepActive(index: 2,),
                            new DashActive(),
                            FutureBuilder(
                              future: createPackageInformationSharePreference.isPageThreeExist(),
                              builder: (BuildContext context,AsyncSnapshot<bool>snapshot){
                                return snapshot.hasData && snapshot.data ? Row(
                                  children: <Widget>[
                                    new DashActive(),
                                    //new StepLastActive(index: 3,current: 2,)
                                    InkWell(
                                      onTap: () {
                                        dataPage();
                                        Navigator.of(context).pop();
                                      },
                                      child: CircleAvatar(
                                        backgroundColor: HexColor('#FF9933'),
                                        maxRadius: 16.0,
                                        child: Text(
                                          textStepLastActive3,
                                          style: TextStyle(
                                              color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                  ) : Row(
                                    children: <Widget>[
                                      new DashInActive(),
                                      new StepInActive(index :3)
                                    ],
                                  )
                                  ;
                              },
                            ),
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
                              new CreatePackageTitle(icon: 'icons/Frame.png', title: 'what_s_your_package'),
                              SizedBox(height: 8.0,),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Container(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(allTranslations.text('delivery_time'), style: TextStyle(color: HexColor('#455A64'), fontWeight: FontWeight.bold),),
                                      SizedBox(height: 10.0,),
                                      IntrinsicHeight(
                                        child: Row(
                                        children: <Widget>[
                                          widget.zoneInformation['2h'] > 0 ? new CreatePackageButton(title: '2' + ' ' + allTranslations.text('hours') +  ' - ' + widget.zoneInformation['2h'].toString() + ' ' + allTranslations.text('usd').toUpperCase(), isClicked: isClick3h, onTap: () {
                                            setState(() {
                                              isClick3h = true;
                                              isClick6h = false;
                                              isClick12h = false;
                                              isClick24h = false;
                                              shippingPrice = double.parse(widget.zoneInformation['2h'].toString());

                                              //createPackageInformationSharePreference.setDeliverytime(2);

                                            });
                                            _calculateWeight();
                                          },) : Container(),
                                          widget.zoneInformation['2h'] > 0  && widget.zoneInformation['4h'] > 0 ? SizedBox(width: 11,) : SizedBox(),
                                          widget.zoneInformation['4h'] >0 ? new CreatePackageButton(title: '4' + ' ' + allTranslations.text('hours') +  ' - ' + widget.zoneInformation['4h'].toString() + ' ' + allTranslations.text('usd').toUpperCase(), isClicked: isClick6h, onTap: () {
                                            setState(() {
                                              isClick3h = false;
                                              isClick6h = true;
                                              isClick12h = false;
                                              isClick24h = false;
                                              shippingPrice = double.parse(widget.zoneInformation['4h'].toString());
                                             // createPackageInformationSharePreference.setDeliverytime(1.5);
                                            });
                                            _calculateWeight();
                                          }) : Container(),
                                        ],
                                        ),
                                      ),
                                      SizedBox(height: 10.0,),
                                      IntrinsicHeight(
                                        child: Row(
                                        children: <Widget>[
                                          widget.zoneInformation['8h'] > 0 ? new CreatePackageButton(title: '8' + ' ' + allTranslations.text('hours') +  ' - ' + widget.zoneInformation['8h'].toString() + ' ' + allTranslations.text('usd').toUpperCase(), isClicked: isClick12h,  onTap: () {
                                            setState(() {
                                              isClick3h = false;
                                              isClick6h = false;
                                              isClick12h = true;
                                              isClick24h = false;
                                              shippingPrice = double.parse(widget.zoneInformation['8h'].toString());
                                             // createPackageInformationSharePreference.setDeliverytime(1.25);
                                            });
                                            _calculateWeight();
                                          }) : Container(),
                                          widget.zoneInformation['8h'] > 0  && widget.zoneInformation['24h'] >= 0 ? SizedBox(width: 11,) : SizedBox(),
                                          widget.zoneInformation['24h'] > 0 ? new CreatePackageButton(title: '24' + ' ' + allTranslations.text('hours') +  ' - ' + widget.zoneInformation['24h'].toString() + ' ' + allTranslations.text('usd').toUpperCase(), isClicked: isClick24h,  onTap: () {
                                            setState(() {
                                              isClick3h = false;
                                              isClick6h = false;
                                              isClick12h = false;
                                              isClick24h = true;
                                              shippingPrice = double.parse(widget.zoneInformation['24h'].toString());
                                              //createPackageInformationSharePreference.setDeliverytime(1);
                                            });
                                            _calculateWeight();
                                          }) : Container(),
                                        ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                child: Text(allTranslations.text('package_type'), style: TextStyle(color: HexColor('#455A64'), fontWeight: FontWeight.bold),),
                              ),
                              Container(
                                padding: const EdgeInsets.all(10.0),
                                child: IntrinsicHeight(
                                  child: Row(
                                  children: <Widget>[
                                    new CreatePackageButton(title: allTranslations.text('actual_weight'), isClicked: isClickLeftButton, onTap:  () {
                                      setState(() {
                                        isClickLeftButton = true;
                                        isClickRightButton = false;
                                        isClickActualWeight = 1;
                                        weightController.text = _actualWeight==0.0? '': _actualWeight.toString();
                                        totalShippingPrice = _actualWeight >= 3 ? (shippingPrice + (_actualWeight - 3) * 0.25) : shippingPrice;
                                      });
                                    },),
                                    SizedBox(width: 11,),
                                    new CreatePackageButton(title: allTranslations.text('weight_converted_from_size'), isClicked: isClickRightButton, onTap:  () {
                                      setState(() {
                                        isClickRightButton = true;
                                        isClickLeftButton = false;
                                        isClickActualWeight = 2;
                                      });
                                      FocusScope.of(context).requestFocus(_lengthFocusNode);
                                    },),
                                  ],
                                ),
                                )
                              ),
                              SizedBox(height: 6.0,),
                              isClickLeftButton == true ? Padding(
                                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(allTranslations.text('weight') + ' (kg)', style: TextStyle(color: HexColor('#B0BEC5')),),
                                    TextField(
                                      textInputAction: TextInputAction.go,
                                      focusNode: _weightFocusNode,

                                    //  inputFormatters: [WhitelistingTextInputFormatter(new RegExp(_regExp))],
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
                                            child: Text(totalShippingPrice.toString() + ' ' + allTranslations.text('usd').toUpperCase(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                          ),
                                        )
                                      ),
                                      keyboardType: TextInputType.numberWithOptions(decimal: true),

                                      onChanged: (String value) {
                                        setState(() {
                                          if(value=='')
                                            value ='0';
                                        //  createPackageInformationSharePreference.setWeightNumber(double.parse(weightController.text));
                                          totalShippingPrice = double.parse(value??0) >= 3 ? (shippingPrice + (double.parse(value??0) - 3) * 0.25) : shippingPrice;
                                          _weight = double.parse(value??0);
                                          _actualWeight = _weight;

                                        });
                                      },
                                      controller: weightController,
                                    )
                                  ],
                                ),
                              ) : SizedBox(width: 0,),
                              isClickRightButton == true ? Container(
                                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 10),
                                color: Colors.white,
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
                                              Form(
                                                child: TextFormField(
                                                  maxLength: 4,
                                                //inputFormatters: ,
                                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                                controller: lengthController,
                                                textInputAction: TextInputAction.next,
                                                focusNode: _lengthFocusNode,
                                               // autofocus: true,
                                               decoration: InputDecoration(counterText: ''),
                                                onFieldSubmitted: (value) {
                                                  widthController.text = '';
                                                  //createPackageInformationSharePreference.setLengthNumber(double.parse(lengthController.text));
                                                  _fieldFocusChange(context, _lengthFocusNode, _widthFocusNode);
                                                  },
                                                ),
                                                onChanged: (){
                                                //  createPackageInformationSharePreference.setLengthNumber(double.parse(lengthController.text));
                                                  _calculateWeight();
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
                                              Form(
                                                child: TextFormField(
                                               // inputFormatters: [],
                                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                                controller: widthController,
                                                textInputAction: TextInputAction.next,
                                                focusNode: _widthFocusNode,
                                                onFieldSubmitted: (value) {
                                                  heightController.text = '';
                                                  //createPackageInformationSharePreference.seWidthNumber(double.parse(widthController.text));
                                                  _fieldFocusChange(context, _widthFocusNode, _heightFocusNode);
                                                },
                                                ),
                                                onChanged: (){
                                                  //createPackageInformationSharePreference.seWidthNumber(double.parse(widthController.text));
                                                  _calculateWeight();
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
                                              Text(allTranslations.text('height') + ' (cm)', style: TextStyle(color: HexColor('#B0BEC5')),),
                                              Form(

                                                child: TextFormField(
                                               // inputFormatters: [],
                                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                                controller: heightController,
                                                textInputAction: TextInputAction.done,
                                                focusNode: _heightFocusNode,
                                                onFieldSubmitted: (value) {
                                                  //createPackageInformationSharePreference.setHeightNumber(double.parse(heightController.text));
                                                  _heightFocusNode.unfocus();
                                                  },
                                                ),
                                                onChanged:(){
                                                 // createPackageInformationSharePreference.setHeightNumber(double.parse(heightController.text));
                                                  _calculateWeight();
                                                } ,
                                              ),

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
                                          Text(totalShippingPrice.toString() + ' ' + allTranslations.text('usd').toUpperCase(), style: TextStyle(color: HexColor('#FF9933'), fontSize: 14, fontWeight: FontWeight.bold),)
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ) : IgnorePointer(
                                ignoring: true,
                                child: Opacity(
                                  opacity: 0.0,
                                ),
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
                                        ),
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
                                child: Text(allTranslations.text('note'), style: TextStyle(color: HexColor('#B0BEC5'), fontSize: 12.0),),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 20.0),
                                child: TextField(
                                  controller: shopNoteController,
                                  onChanged: (value){
                                    //createPackageInformationSharePreference.setNoteTxt(value);
                                  },
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _isReceiverPayIfNotReceived = !_isReceiverPayIfNotReceived;
                                  });
                                },
                                child: Row(
                                  children: <Widget>[
                                    Checkbox(
                                      value: _isReceiverPayIfNotReceived,
                                      onChanged: _handleChangeRadioReceiverPay,
                                      activeColor: HexColor('#0099CC'),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(allTranslations.text('note_receiver_must_pay_if_not_receive'), style: TextStyle(color: HexColor('#455A64')),),
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 1,
                                      child: RaisedButton(
                                        onPressed: () {
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
                                        onPressed: _valid() ? (

                                        ) async{
                                          bool checkPage = await createPackageInformationSharePreference.isPageThreeExist();

                                          createPackageInformationSharePreference.setPageTwoExist(true);
                                          dynamic obj ={
                                            'zoneInformation' : widget.zoneInformation,
                                            'packageInformation' : {
                                                    'packageTypeId': packageType,
                                                    'weight': _weight,
                                                    'packageSize': {
                                                      'length': lengthController.text,
                                                      'height': heightController.text,
                                                      'width': widthController.text,
                                                    },
                                                    "price":totalShippingPrice,
                                                    'currencyId':'5ca479e13ba7381850a0d2d7',
                                                    'typeOfCalWeight': isClickLeftButton ? 'actualWeight' : 'convertedFromSize'
                                                          },
                                            'totalShippingPrice': totalShippingPrice,
                                            'deliveryTime': isClick3h ? '2h' : (isClick6h ? '4h' : (isClick12h ? '8h' : '24h')),
                                            'shopNotes': shopNoteController.text
                                          };
                                          SharedPreferences pref = await _prefs;
                                          String pageTwoData = jsonEncode(obj);
                                            await pref.setString('dataPageTwo', pageTwoData);

                                          dataPage();

                                          if(checkPage==true){
                                              Navigator.of(context).pop();
                                            }
                                        else
                                          Navigator.of(context).pushReplacement(
                                            new PageRouteBuilder(
                                              pageBuilder: (BuildContext context, _, __) {
                                                return CreatePackageServices(
                                                  // shopInformation: widget.shopInformation,
                                                  // receiverInformation: widget.receiverInformation,
                                                  // zoneInformation: widget.zoneInformation,
                                                  // isSaveContact: widget.isSaveContact,
                                                  zoneInformation: obj['zoneInformation'],
                                                // packageInformation:obj['packageInformation'],
                                                // totalShippingPrice: obj['totalShippingPrice'],
                                                // deliveryTime: obj['deliveryTime'],
                                                // shopNotes: obj['shopNotes']
                                                );
                                              },
                                            )
                                          );

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
                                            child: Text(allTranslations.text('next').toUpperCase(), style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              )//1
                              //
                            ],
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

class CreatePackageButton extends StatefulWidget {
  const CreatePackageButton({
    Key key,
    this.title,
    this.onTap,
    this.isClicked
  }) : super(key: key);

  final String title;
  final bool isClicked;
  final Function() onTap;

  @override
  _CreatePackageButtonState createState() => _CreatePackageButtonState();
}

class _CreatePackageButtonState extends State<CreatePackageButton> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: widget.isClicked == false ? HexColor('#DFE4EA') : HexColor('#0099CC'),
            ),
            borderRadius: BorderRadius.all(Radius.circular(5))
          ),
          child: Center(
            child: Text(widget.title, textAlign: TextAlign.center, style: TextStyle(color: widget.isClicked == false ? HexColor('#78909C') : HexColor('#0099CC')),),
          ),
        ),
      ),
    );
  }
}
