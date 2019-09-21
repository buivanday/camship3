import 'package:farax/components/gradient_appbar.dart';
import 'package:farax/components/hex_color.dart';
import 'package:farax/utils/auth_utils.dart';
import 'package:farax/utils/network_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

import '../../all_translations.dart';
import '../choose_on_map.dart';
import 'address_book.dart';

class AddAddressBook extends StatefulWidget {
  const AddAddressBook(
      {Key key,
      this.isReturnedFromChooseMap = false,
      this.oldData,
      this.chosenAddress = '',
      this.lat,
      this.lng})
      : super(key: key);

  final bool isReturnedFromChooseMap;
  final dynamic oldData;
  final String chosenAddress;
  final dynamic lat;
  final dynamic lng;

  @override
  _AddAddressBookState createState() => _AddAddressBookState();
}

class _AddAddressBookState extends State<AddAddressBook> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences _sharedPreferences;
  bool _isDefaultAddress = false;
  var _shopNameController = new TextEditingController();
  var _phoneNumberController = new TextEditingController();
  var _addressController = new TextEditingController();
  var _lat, _lng;
  final FocusNode _fullNameFocusNode = FocusNode();
  final FocusNode _phoneNumberFocusNode = FocusNode();
  final FocusNode _addressFocusNode = FocusNode();
  bool isValidNumberPhone = false;
  bool isErr = false;
  dynamic selectedZone;
  double lat;
  double lng;

  @override
  void initState() {
    super.initState();
    _fetchSessionAndNavigate();
    _focusPhoneNumberListener();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _fetchSessionAndNavigate() async {
    _sharedPreferences = await _prefs;
    String authToken = AuthUtils.getToken(_sharedPreferences);

    if (authToken == null) {
      _logout();
    } else {
      if (widget.isReturnedFromChooseMap == true) {
        _phoneNumberController.text = widget.oldData['phoneNumber'];
        _shopNameController.text = widget.oldData['shopName'];
        _addressController.text = widget.chosenAddress;
        _lat = widget.lat;
        _lng = widget.lng;
      }
    }
  }

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  bool _isValid(String variable) {
    return variable != null && variable != '' && variable.isNotEmpty;
  }

  bool _valid() {
    String _shopFullName = _shopNameController.text;
    String _shopPhoneNumber = _phoneNumberController.text;
    String _shopAddress = _addressController.text;
    return _isValid(_shopFullName) &&
        _isValid(_shopPhoneNumber) &&
        _isValid(_shopAddress) &&
        _validatePhoneNumber(_shopPhoneNumber)==null;
  }

  _logout() {
    NetworkUtils.logoutUser(_scaffoldKey.currentContext, _sharedPreferences);
  }

  Future _saveAddressBook() async {
    String authToken = AuthUtils.getToken(_sharedPreferences);
    var saveAddressBookResponse =
        await NetworkUtils.postWithBody(authToken, '/api/Members/store', {
      'name': _shopNameController.text,
      'phoneNumber': _phoneNumberController.text,
      'address': _addressController.text,
      'lat': lat,
      'lng': lng,
      'isPrimary': _isDefaultAddress
    });

    if (saveAddressBookResponse != null) {
      Navigator.pop(context);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => AddressBook(
                    isAddedSuccessfully: true,
                  )));
    }
  }

  _onTapMap() async {
    var result = await Navigator.of(context).push(new PageRouteBuilder(
      pageBuilder: (BuildContext context, _, __) {
        return ChooseOnMap(isCreatePackage: true);
      },
    ));
    if (result != null) {
      _addressController.text =
          result['chosenAddress'] == null ? '' : result['chosenAddress'];
      setState(() {
        selectedZone = result['selectedZone'];
        lat = result['lat'];
        lng = result['lng'];
      });
    }
  }

   String _validatePhoneNumber(String value){
     final RegExp phoneExp = RegExp(r'^0\d+$');//RegExp(r'/^0(1\d{9}|9\d{8})$/');
    if(value.length==0||value.trim()=='') return null;
    if(value.length<9){
      return 'Mobile number must be at least 10 digit';
    }
    else if(!phoneExp.hasMatch(value)){ 
      return 'Mobile number must be format 0xxx';
    }
    
    return null;
  }

  _focusPhoneNumberListener() {
    _phoneNumberFocusNode.addListener(() {
      String value = _phoneNumberController.text;
      final RegExp phoneExp = RegExp(r'^0\d+$');
      bool isAutoValid = false;
      if (_phoneNumberFocusNode.hasFocus) {
        isAutoValid = true;
      } else {
        isAutoValid = false;
      }
      setState(() {
        isValidNumberPhone = isAutoValid;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      body: Container(
        child: Column(
          children: <Widget>[
            GradientAppBar(
                title: allTranslations.text('add_address'),
                hasBackIcon: true,
                closeIcon: true),
            Expanded(
                flex: 1,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    FocusScope.of(context).requestFocus(new FocusNode());
                  },
                  child: Container(
                    // scrollDirection: Axis.vertical,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          color: Colors.white,
                          child: Theme(
                            data: new ThemeData(hintColor: HexColor('#DFE4EA')),
                            child :Form(
                              onChanged: (){
                                setState(() {
                                  isErr = _valid();
                                });
                                
                                print(isErr);
                              },
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                  height: 41.0,
                                ),
                                TextFormField(
                                  focusNode: _fullNameFocusNode,
                                  textInputAction: TextInputAction.next,
                                  onFieldSubmitted: (value) {
                                    _fieldFocusChange(
                                        context,
                                        _fullNameFocusNode,
                                        _phoneNumberFocusNode);
                                  },
                                  decoration: InputDecoration(
                                    labelText:
                                        allTranslations.text('shop_name'),
                                    labelStyle: TextStyle(
                                        color: HexColor('#90A4AE'),
                                        fontSize: 14),
                                  ),
                                  controller: _shopNameController,
                                  style: TextStyle(color: HexColor('#455A64')),
                                ),
                                SizedBox(
                                  height: 41.0,
                                ),
                                TextFormField(
                                  key: _formKey,
                                  focusNode: _phoneNumberFocusNode,
                                  textInputAction: TextInputAction.next,
                                  autovalidate: isValidNumberPhone,
                                  validator: _validatePhoneNumber,
                                  controller: _phoneNumberController,
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(color: HexColor('#455A64')),
                                  inputFormatters: <TextInputFormatter>[
                                    BlacklistingTextInputFormatter(
                                        new RegExp('[\\-|\\ ]')),
                                    WhitelistingTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(11)
                                  ],
                                  onFieldSubmitted: //_isValidNP? (value){} :
                                      (value) async {
                                    _phoneNumberFocusNode.unfocus();
                                    _onTapMap();

                                  },
                                  decoration: InputDecoration(
                                    labelText: allTranslations
                                        .text('form_phone_number'),
                                    labelStyle: TextStyle(
                                        color: HexColor('#90A4AE'),
                                        fontSize: 14),
                                  ),
                                ),
                                SizedBox(
                                  height: 41.0,
                                ),
                                Theme(
                                  data: new ThemeData(
                                      hintColor: HexColor('#DFE4EA')),
                                  child: TextField(
                                    onTap: () {
                                      _onTapMap();
                                    },
                                    decoration: InputDecoration(
                                      labelText:
                                          allTranslations.text('address'),
                                      labelStyle: TextStyle(
                                          color: HexColor('#B0BEC5'),
                                          fontSize: 14),
                                      suffixIcon: InkWell(
                                        onTap: () {
                                          // _onTapMap();
                                        },
                                        child: Transform.rotate(
                                          angle: 0.75,
                                          child: Icon(
                                            Icons.navigation,
                                            color:
                                                Color.fromRGBO(21, 166, 212, 1),
                                            size: 24.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                    controller: _addressController,
                                    style:
                                        TextStyle(color: HexColor('#455A64')),
                                  ),
                                ),
                                SizedBox(
                                  height: 28.0,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Checkbox(
                                      value: _isDefaultAddress,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      onChanged: (bool value) {
                                        setState(() {
                                          _isDefaultAddress = value;
                                        });
                                      },
                                    ),
                                    Text(
                                      allTranslations
                                          .text('make_default_address'),
                                      style: TextStyle(
                                          color: HexColor('#455A64'),
                                          fontSize: 14.0),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 28,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(1), //16
                                  child: RaisedButton(
                                    disabledColor: HexColor('#B0BEC5'),
                                    disabledTextColor: Colors.white,
                                    onPressed:
                                        _valid() || isErr? _saveAddressBook : null,
                                    color: Color.fromRGBO(253, 134, 39, 1),
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
                                                .text('save')
                                                .toUpperCase(),
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),)
                          )),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
