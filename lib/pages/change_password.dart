import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:farax/components/hex_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../all_translations.dart';
import '../components/gradient_appbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/auth_utils.dart';
import '../utils/network_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:progress_dialog/progress_dialog.dart';

class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
	Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences _sharedPreferences;
  var _currentPasswordController = new TextEditingController();
  var _newPasswordController = new TextEditingController();
  var _confirmNewPasswordController = new TextEditingController();
  final FocusNode _currentPasswordNode = FocusNode();
  final FocusNode _newPasswordNode = FocusNode();
  final FocusNode _confirmNewPasswordNode = FocusNode();
  bool _obscureConfirmPassword = true;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _formValid = false;
  bool _isWaiting = false;
  @override
	void initState() {
		super.initState();

   
	}
  
  Future _save() async {
    String pwd = _currentPasswordController.text;
    String rePwd = _confirmNewPasswordController.text;
    String newPwd = _newPasswordController.text;

    try { 
      setState(() {
        _isWaiting = true;
      });
      _sharedPreferences = await _prefs;
		  String authToken = AuthUtils.getToken(_sharedPreferences);
      var response = await NetworkUtils.postWithBody(authToken, '/api/Members/change-password', {
        'oldPassword': pwd,
        'newPassword': newPwd
      });

      print(response);
      if(response != null && response['error'] != null) {
        String code = response['error']['code'].toString();
        if(code.toLowerCase() == 'invalid_password') {
          Fluttertoast.showToast(
            msg: allTranslations.text('invalid_current_password'),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIos: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: allTranslations.text('success'),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0
        );
        NetworkUtils.logoutUser(_scaffoldKey.currentContext, _sharedPreferences);
      }

      setState(() {
        _isWaiting = false;
      });
    } catch(err) {
      print(err);
    }
  }

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  bool _valid() {
    String pwd = _currentPasswordController.text;
    String rePwd = _confirmNewPasswordController.text;
    String newPwd = _newPasswordController.text;

    return _isValid(pwd) &&
        _isValid(rePwd) &&
        _isValid(newPwd) && 
        rePwd == newPwd;
  }

  bool _isValid(String variable) {
    return variable != null && variable != '' && variable.isNotEmpty;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        child: Stack(
          children: [
            Column(
          children: <Widget>[
          GradientAppBar(title: allTranslations.text('change_password'), hasBackIcon: true),
          Expanded(
            flex: 1,
            child: Form(
              onChanged: () {
                setState(() {
                  _formValid = _valid();
                });
              },
              autovalidate: true,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 16.0),
                child: Column(
                  children: <Widget>[
                    Theme(
                      data: new ThemeData(hintColor: HexColor('#DFE4EA')),
                      child: TextFormField(
                        focusNode: _currentPasswordNode,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: allTranslations.text('current_password'),
                          labelStyle: TextStyle(
                              color: HexColor('#B0BEC5'), fontSize: 14),
                          suffixIcon: GestureDetector(
                            dragStartBehavior: DragStartBehavior.down,
                            onTap: () {
                              setState(() {
                                _obscureCurrentPassword = !_obscureCurrentPassword;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Icon(
                                _obscureCurrentPassword ? Icons.visibility_off : Icons.visibility,
                                semanticLabel: _obscureCurrentPassword ? 'show password' : 'hide password',
                              ),
                            ),
                          ),
                        ),
                        obscureText: _obscureCurrentPassword,
                        onFieldSubmitted: (value) {
                          _fieldFocusChange(context, _currentPasswordNode, _newPasswordNode);
                        },
                        controller: _currentPasswordController,
                        style: TextStyle(color: HexColor('#455A64')),
                      ),
                    ),
                    Theme(
                      data: new ThemeData(hintColor: HexColor('#DFE4EA')),
                      child: TextFormField(
                        focusNode: _newPasswordNode,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: allTranslations.text('new_password'),
                          labelStyle: TextStyle(
                              color: HexColor('#B0BEC5'), fontSize: 14),
                          suffixIcon: GestureDetector(
                            dragStartBehavior: DragStartBehavior.down,
                            onTap: () {
                              setState(() {
                                _obscureNewPassword = !_obscureNewPassword;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Icon(
                                _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                                semanticLabel: _obscureNewPassword ? 'show password' : 'hide password',
                              ),
                            ),
                          ),
                        ),
                        obscureText: _obscureNewPassword,
                        onFieldSubmitted: (value) {
                          _fieldFocusChange(context, _newPasswordNode,
                              _confirmNewPasswordNode);
                        },
                        controller: _newPasswordController,
                        style: TextStyle(color: HexColor('#455A64')),
                      ),
                    ),
                    Theme(
                      data: new ThemeData(hintColor: HexColor('#DFE4EA')),
                      child: TextFormField(
                        focusNode: _confirmNewPasswordNode,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: allTranslations.text('confirm_password'),
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
                              padding: const EdgeInsets.all(10.0),
                              child: Icon(
                                _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                semanticLabel: _obscureConfirmPassword ? 'show password' : 'hide password',
                              ),
                            ),
                          ),
                        ),
                        obscureText: _obscureConfirmPassword,
                        onFieldSubmitted: (value) {
                          _confirmNewPasswordNode.unfocus();
                        },
                        validator: (String arg) {
                          if(arg != _newPasswordController.text)
                            return allTranslations.text('confirm_password_error');
                          else
                            return null;
                        },
                        controller: _confirmNewPasswordController,
                        style: TextStyle(color: HexColor('#455A64')),
                      ),
                    ),
                  ],
                ),
              )
            )
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: RaisedButton(
                onPressed: _formValid ? _save : null,
                color: Color.fromRGBO(253, 134, 39, 1),
                textColor: Colors.white,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10))
                  ),
                  child: Center(
                    child: Text(allTranslations.text('save').toUpperCase(), style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            )
          ],
        ),
        _isWaiting ? Positioned.fill(
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
          ]
        ),
      )
    ); 
  }
}