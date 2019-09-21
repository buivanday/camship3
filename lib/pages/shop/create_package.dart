import 'package:farax/components/gradient_appbar.dart';
import 'package:farax/components/hex_color.dart';
import 'package:farax/services/connectivity.dart';
import 'package:farax/utils/auth_utils.dart';
import 'package:farax/utils/network_utils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

import '../../all_translations.dart';
import '../choose_on_map.dart';
import 'add_address_book.dart';
import 'create_package_information.dart';
import 'create_package_services.dart';
import 'create_package_sharepreference.dart';
import '../../components/offline_notification.dart';
import '../../blocs/regex.dart';
import 'package:provider/provider.dart';
import 'package:farax/services/connectivity.dart';

class CreatePackage extends StatefulWidget {
  final Map<String, dynamic> shopInformation;
  final Map<String, dynamic> receiverInformation;
  final bool isSaveContact;

  const CreatePackage(
      {Key key,
      this.shopInformation,
      this.receiverInformation,
      this.isSaveContact})
      : super(key: key);

  @override
  _CreatePackageState createState() => _CreatePackageState();
}

class _CreatePackageState extends State<CreatePackage> {
  bool _isSaveContact = false;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences _sharedPreferences;
  var _fullNameShopController = new TextEditingController();
  var _phoneNumberShopController = new TextEditingController();
  var _addressShopController = new TextEditingController();
  var _fullNameCustomerController = new TextEditingController();
  var _phoneNumberCustomerController = new TextEditingController();
  var _addressCustomerController = new TextEditingController();
  var _storeIdController = new TextEditingController();
  final FocusNode _fullNameFocusNode = FocusNode();
  final FocusNode _phoneNumberFocusNode = FocusNode();
  String _storeId = '';
  List<dynamic> _defaultStores = [];
  List<dynamic> _defaultReceivers = [];
  bool isLoaded = false;
  dynamic selectedZone;
  dynamic zoneId;
  var resultSelectedZone;
  double lat;
  double lng;
  bool isGetReceiver = false;
  String jsonData;
  final _mobileFormatter = NumberTextInputFormatter();
  CreatePackageSharePreference preference;
  var network;
  bool isOffline = false;
  bool _autoValidPhone = false,_autoValidName=false,_autoValidAddress =false;
  bool _isErr= false;
  bool _isValidNB =false;
  bool _isForm =false;
  ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    _fetchSessionAndNavigate();
    _cusListener();
    _prefInit();
  }

  @override
  void dispose() {
    super.dispose();
    //_destroyPref();
  }

  _prefInit() async {
    SharedPreferences pref = await _prefs;
    jsonData = pref.getString('dataPageOne');
    if (jsonData == null) return;
    var obj = jsonDecode(jsonData);
    final Map<String, dynamic> shopInformation = obj['shopInformation'];
    final Map<String, dynamic> receiverInformation = obj['receiverInformation'];
    final dynamic zoneInformation = obj['zoneInformation'];

    _fullNameShopController.text = shopInformation['name'];
    _phoneNumberShopController.text = shopInformation['phoneNumber'];
    _addressShopController.text = shopInformation['address'];
    _storeIdController.text = shopInformation['id'];
    _fullNameCustomerController.text = receiverInformation['fullName'];
    _phoneNumberCustomerController.text = receiverInformation['phoneNumber'];
    _addressCustomerController.text = receiverInformation['address'];
    zoneId = receiverInformation['zoneId'];
    selectedZone = zoneInformation;
    _isSaveContact = obj["isSaveContact"];
  }

  _fetchSessionAndNavigate() async {
    _sharedPreferences = await _prefs;
    String authToken = AuthUtils.getToken(_sharedPreferences);
    network = Provider.of<ConnectionStatus>(context);
    if (network == ConnectionStatus.offline) {
      NetworkUtils.showSnackBar(_scaffoldKey, null);
      isOffline = true;
      return;
    } else
      isOffline = false;
    if (authToken == null) {
      _logout();
    } else {
      var _storesResponse =
          await NetworkUtils.fetch(authToken, '/api/Members/stores');
      var _defaultStores = _storesResponse.where((_store) {
        return _store['isPrimary'] == true;
      }).toList();
      var _defaultStore;
      if (_defaultStores.isEmpty) {
        _defaultStore = _storesResponse[0];
      } else {
        _defaultStore = _defaultStores[0];
      }

      if (mounted == true) {
        setState(() {
          _defaultStores = _storesResponse;
        });
      }

      _fullNameShopController.text = _defaultStore['name'];
      _phoneNumberShopController.text = _defaultStore['phoneNumber'];
      _addressShopController.text = _defaultStore['address'];
      _storeIdController.text = _defaultStore['id'];
    }
  }

  _logout() {
    NetworkUtils.logoutUser(_scaffoldKey.currentContext, _sharedPreferences);
  }

  bool _valid() {
    String _shopFullName = _fullNameShopController.text;
    String _shopPhoneNumber = _phoneNumberShopController.text;
    String _shopAddress = _addressShopController.text;

    String _customerFullName = _fullNameCustomerController.text;
    String _customerPhoneNumber = _phoneNumberCustomerController.text;
    String _customerAddress = _addressCustomerController.text;

    return _isValid(_shopFullName) &&
        _isValid(_shopPhoneNumber) &&
        _isValid(_shopAddress) &&
        _isValid(_customerFullName) &&
        _isValid(_customerPhoneNumber)&&
        _isValid(_customerAddress);
        
  }

  bool _isValid(String variable) {
    return variable != null && variable != '' && variable.isNotEmpty;
  }

  String _validatePhoneNumber(String value) {
    final RegExp phoneExp = RegExp(r'^0\d+$');
     // _isValidateNB = false;
     if(value.length==0 ||value.trim()=='')
      return null;
    if (value.length < 9) 
      return  allTranslations.text('phone_number_10_digit');
    else if (!phoneExp.hasMatch(value))   
      return allTranslations.text('phone_number_format');
     
   
    return null;
  }
  String _validateFullnameCus(String value){
    if(_fullNameCustomerController.text.length==0||_fullNameCustomerController.text.trim()==''){
      //return 'Full Name is not empty';
    }
    return null;
  }
  String _validateAddressCus(String value){
    if(_addressCustomerController.text.length==0){
      return 'Address is not empty';
    }
    return null;
  }
  _cusListener() {
    _phoneNumberFocusNode.addListener(() {
   
    if(_phoneNumberFocusNode.hasFocus) {
      _autoValidPhone = true;
    }else{
      _autoValidName =false;
    }
    });
    _fullNameFocusNode.addListener((){
       if(_fullNameFocusNode.hasFocus){
        _autoValidName =true;
      }else{
        _autoValidName=false;
      }
    });
    
  }

  void _settingModalBottomSheet(context) async {
    network = Provider.of<ConnectionStatus>(context);
    if (network == ConnectionStatus.offline) {
      isOffline = true;
    } else {
      setState(() {
        isOffline = false;
      });
    }
    ;
    if (!isLoaded && !isOffline) {
      String authToken = AuthUtils.getToken(_sharedPreferences);
      var _storesResponse =
          await NetworkUtils.fetch(authToken, '/api/Members/stores');
      if (mounted) {
        setState(() {
          _defaultStores = _storesResponse;
          isLoaded = true;
        });
      }
    }
    List<Widget> list = new List<Widget>();
    for (var i = 0; i < _defaultStores.length; i++) {
      dynamic _store = _defaultStores[i];
      _store['index'] = i;
      list.add(Column(
        children: <Widget>[
          new ListTile(
              leading: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    new Icon(
                      Icons.home,
                      textDirection: TextDirection.ltr,
                    )
                  ],
                ),
              ),
              title: new Text(_store['name']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(_store['address']),
                  SizedBox(
                    height: 2.0,
                  ),
                  Text(_store['phoneNumber'])
                ],
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
              onTap: () {
                _fullNameShopController.text = _store['name'];
                _phoneNumberShopController.text = _store['phoneNumber'];
                _addressShopController.text = _store['address'];
                _storeIdController.text = _store['id'];

                Navigator.pop(context);
                FocusScope.of(context).requestFocus(_fullNameFocusNode);
                // _settingModalReceiverBottomSheet(context);
              }),
          Divider()
        ],
      ));
    }
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            padding: const EdgeInsets.only(top: 16.0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        allTranslations.text('list_shops'),
                        style: TextStyle(
                            color: HexColor('#455A64'),
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0),
                      ),
                      InkWell(
                        onTap: () async {
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddAddressBook()));
                          setState(() {
                            isLoaded = false;
                          });

                          Navigator.pop(context);
                          _settingModalBottomSheet(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: HexColor('#FF9933'),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Text('Add Store',style: 
                              TextStyle(color:  Colors.white,
                            
                            ),
                          )
                        ),
                      ))
                    ],
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Divider(
                  height: 1.0,
                ),
                Expanded(
                  flex: 1,
                  child: isOffline
                      ? OfflineNotification()
                      : SingleChildScrollView(
                          child: Column(
                            children: list,
                          ),
                        ),
                )
              ],
            ),
          );
        });
  }

  void _settingModalReceiverBottomSheet(context) async {
    network = Provider.of<ConnectionStatus>(context);
    if (network == ConnectionStatus.offline) {
      isOffline = true;
    } else {
      setState(() {
        isOffline = false;
      });
    }
    ;
    if (!isOffline) {
      String authToken = AuthUtils.getToken(_sharedPreferences);
      var _storesResponse =
          await NetworkUtils.fetch(authToken, '/api/Members/contacts');
      if (mounted) {
        setState(() {
          _defaultReceivers = _storesResponse;
          isLoaded = true;
        });
      }
    }
    List<Widget> list = new List<Widget>();
    for (var i = 0; i < _defaultReceivers.length; i++) {
      dynamic _store = _defaultReceivers[i];
      _store['index'] = i;
      list.add(Column(
        children: <Widget>[
          new ListTile(
              leading: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    new Icon(
                      Icons.home,
                      textDirection: TextDirection.ltr,
                    )
                  ],
                ),
              ),
              title: new Text(_store['fullName']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(_store['address']),
                  SizedBox(
                    height: 2.0,
                  ),
                  Text(_store['phoneNumber'])
                ],
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
              onTap: () {
               
                _fullNameCustomerController.text = _store['fullName'];
                _phoneNumberCustomerController.text = _store['phoneNumber'];
                _addressCustomerController.text = _store['address'];
              
                //FocusScope.of(context).requestFocus(_fullNameFocusNode);
                
                setState(() {
                  _isErr = true;
                  selectedZone = _store['zone'];
                  zoneId = _store['zoneId'];
                  lat = _store['lat'];
                  lng = _store['lng'];
                  isGetReceiver = true;
                  _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                 // _isValidateNB =true;
                });

                Navigator.pop(context);
                // FocusScope.of(context).requestFocus(_fullNameFocusNode);
              }),
          Divider()
        ],
      ));
    }
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            padding: const EdgeInsets.only(top: 16.0),
            child: Column(
              children: <Widget>[
                Text(
                  allTranslations.text('list_receivers'),
                  style: TextStyle(
                      color: HexColor('#455A64'),
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Divider(
                  height: 1.0,
                ),
                Expanded(
                  flex: 1,
                  child: isOffline
                      ? OfflineNotification()
                      : SingleChildScrollView(
                          child: Column(
                            children: list,
                          ),
                        ),
                )
              ],
            ),
          );
        });
  }

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  Future<bool> _backPage() async {
    await _setPageTwoExist(false);
    await _setPageThreeExist(false);
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/main-shop', (Route<dynamic> route) => false);
    return false;
  }

  Future<bool> _isPageTwoExist() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isPageTwoExist') == null
        ? false
        : prefs.getBool('isPageTwoExist');
  }

  Future<bool> _isPageThreeExist() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isPageThreeExist') == null
        ? false
        : prefs.getBool('isPageThreeExist');
  }

  Future<bool> _setPageOneExist(bool isValue) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool('isPageOneExist', isValue);
  }

  Future<bool> _setPageTwoExist(bool isValue) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool('isPageTwoExist', isValue);
  }

  Future<bool> _setPageThreeExist(bool isValue) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool('isPageThreeExist', isValue);
  }

  @override
  Widget build(BuildContext context) {
    network = Provider.of<ConnectionStatus>(context);
    if (network == ConnectionStatus.offline) {
      isOffline = true;
    } else {
      setState(() {
        isOffline = false;
      });
    }
    ;
    return WillPopScope(
      onWillPop: _backPage,
      child: Scaffold(
          key: _scaffoldKey,
          body: Container(
              color: Color.fromRGBO(242, 242, 242, 1),
              child: Column(children: <Widget>[
                GradientAppBar(
                  title: allTranslations.text('create_package_title'),
                  hasBackIcon: true,
                  backtoShopHome: true,
                ),
                Expanded(
                    flex: 1,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        FocusScope.of(context).requestFocus(new FocusNode());
                      },
                      child: SingleChildScrollView(
                          controller: _scrollController,
                          scrollDirection: Axis.vertical,
                          child: Container(
                            padding: const EdgeInsets.only(
                                top: 20, left: 16, right: 16),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    new StepActive(
                                      index: 1,
                                    ),
                                    new DashActive(),
                                    FutureBuilder(
                                      future: //preference.isPageTwoExist(),
                                          _isPageTwoExist(),
                                      builder: (BuildContext context,
                                          AsyncSnapshot<bool> snapshot) {
                                        return snapshot.hasData && snapshot.data
                                            ? Row(
                                                children: <Widget>[
                                                  new DashActive(),
                                                  new StepLastActive(
                                                    index: 2,
                                                    current: 1,
                                                  ),
                                                  new DashActive()
                                                ],
                                              )
                                            : Row(
                                                children: <Widget>[
                                                  new DashInActive(),
                                                  new StepInActive(
                                                    index: 2,
                                                  ),
                                                  new DashInActive()
                                                ],
                                              );
                                      },
                                    ),
                                    FutureBuilder(
                                      future: _isPageThreeExist(),
                                      builder: (BuildContext context,
                                          AsyncSnapshot<bool> snapshot) {
                                        return snapshot.hasData && snapshot.data
                                            ? Row(
                                                children: <Widget>[
                                                  new DashActive(),
                                                  new StepLastActive(
                                                    index: 3,
                                                    current: 1,
                                                    onTap: () {},
                                                  )
                                                ],
                                              )
                                            : Row(
                                                children: <Widget>[
                                                  new DashInActive(),
                                                  new StepInActive(index: 3)
                                                ],
                                              );
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 20.0,
                                ),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(4.0)),
                                      color: Colors.white),
                                  
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          CircleAvatar(
                                            maxRadius: 32.0,
                                            backgroundColor: Color.fromRGBO(
                                                0, 153, 204, 0.1),
                                            child: Center(
                                              child: Image.asset(
                                                  'icons/store.png'),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 20.0,
                                          ),
                                          Text(
                                            allTranslations
                                                .text('shop_s_information'),
                                            style: TextStyle(
                                                color: HexColor('#455A64'),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18.0),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 35.0,
                                      ),
                                      Theme(
                                        data: new ThemeData(
                                            hintColor: HexColor('#DFE4EA')),
                                        child: TextField(
                                          onTap: () {
                                            _settingModalBottomSheet(context);
                                          },
                                          decoration: InputDecoration(
                                              hintText: allTranslations
                                                  .text('full_name'),
                                              hintStyle: TextStyle(
                                                  color: HexColor('#90A4AE'),
                                                  fontSize: 14),
                                              suffixIcon: Image.asset(
                                                  'icons/contact.png')),
                                          controller: _fullNameShopController,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 25.0,
                                      ),
                                      Theme(
                                        data: new ThemeData(
                                            hintColor: HexColor('#DFE4EA')),
                                        child: TextField(
                                          enabled: false,
                                          decoration: InputDecoration(
                                            hintText: allTranslations
                                                .text('form_phone_number'),
                                            hintStyle: TextStyle(
                                                color: HexColor('#90A4AE'),
                                                fontSize: 14),
                                          ),
                                          controller:
                                              _phoneNumberShopController,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 25.0,
                                      ),
                                      Theme(
                                        data: new ThemeData(
                                            hintColor: HexColor('#DFE4EA')),
                                        child: TextField(
                                          enabled: false,
                                          decoration: InputDecoration(
                                              hintText: allTranslations
                                                  .text('address'),
                                              hintStyle: TextStyle(
                                                  color: HexColor('#90A4AE'),
                                                  fontSize: 14),
                                              suffixIcon: Image.asset(
                                                  'icons/near-me.png')),
                                          controller: _addressShopController,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5.0,
                                      ),
                                      Opacity(
                                        opacity: 0.0,
                                        child: TextField(
                                            decoration: InputDecoration(
                                                hintText: allTranslations
                                                    .text('address'),
                                                hintStyle: TextStyle(
                                                    color: HexColor('#90A4AE'),
                                                    fontSize: 14),
                                                suffixIcon: Image.asset(
                                                    'icons/near-me.png')),
                                            controller: _storeIdController),
                                      ),
                                      SizedBox(
                                        height: 5.0,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 22.0,
                                ),
                                Container(
                                  width: double.infinity,
                                  // padding: const EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(4.0)),
                                      color: Colors.white),
                                  child :Form(
                                   // autovalidate: au,
                                    key: _formKey,
                                    onChanged: (){
                                      
                                      final RegExp phoneExp = RegExp(r'^0\d+$');
                                      if(!_isValid(_fullNameCustomerController.text)||
                                        !_isValid(_phoneNumberCustomerController.text)||
                                        !_isValid(_addressCustomerController.text)||
                                        _phoneNumberCustomerController.text.length < 9||
                                        !phoneExp.hasMatch(_phoneNumberCustomerController.text)
                                       ){
                                          setState(() {
                                        _isErr = false;
                                      });
                                      }else
                                        setState(() {
                                        _isErr =true;
                                      });
                                      
                                    },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      new CreatePackageTitle(
                                          icon: 'icons/user-package.png',
                                          title: 'receiver_s_information'),
                                      SizedBox(
                                        height: 15.0,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Theme(
                                          data: new ThemeData(
                                              hintColor: HexColor('#DFE4EA')),
                                          child: TextFormField(
                                            decoration: InputDecoration(
                                                hintText: allTranslations
                                                    .text('full_name'),
                                                hintStyle: TextStyle(
                                                    color: HexColor('#90A4AE'),
                                                    fontSize: 14),
                                                suffixIcon: InkWell(
                                                  onTap: () {
                                                    
                                                    _settingModalReceiverBottomSheet(
                                                        context);
                                                  },
                                                  child: Image.asset(
                                                      'icons/contact.png'),
                                                )),
                                            textCapitalization:
                                                TextCapitalization.words,
                                            textInputAction:
                                                TextInputAction.next,
                                            focusNode: _fullNameFocusNode,
                                            autovalidate: _autoValidName,
                                            validator: _validateFullnameCus,
                                            onFieldSubmitted: (value) {
                                              setState(() {
                                                isGetReceiver = false;
                                              });
                                              _fieldFocusChange(
                                                  context,
                                                  _fullNameFocusNode,
                                                  _phoneNumberFocusNode);
                                            },
                                            controller:
                                                _fullNameCustomerController,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5.0,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Theme(
                                          data: new ThemeData(
                                              hintColor: HexColor('#DFE4EA')),
                                          
                                            child: TextFormField(
                                            validator: _validatePhoneNumber,
                                            autovalidate: _autoValidPhone,
                                            inputFormatters: <
                                                TextInputFormatter>[
                                              BlacklistingTextInputFormatter(
                                                  new RegExp('[\\-|\\ ]')),
                                              WhitelistingTextInputFormatter
                                                  .digitsOnly,
                                              LengthLimitingTextInputFormatter(
                                                  11)
                                            ],
                                            decoration: InputDecoration(
                                              hintText: allTranslations
                                                  .text('form_phone_number'),
                                              hintStyle: TextStyle(
                                                  color: HexColor('#90A4AE'),
                                                  fontSize: 14),
                                            ),
                                            keyboardType: TextInputType.number,
                                            textInputAction:
                                                TextInputAction.next,
                                            focusNode: _phoneNumberFocusNode,
                                            onFieldSubmitted: isOffline
                                                ? (value) {
                                                    NetworkUtils.showSnackBar(
                                                        _scaffoldKey, null);
                                                  }
                                                : (value) async {
                                                    _phoneNumberFocusNode.unfocus();
                                                    _addressCustomerController.text='';
                                                    var result = await Navigator
                                                            .of(context)
                                                        .push(
                                                            new PageRouteBuilder(
                                                      pageBuilder:
                                                          (BuildContext context,
                                                              _, __) {
                                                        return ChooseOnMap(
                                                            isCreatePackage:
                                                                true);
                                                      },
                                                    ));
                                                  
                                                    resultSelectedZone = result;
                                                    if (result != null) {
                                                      _addressCustomerController
                                                              .text =
                                                          result[
                                                              'chosenAddress'];
                                                      setState(() {
                                                        selectedZone = result[
                                                            'selectedZone'];
                                                        lat = result['lat'];
                                                        lng = result['lng'];
                                                        isGetReceiver = false;
                                                      });
                                                    }
                                                  },
                                            controller:
                                                _phoneNumberCustomerController,
                                          ),
                                          
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5.0,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Theme(
                                          data: new ThemeData(
                                              hintColor: HexColor('#DFE4EA')),
                                          child: TextField(
                                            decoration: InputDecoration(
                                                hintText: allTranslations
                                                    .text('address'),
                                                hintStyle: TextStyle(
                                                    color: HexColor('#90A4AE'),
                                                    fontSize: 14),
                                                suffixIcon: Image.asset(
                                                    'icons/near-me.png')),
                                            controller:
                                                _addressCustomerController,
                                            onTap: isOffline
                                                ? () {
                                                    NetworkUtils.showSnackBar(_scaffoldKey, null);
                                                    print("offline");
                                                  }
                                                : () async {
                                                    var result = await Navigator
                                                            .of(context)
                                                        .push(
                                                            new PageRouteBuilder(
                                                      pageBuilder:
                                                          (BuildContext context,
                                                              _, __) {
                                                        return ChooseOnMap(
                                                            isCreatePackage:
                                                                true);
                                                      },
                                                    ));
                                                       
                                                    if (result != null) {
                                                      _addressCustomerController
                                                              .text =
                                                          result[
                                                              'chosenAddress'];
                                                      setState(() {
                                                        selectedZone = result[
                                                            'selectedZone'];
                                                        lat = result['lat'];
                                                        lng = result['lng'];
                                                        isGetReceiver = false;
                                                      });
                                                    }
                                                  },
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Checkbox(
                                            value: _isSaveContact,
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                            onChanged: !isGetReceiver
                                                ? (bool value) {
                                                    setState(() {
                                                      _isSaveContact = value;
                                                    });
                                                  }
                                                : null,
                                          ),
                                          Text(
                                            allTranslations
                                                .text('save_this_contact'),
                                            style: TextStyle(
                                                color: !isGetReceiver
                                                    ? HexColor('#455A64')
                                                    : Colors.grey,
                                                fontSize: 14.0),
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: RaisedButton(
                                          onPressed: _valid() && _validatePhoneNumber(_phoneNumberCustomerController.text)==null
                                              ? () async {
                                                  _setPageOneExist(true);
                                                  SharedPreferences pref =
                                                      await _prefs;
                                                  // pref.setStringList(key, value)
                                                  dynamic obj = {
                                                    'isSaveContact':
                                                        _isSaveContact,
                                                    'shopInformation': {
                                                      'name':
                                                          _fullNameShopController
                                                              .text,
                                                      'phoneNumber':
                                                          _phoneNumberShopController
                                                              .text,
                                                      'address':
                                                          _addressShopController
                                                              .text,
                                                      'id': _storeIdController
                                                          .text
                                                    },
                                                    'receiverInformation': {
                                                      'fullName':
                                                          _fullNameCustomerController
                                                              .text,
                                                      'phoneNumber':
                                                          _phoneNumberCustomerController
                                                              .text,
                                                      'address':
                                                          _addressCustomerController
                                                              .text,
                                                      'zoneId':
                                                          selectedZone['id'],
                                                      //'zoneId': zoneId,

                                                      'lat': lat,
                                                      'lng': lng
                                                    },
                                                    'zoneInformation':
                                                        selectedZone
                                                  };

                                                  //
                                                  String pageOneData =
                                                      jsonEncode(obj);
                                                  await pref.setString(
                                                      'dataPageOne',
                                                      pageOneData);
                                                  //  print(pageOneData);
                                                  Navigator.of(context)
                                                      .pushReplacement(
                                                          new PageRouteBuilder(
                                                    pageBuilder:
                                                        (BuildContext context,
                                                            _, __) {
                                                      return CreatePackageInformation(
                                                        zoneInformation: obj[
                                                            'zoneInformation'],
                                                      );
                                                    },
                                                  ));
                                                }
                                              : null,
                                          disabledColor: HexColor('#B0BEC5'),
                                          disabledTextColor: Colors.white,
                                          color:
                                              Color.fromRGBO(253, 134, 39, 1),
                                          textColor: Colors.white,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 16),
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10))),
                                            child: Center(
                                              child: Text(
                                                  allTranslations
                                                      .text('next')
                                                      .toUpperCase(),
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                                  ),//
                                )
                              ],
                            ),
                          )),
                    )),
              ]))),
    );
  }
}

class StepInActive extends StatelessWidget {
  const StepInActive({Key key, this.index}) : super(key: key);

  final int index;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: HexColor('#DFE4EA'),
      maxRadius: 16.0,
      child: Text(
        index.toString(),
        style: TextStyle(
            color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class StepLastActive extends StatefulWidget {
  const StepLastActive({Key key, this.index, this.current, this.onTap})
      : super(key: key);

  final int index;
  final int current;
  final Function onTap;

  @override
  _StepLastActiveState createState() => _StepLastActiveState();
}

class _StepLastActiveState extends State<StepLastActive> {
  Future<String> _getJsonDataPageOne() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('dataPageOne') ?? '';
  }

  pageCreatePackage(bool type) {
    if (type) {
      Navigator.of(context).push(
          new PageRouteBuilder(pageBuilder: (BuildContext context, _, __) {
        return CreatePackage();
      }));
    } else {
      Navigator.of(context).pushReplacement(
          new PageRouteBuilder(pageBuilder: (BuildContext context, _, __) {
        return CreatePackage();
      }));
    }
  }

  pageCreatePackageInfo(bool type) async {
    var dataPage2 = await _getJsonDataPageOne();
    // print(dataPage2);
    var obj = jsonDecode(dataPage2);
    if (type) {
      Navigator.of(context).push(new PageRouteBuilder(
        pageBuilder: (BuildContext context, _, __) {
          return CreatePackageInformation(
            zoneInformation: obj['zoneInformation'],
          );
        },
      ));
    } else {
      Navigator.of(context).pushReplacement(new PageRouteBuilder(
        pageBuilder: (BuildContext context, _, __) {
          return CreatePackageInformation(
            zoneInformation: obj['zoneInformation'],
          );
        },
      ));
    }
  }

  pageCreatePackageService() async {
    var dataPage2 = await _getJsonDataPageOne();
    //print(dataPage2);
    var obj = jsonDecode(dataPage2);
    Navigator.of(context).pushReplacement(
        new PageRouteBuilder(pageBuilder: (BuildContext context, _, __) {
      return CreatePackageServices(
        zoneInformation: obj['zoneInformation'],
      );
    }));
  }

  _onTap(int index, int current) async {
    bool push = true;
    bool replacement = false;
    switch (index) {
      case 1:
        if (current == 2) {
          widget.onTap();
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool("isPageTwoExist", true);
          pageCreatePackage(false);
        } else if (current == 3) {
          pageCreatePackage(true);
        }
        break;
      case 2:
        if (current == 1) {
          pageCreatePackageInfo(false);
        } else if (current == 3) {
          pageCreatePackageInfo(true);
        }
        break;
      case 3:
        if (current == 1) {
          Navigator.of(context).pop();
        }
        if (current == 2) {
          Navigator.of(context).pop();
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    int index = widget.index;
    int current = widget.current;

    return InkWell(
      onTap: () {
        print(
            "index: " + index.toString() + ", current: " + current.toString());
        _onTap(index, current);
      },
      child: CircleAvatar(
        backgroundColor: HexColor('#FF9933'),
        maxRadius: 16.0,
        child: Text(
          index.toString(),
          style: TextStyle(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    ); //1
  }
}
// class StepLastActive extends StatelessWidget {
//   const StepLastActive({Key key, this.index}) : super(key: key);

//   final int index;

//   @override
//   Widget build(BuildContext context) {

//   }
// }

class StepActive extends StatelessWidget {
  const StepActive({Key key, this.index}) : super(key: key);

  final int index;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: CircleAvatar(
        backgroundColor: Color.fromRGBO(255, 153, 51, 0.5),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: CircleAvatar(
            backgroundColor: HexColor('#FF9933'),
            child: Text(
              index.toString(),
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

class DashInActive extends StatelessWidget {
  const DashInActive({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20.0,
      height: 0.0,
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: HexColor('#DFE4EA'), width: 2.0))),
    );
  }
}

class DashActive extends StatelessWidget {
  const DashActive({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20.0,
      height: 0.0,
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: HexColor('#FF9933'), width: 2.0))),
    );
  }
}
