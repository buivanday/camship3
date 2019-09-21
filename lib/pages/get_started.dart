import 'package:farax/components/hex_color.dart';
import 'package:farax/utils/network_utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../components/gradient_appbar.dart';
import '../all_translations.dart';
import 'choose_on_map.dart';
import 'login.dart';
import 'package:flutter/services.dart';

class GetStarted extends StatefulWidget {
  const GetStarted({
    Key key,
    this.oldData,
    this.isReturnedFromChooseMap = false,
    this.chosenAddress,
    this.lat,
    this.lng
  }) : super(key: key);

  final Map<String, dynamic> oldData;
  final bool isReturnedFromChooseMap;
  final String chosenAddress;
  final double lat;
  final double lng;
  @override
  _GetStartedState createState() => _GetStartedState();
}

class _GetStartedState extends State<GetStarted> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var _fullNameController = new TextEditingController(),
      _phoneNumberController = new TextEditingController(),
      _addressController = new TextEditingController();
  var _passwordController = new TextEditingController(),
      _confirmPasswordController = new TextEditingController();
  bool _isFemale = false;
  bool _isMale = false;
  double _lat;
  double _lng;
  dynamic selectedZone;
  double lat;
  double lng;
  bool _obscureConfirmPassword = true;
  bool _obscureText = true;
  bool isErr =false;
  bool _autoValidPhone = false;
  bool _showWaiting =false;
  String iconSuccess = "icons/bill-alert-icon-title.png";
  String iconFail = "icons/icon-2.png";
  
  final FocusNode _fullNameFocusNode = FocusNode();
  final FocusNode _phoneNumberFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPaswordFocusNode = FocusNode();
  final FocusNode _addressFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _fetchSessionAndNavigate();
    //_focusPhoneNumberListener();
  }
  @override
  void dispose(){
    super.dispose();
    //_phoneNumberFocusNode.dispose();
  }
  
  _fetchSessionAndNavigate() async {
    if (widget.isReturnedFromChooseMap == true) {
      _fullNameController.text = widget.oldData['fullName'];
      _phoneNumberController.text = widget.oldData['phoneNumber'];
      _passwordController.text = widget.oldData['password'];
      _confirmPasswordController.text = widget.oldData['confirmPassword'];
      _addressController.text = widget.chosenAddress;
      _isFemale = widget.oldData['_isFemale'];
      _isMale = widget.oldData['_isMale'];
      _lat = widget.lat;
      _lng = widget.lng;
    }
  }

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  Future _register() async {
    String authToken = '';
    var responseRegister = await NetworkUtils.postWithBody(
        authToken, '/api/Members/shop-register', {
      'fullName': _fullNameController.text,
      'phoneNumber': _phoneNumberController.text,
      'password': _passwordController.text,
      'gender': _isFemale != null && _isFemale
          ? false
          : (_isMale != null && _isMale ? true : null),
      'address': _addressController.text,
      'lat': lat,
      'lng': lng
    });

    if (responseRegister == null) {
      NetworkUtils.showSnackBar(
          _scaffoldKey, allTranslations.text('something_went_wrong'));
    } else if (responseRegister == 'NetworkError') {
      NetworkUtils.showSnackBar(_scaffoldKey, null);
    } else if (responseRegister['error'] != null) {
      int statusCode = responseRegister['error']['statusCode'];

      if (statusCode == 422) {
        dynamic details = responseRegister['error']['details'];
        dynamic codes = details['codes'];
        if (codes['username'] != null) {
          List<dynamic> errors = codes['username'];
          if (errors.contains('uniqueness')) {
            _showDialog(allTranslations.text('error_phone_number_exist'),iconFail,_registerFailed);
            
            // NetworkUtils.showSnackBar(
            //     _scaffoldKey, allTranslations.text('error_phone_number_exist'));
          } else {
             _showDialog(allTranslations.text('register_failed'),iconFail,_registerFailed);
            
            // NetworkUtils.showSnackBar(
            //     _scaffoldKey, allTranslations.text('register_failed'));
          }
        } else {
           _showDialog(allTranslations.text('register_failed'),iconFail,_registerFailed);
            
          // NetworkUtils.showSnackBar(
          //     _scaffoldKey, allTranslations.text('register_failed'));
        }
      } else {
         _showDialog(allTranslations.text('register_failed'),iconFail,_registerFailed);
            
        // NetworkUtils.showSnackBar(
        //     _scaffoldKey, allTranslations.text('register_failed'));
      }
    } else {
        _showDialog(allTranslations.text('register_successfully'),iconSuccess,_successOK);
        // NetworkUtils.showSnackBar(
        //   _scaffoldKey, allTranslations.text('register_successfully'));
         
     // Navigator.pushReplacementNamed(context, '/login');
    }
    
  }
  void _showDialog(String title,String icon,Function onTap){
    setState(() {
     _showWaiting = true; 
    });
    showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context)=>new DialogConfirmGetStarted(title: title,icon: icon,onTap: onTap,),
    );
  }
   _successOK(){
    Navigator.pushReplacementNamed(context, '/login');
  }
   _registerFailed(){
      Navigator.of(context).pop();
    }

  bool _valid() {
    String  fullName = _fullNameController.text;
    String  numberPhone = _phoneNumberController.text;
    String pwd = _passwordController.text;
    String rePwd = _confirmPasswordController.text;
    String address = _addressController.text;

    return _isValid(fullName) &&
        _isValid(numberPhone) &&
        _isValid(pwd) &&
        _isValid(address)&&
        _isValid(rePwd)&&
        _validatePhoneNumber(numberPhone)==null; 
  }
  bool _isValid(String variable) {
    return variable != null && variable != '' && variable.isNotEmpty;
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
  _focusPhoneNumberListener(){
    _phoneNumberFocusNode.addListener((){
      bool isAutoValid = false;
      _phoneNumberFocusNode.hasFocus? isAutoValid = false : isAutoValid = true;
      setState(() {
       _autoValidPhone= isAutoValid; 
      });
    });
  }
  _onTapMap()async{
     var result = await Navigator.of(context)
        .push(new PageRouteBuilder(
      pageBuilder: (BuildContext context, _, __) {
        return ChooseOnMap(isCreatePackage: true);
      },
    ));
    if(result==null)
      _addressController.text = '';
    else{
    _addressController.text =
        result['chosenAddress']==null? '':result['chosenAddress'];
    setState(() {
      selectedZone = result['selectedZone'];
      lat = result['lat'];
      lng = result['lng'];
    });}
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: Container(
          child: Column(
            children: <Widget>[
              GradientAppBar(
                  title: allTranslations.text('get_started'),
                  hasBackIcon: true),
              Expanded(
                flex: 3,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    FocusScope.of(context).requestFocus(new FocusNode());
                  },
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 38.0),
                    child: Form(
                      onChanged: (){
                        print(_valid());
                        setState(() {
                         isErr = _valid(); 
                        });
                      },
                      autovalidate: true,
                      child: Column(
                        children: <Widget>[
                          Theme(
                            data: new ThemeData(hintColor: HexColor('#DFE4EA')),
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText:allTranslations.text('full_name'),
                                labelStyle: TextStyle(
                                    color: HexColor('#B0BEC5'), fontSize: 14),
                              ),
                              textInputAction: TextInputAction.next,
                              textCapitalization: TextCapitalization.words,
                              onFieldSubmitted: (value) {
                                _fieldFocusChange(context, _fullNameFocusNode,
                                    _phoneNumberFocusNode);
                              },
                              focusNode: _fullNameFocusNode,
                              controller: _fullNameController,
                            ),
                          ),
                          SizedBox(height: 20),
                          Theme(
                           
                            data: new ThemeData(hintColor: HexColor('#DFE4EA')),
                            child: TextFormField(                              
                              autovalidate: _autoValidPhone,
                              validator: _validatePhoneNumber,
                               inputFormatters:<TextInputFormatter>
                               [BlacklistingTextInputFormatter(new RegExp('[\\-|\\ ]')),
                                WhitelistingTextInputFormatter.digitsOnly,
                               
                                LengthLimitingTextInputFormatter(11)
                                ],
                              focusNode: _phoneNumberFocusNode,
                              decoration: InputDecoration(
                                labelText:
                                    allTranslations.text('form_phone_number'),
                                labelStyle: TextStyle(
                                    color: HexColor('#B0BEC5'), fontSize: 14),
                              ),
                              keyboardType: TextInputType.number,
                              onFieldSubmitted: (value) {
                                _fieldFocusChange(context, _phoneNumberFocusNode,
                                    _passwordFocusNode);
                              },
                              textInputAction: TextInputAction.next,
                              controller: _phoneNumberController,
                              style: TextStyle(color: HexColor('#455A64')),
                            ),
                          ),
                          SizedBox(height: 20),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: HexColor('#DFE4EA')),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(60.0))),
                              width: 172.0,
                              height: 40.0,
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 1,
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _isMale = !_isMale;
                                          _isFemale = false;
                                        });
                                      },
                                      child: Container(
                                        decoration: _isMale == true
                                            ? BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(60.0)),
                                                gradient: LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    stops: [
                                                      0.11,
                                                      0.75
                                                    ],
                                                    colors: [
                                                      HexColor('#00C9E8'),
                                                      HexColor('#0099CC')
                                                    ]),
                                                boxShadow: [
                                                    BoxShadow(
                                                        color: Color.fromRGBO(
                                                            0, 0, 0, 0.12),
                                                        blurRadius: 8.0,
                                                        spreadRadius: 2.0)
                                                  ])
                                            : BoxDecoration(),
                                        child: Center(
                                          child: Text(
                                            'Male',
                                            style: TextStyle(
                                                color: _isMale == true
                                                    ? Colors.white
                                                    : HexColor('#78909C'),
                                                fontSize: 14.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _isFemale = !_isFemale;
                                          _isMale = false;
                                        });
                                      },
                                      child: Container(
                                        decoration: _isFemale == true
                                            ? BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(60.0)),
                                                gradient: LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    stops: [
                                                      0.11,
                                                      0.75
                                                    ],
                                                    colors: [
                                                      HexColor('#00C9E8'),
                                                      HexColor('#0099CC')
                                                    ]),
                                                boxShadow: [
                                                    BoxShadow(
                                                        color: Color.fromRGBO(
                                                            0, 0, 0, 0.12),
                                                        blurRadius: 8.0,
                                                        spreadRadius: 2.0)
                                                  ])
                                            : BoxDecoration(),
                                        child: Center(
                                          child: Text(
                                            'Female',
                                            style: TextStyle(
                                                color: _isFemale == true
                                                    ? Colors.white
                                                    : HexColor('#78909C'),
                                                fontSize: 14.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Theme(
                            data: new ThemeData(hintColor: HexColor('#DFE4EA')),
                            child: TextFormField(
                              focusNode: _passwordFocusNode,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: allTranslations.text('password'),
                                labelStyle: TextStyle(
                                    color: HexColor('#B0BEC5'), fontSize: 14),
                                suffixIcon: GestureDetector(
                                  dragStartBehavior: DragStartBehavior.down,
                                  onTap: () {
                                    setState(() {
                                      _obscureText = !_obscureText;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Icon(
                                      _obscureText ? Icons.visibility_off : Icons.visibility,
                                      semanticLabel: _obscureText ? 'show password' : 'hide password',
                                    ),
                                  ),
                                ),
                              ),
                              obscureText: _obscureText,
                              onFieldSubmitted: (value) {
                                _fieldFocusChange(context, _passwordFocusNode,
                                    _confirmPaswordFocusNode);
                              },
                              controller: _passwordController,
                              style: TextStyle(color: HexColor('#455A64')),
                            ),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Theme(
                            data: new ThemeData(hintColor: HexColor('#DFE4EA')),
                            child: TextFormField(
                              textInputAction: TextInputAction.next,
                              focusNode: _confirmPaswordFocusNode,
                              onFieldSubmitted: (value) {
                                _confirmPaswordFocusNode.unfocus();
                                _onTapMap();
                              },
                              validator: (String arg) {
                                if(arg != _passwordController.text)
                                  return 'Password must be equal to confirm password';
                                else
                                  return null;
                              },
                              decoration: InputDecoration(
                                labelText:
                                    allTranslations.text('confirm_password'),
                                labelStyle: TextStyle(
                                    color: HexColor('#B0BEC5'), fontSize: 14),
                                suffixIcon: GestureDetector(
                                  dragStartBehavior: DragStartBehavior.down,
                                  onTap: () {
                                    setState(() {
                                      _obscureConfirmPassword = !_obscureConfirmPassword;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                    child: Icon(
                                      
                                      _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                      semanticLabel: _obscureConfirmPassword ? 'show password' : 'hide password',
                                    ),
                                  ),
                                ),
                              ),
                              obscureText: _obscureConfirmPassword,
                              controller: _confirmPasswordController,
                              style: TextStyle(color: HexColor('#455A64')),
                            ),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Theme(
                            data: new ThemeData(hintColor: HexColor('#DFE4EA')),
                            child: TextField(
                              onTap: _onTapMap,
                              decoration: InputDecoration(
                                labelText: allTranslations.text('address'),
                                labelStyle: TextStyle(
                                    color: HexColor('#B0BEC5'), fontSize: 14),
                                suffixIcon: InkWell(
                                  child: Transform.rotate(
                                    angle: 0.75,
                                    child: Icon(
                                      Icons.navigation,
                                      color: Color.fromRGBO(21, 166, 212, 1),
                                      size: 24.0,
                                    ),
                                  ),
                                ),
                              ),
                              controller: _addressController,
                              style: TextStyle(color: HexColor('#455A64')),
                            ),
                          ),
                          SizedBox(
                            height: 25.0,
                          ),
                        ],
                      ),
                    )
                  ),
                ),
              ),
              Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: 10.0,
                          ),
                          RaisedButton(
                            onPressed: _valid()||isErr ?  _register : null,
                            color: Color.fromRGBO(253, 134, 39, 1),
                            textColor: Colors.white,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              child: Center(
                                child: Text(
                                    allTranslations
                                        .text('register')
                                        .toUpperCase(),
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Text(
                            allTranslations.text('register_agree_term'),
                            style: TextStyle(color: HexColor('#78909C')),
                          ),
                          Text(
                            allTranslations.text('term_of_services'),
                            style: TextStyle(color: HexColor('#0099CC')),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                allTranslations.text('already_have_account'),
                                style: TextStyle(color: HexColor('#78909C')),
                              ),
                              InkWell(
                                onTap: () {
                                 
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  allTranslations.text('sign_in'),
                                  style: TextStyle(color: HexColor('#0099CC')),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ))
            ],
          ),
        ));
  }
}

