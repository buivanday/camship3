import 'package:flutter/material.dart';
import '../all_translations.dart';
import '../components/hex_color.dart';
import '../all_translations.dart';
import '../components/gradient_appbar.dart';
import '../utils/network_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/auth_utils.dart';

class FailReason extends StatefulWidget {
  const FailReason({
    Key key,
    @required this.order
  }) : super(key: key);

  final dynamic order;

  @override
  _FailReasonState createState() => _FailReasonState();
}

class _FailReasonState extends State<FailReason> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
	SharedPreferences _sharedPreferences;
  bool isOtherReason = false;
  String failedReason = '';
  TextEditingController _failedReasonController = new TextEditingController();

  _handleChangeFailedReason(value) {
    if(value == allTranslations.text('other')) {
      setState(() {
        failedReason = _failedReasonController.text;
        isOtherReason = true;
      });
    } else {
      setState(() {
        failedReason = value;
        isOtherReason = false;
      });
    }
    
  }

  Future _confirmInShop() async {
    _sharedPreferences = await _prefs;
		String authToken = AuthUtils.getToken(_sharedPreferences);
    var responseJson = await NetworkUtils.postWithBody(authToken, '/api/Orders/${widget.order['id']}/shipping-failed', {
      "failedReasonFull": failedReason
    });
    if(responseJson == null) {

      NetworkUtils.showSnackBar(_scaffoldKey, allTranslations.text('something_went_wrong'));

    } else if(responseJson == 'NetworkError') {

      NetworkUtils.showSnackBar(_scaffoldKey, null);

    } else if(responseJson['errors'] != null) {
      NetworkUtils.logoutUser(_scaffoldKey.currentContext, _sharedPreferences);
    } else {
      Navigator.pushReplacementNamed(_scaffoldKey.currentContext, '/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        key: _scaffoldKey,
        // appBar: back,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.only(top: 84),
                    child: Column(
                      children: <Widget>[
                        Stack(
                          children: <Widget>[
                            IconButton(
                              padding: const EdgeInsets.only(top: 20, left: 16),
                              icon: Icon(Icons.arrow_back, size: 35,),
                              // color: Colors.white,
                              alignment: Alignment.centerLeft,
                              onPressed: () { 
                                Navigator.pop(context);
                              },
                            ),
                            Center(
                              child: Image.asset('icons/icon-2.png'),
                            )
                          ],
                        ),
                        SizedBox(height: 24,),
                        Text(allTranslations.text('why_does_it_fail'), style: TextStyle(color: HexColor('#FF9933'), fontWeight: FontWeight.bold, fontSize: 18.0),),
                        SizedBox(height: 36,),
                        InkWell(
                          onTap: () {
                            _handleChangeFailedReason(allTranslations.text('fail_reason_1'));
                          },
                          child: Row(
                            children: <Widget>[
                              Radio(
                                groupValue: failedReason,
                                value: allTranslations.text('fail_reason_1'),
                                onChanged: _handleChangeFailedReason
                              ),
                              Text(allTranslations.text('fail_reason_1'), style: TextStyle(color: HexColor('#455A64')),)
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            _handleChangeFailedReason(allTranslations.text('fail_reason_2'));
                          },
                          child: Row(
                            children: <Widget>[
                              Radio(
                                groupValue: failedReason,
                                value: allTranslations.text('fail_reason_2'),
                                onChanged: _handleChangeFailedReason
                              ),
                              Text(allTranslations.text('fail_reason_2'), style: TextStyle(color: HexColor('#455A64')),)
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            _handleChangeFailedReason(allTranslations.text('fail_reason_3'));
                          },
                          child: Row(
                            children: <Widget>[
                              Radio(
                                groupValue: failedReason,
                                value: allTranslations.text('fail_reason_3'),
                                onChanged: _handleChangeFailedReason
                              ),
                              Flexible(child:
                              Text(allTranslations.text('fail_reason_3'), style: TextStyle(color: HexColor('#455A64')),))
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            _handleChangeFailedReason(allTranslations.text('fail_reason_4'));
                          },
                          child: Row(
                            children: <Widget>[
                              Radio(
                                groupValue: failedReason,
                                value: allTranslations.text('fail_reason_4'),
                                onChanged: _handleChangeFailedReason
                              ),
                              Text(allTranslations.text('fail_reason_4'), style: TextStyle(color: HexColor('#455A64')),)
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            _handleChangeFailedReason(allTranslations.text('fail_reason_5'));
                          },
                          child: Row(
                            children: <Widget>[
                              Radio(
                                groupValue: failedReason,
                                value: allTranslations.text('fail_reason_5'),
                                onChanged: _handleChangeFailedReason
                              ),
                              Text(allTranslations.text('fail_reason_5'), style: TextStyle(color: HexColor('#455A64')),)
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            _handleChangeFailedReason(allTranslations.text('other'));
                          },
                          child: Row(
                            children: <Widget>[
                              Radio(
                                groupValue: failedReason,
                                value: allTranslations.text('other'),
                                onChanged: _handleChangeFailedReason
                              ),
                              Text(allTranslations.text('other'), style: TextStyle(color: HexColor('#455A64')),)
                            ],
                          ),
                        ),
                        isOtherReason == true ? Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.only(left: 16, top: 12),
                              alignment: Alignment.centerLeft,
                              child: Text(allTranslations.text('enter_other_reason_label'), style: TextStyle(color: HexColor('#B0BEC5'), fontSize: 12),),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: TextField(
                                controller: _failedReasonController,
                                onChanged: (String value) {
                                  setState(() {
                                    failedReason = value;
                                  });
                                },
                              decoration: InputDecoration(
                                hintText: allTranslations.text('enter_other_reason_label')
                              ),
                            ),
                            )
                          ],
                        ) : IgnorePointer(
                          ignoring: true,
                          child: Opacity(
                            opacity: 0.0,
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ),
              RaisedButton(
                onPressed: _confirmInShop,
                color: HexColor('#FF9933'),
                textColor: Colors.white,
                child: Text(allTranslations.text('submit').toUpperCase(), ),
              ),
              SizedBox(height: 8,)
            ],
          ),
        ),
      ),
    );
  }
}