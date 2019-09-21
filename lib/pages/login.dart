import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../components/gradient_appbar.dart';
import '../all_translations.dart';
import '../utils/auth_utils.dart';
import '../utils/network_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info/device_info.dart';
import 'dart:io' show Platform;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:farax/services/connectivity.dart';

import 'get_started.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState>_formKey = new GlobalKey<FormState>();
	Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
	SharedPreferences _sharedPreferences;
  bool _isLoading = false;
  bool _obscureText = false;
  bool _isValidNumberPhone = false;
  dynamic device;
  TextEditingController _emailController, _passwordController;
  String _emailError, _passwordError;
  final FocusNode _passwordFocusNode = FocusNode(); 
  final FocusNode _phoneNumberFocusNode = FocusNode();
  String pattern = r'[0-9]';

  
  @override
	void initState() {
		super.initState();
		_fetchSessionAndNavigate();
		_emailController = new TextEditingController();
		_passwordController = new TextEditingController();
    _focusPhoneNumberListener();
	}
  @override
 void dispose(){
   super.dispose();
   _phoneNumberFocusNode.dispose();
  }
  _fetchSessionAndNavigate() async {
		_sharedPreferences = await _prefs;
		DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if(Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      device = {
        'os': 'Android',
        'deviceId': androidInfo.androidId,
        'model': androidInfo.model,
        'manufacturer': androidInfo.manufacturer,
        'registrationToken': _sharedPreferences.getString('registrationToken')
      };
    } else if(Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      device = {
        'os': 'iOS',
        'model': iosInfo.model,
        'name': iosInfo.name,
        'systemVersion': iosInfo.systemVersion,
        'registrationToken': _sharedPreferences.getString('registrationToken')
      };
    }
	}

  _valid() {
		bool valid = true;

		if(_emailController.text.isEmpty) {
			valid = false;
			_emailError = allTranslations.text("phone_number_required");
		}
    if(_emailController.text.length<9){
      valid = false;
			_emailError = allTranslations.text("phone_number_required");
    }
		if(_passwordController.text.isEmpty) {
			valid = false;
			_passwordError = allTranslations.text('password_required');
		}

		return valid;
	}
  String _validatePhoneNumber(String value){
     final RegExp phoneExp = RegExp(r'^0\d+$');//RegExp(r'/^0(1\d{9}|9\d{8})$/');
    
    if(value.length<9)
      return 'Mobile number must be at least 10 digit';
    else if(!phoneExp.hasMatch(value)){
      print(phoneExp.hasMatch(value));
      return 'Mobile number must be format 0xxxxxxxxx';
    }
    return null;
  }
  _signIn(BuildContext context) async {
    _showLoading();
    if(_valid()) {
			var responseJson = await NetworkUtils.authenticateUser(
				_emailController.text, _passwordController.text
			);
			if(responseJson == null) {

				NetworkUtils.showSnackBar(_scaffoldKey, allTranslations.text('something_went_wrong'));

			} else if(responseJson == 'NetworkError') {

				NetworkUtils.showSnackBar(_scaffoldKey, null);

			} else if(responseJson['error'] != null) {

				NetworkUtils.showSnackBar(_scaffoldKey, allTranslations.text('login_failed'));

			} else {

				AuthUtils.insertDetails(_sharedPreferences, responseJson);

        var updatedResponse = await NetworkUtils.patch(
          responseJson['id'], '/api/Members/${responseJson['user']['id']}', {
            'device': device
          }
        );

        if(updatedResponse == null) {
          NetworkUtils.showSnackBar(_scaffoldKey, allTranslations.text('something_went_wrong'));
        } else if(responseJson == 'NetworkError') {

          NetworkUtils.showSnackBar(_scaffoldKey, null);

        } else if(responseJson['error'] != null) {
          NetworkUtils.showSnackBar(_scaffoldKey, allTranslations.text('login_failed'));

        } else {
          if(responseJson['user'] != null && responseJson['user']['roleId'] == 4) {
            Navigator.of(context)
              .pushNamedAndRemoveUntil('/main-shop', (Route<dynamic> route) => false);
          } else {
            Navigator.of(context)
              .pushNamedAndRemoveUntil('/main', (Route<dynamic> route) => false);
          }
        }

			}
			_hideLoading();
		} else {
      NetworkUtils.showSnackBar(_scaffoldKey, allTranslations.text('login_failed'));
			setState(() {
				_isLoading = false;
				_emailError;
				_passwordError;
			});
		}
  }

  _showLoading() {
		setState(() {
		  _isLoading = true;
		});
	}

	_hideLoading() {
		setState(() {
		  _isLoading = false;
		});
	}

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }
  _focusPhoneNumberListener(){
    _phoneNumberFocusNode.addListener((){
      bool isAutoValid = false;
      _phoneNumberFocusNode.hasFocus? isAutoValid = false : isAutoValid = true;
      setState(() {
       _isValidNumberPhone = isAutoValid; 
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    var network = Provider.of<ConnectionStatus>(context);
    if(network==ConnectionStatus.offline){
      NetworkUtils.showSnackBar(_scaffoldKey, null);
    }
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomPadding: false,
     
      body: Container(
        child: Column(
          children: <Widget>[
            GradientAppBar(title: allTranslations.text('login_title')),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
              },
              child: SingleChildScrollView(
                child: Stack(
                  children: <Widget>[
                    Container(
                      height: MediaQuery.of(context).size.height * 0.85,
                      alignment: Alignment(0.0, 0.0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Center(
                              child: Image.asset('icons/logo.png', width: 200),
                            ),
                            TextFormField(
                              key: _formKey,
                              inputFormatters:<TextInputFormatter>
                               [BlacklistingTextInputFormatter(new RegExp('[\\-|\\ ]')),
                                          //  WhitelistingTextInputFormatter.digitsOnly,
                                //WhitelistingTextInputFormatter(new RegExp(pattern)),
                                LengthLimitingTextInputFormatter(11)
                                ],
                              decoration: InputDecoration(
                                labelText: allTranslations.text('form_phone_number'),
                                hintText: allTranslations.text('form_phone_number')
                              ),
                              focusNode: _phoneNumberFocusNode,
                              onFieldSubmitted: (value) {
                                _fieldFocusChange(context, _phoneNumberFocusNode,
                                      _passwordFocusNode);
                              },
                              textInputAction: TextInputAction.next,
                              controller: _emailController,
                              keyboardType: TextInputType.phone,
                              // validator: _validatePhoneNumber,
                              // autovalidate: _isValidNumberPhone,
                            ),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: allTranslations.text('form_password'),
                                hintText: allTranslations.text('form_password'),
                                suffixIcon: GestureDetector(
                                  dragStartBehavior: DragStartBehavior.down,
                                  onTap: () {
                                    setState(() {
                                      _obscureText = !_obscureText;
                                    });
                                  },
                                  child: Icon(
                                    _obscureText ? Icons.visibility_off : Icons.visibility,
                                    semanticLabel: _obscureText ? 'show password' : 'hide password',
                                  ),
                                ),
                              ),
                              focusNode: _passwordFocusNode,
                              onFieldSubmitted: (value) {
                                _passwordFocusNode.unfocus();
                              },
                              textInputAction: TextInputAction.done,
                              obscureText: !_obscureText,
                              controller: _passwordController,
                            ),
                            SizedBox(height: 20),
                            RaisedButton(
                              onPressed: () {_signIn(context);},
                              color: Colors.orange,
                              textColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Text(allTranslations.text('form_login_button_text'), style: TextStyle(fontWeight: FontWeight.bold),)
                            ),
                            SizedBox(height: 20),
                            InkWell(
                              // When the user taps the button, show a snackbar
                              onTap: () {
                                Navigator.pushNamed(context, '/forgot-password');
                              },
                              child: Container(
                                padding: EdgeInsets.all(12.0),
                                child: Text(allTranslations.text('forgot_password'), style: TextStyle(color: Color.fromRGBO(17, 134, 193, 1)),textAlign: TextAlign.center,),
                              ),
                            ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(allTranslations.text('need_register'), style: TextStyle(color: Color.fromRGBO(102, 125, 138, 1)),textAlign: TextAlign.center,),
                                SizedBox(width: 5),
                                InkWell(
                                  // When the user taps the button, show a snackbar
                                  onTap: () {
                                    Navigator.of(context).push(
                                      new PageRouteBuilder(
                                        pageBuilder: (BuildContext context, _, __) {
                                          return GetStarted();
                                        },
                                      )
                                    );
                                  },
                                  child: Text(allTranslations.text('get_started'), style: TextStyle(color: Color.fromRGBO(17, 134, 193, 1)),textAlign: TextAlign.center,)
                                ),
                                
                              ],
                            ),
                            
                          ],
                        ),
                      )
                    ),
                    _isLoading ? Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                        // filter: ImageFilter.matrix(Matrix4.diagonal3(Vector3.all(4.0))),
                        child: Container(
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                    ) : Opacity(opacity: 0.0,),
                  ],
                )
              )
            ),
          ],
        ),
      )
    );
  }
}