class DialogConfirmGetStarted extends StatefulWidget {
  const DialogConfirmGetStarted({Key key,this.title,this.icon,this.onTap }) : super(key:key);
  final String title;
  final String icon;
  final Function onTap;
  @override
  _DialogConfirmGetStartedState createState() => _DialogConfirmGetStartedState();
}

class _DialogConfirmGetStartedState extends State<DialogConfirmGetStarted> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async=>false,
      child: Center(
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5.0))
          ),
          contentPadding: const EdgeInsets.all(20.0),
          backgroundColor: Colors.white,
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Image.asset(widget.icon),
              SizedBox(width :16),
              Expanded(
                child: Text(widget.title + '!',
                textAlign: TextAlign.center,
                maxLines: 2,   
                style: TextStyle(
                  color: Color.fromRGBO(20, 156, 206, 1),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              )  
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                SizedBox(height: 20.0,),
                InkWell(
                  onTap:(){
                    widget.onTap();
                  } 
                    ,
                  child: Container(
                    width: 146,
                    height: 42,
                    decoration: BoxDecoration(
                      color: HexColor('#FF9933'),
                      borderRadius: BorderRadius.all(Radius.circular(4.0))
                    ),
                    child: Center(
                      child: Text(allTranslations.text('ok').toUpperCase(), style: TextStyle(fontSize: 14.0,color: Colors.white,fontWeight: FontWeight.bold )),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}