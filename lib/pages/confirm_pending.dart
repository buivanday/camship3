import 'package:farax/components/hex_color.dart';
import 'package:farax/pages/delivery_customer.dart';
import 'package:flutter/material.dart';
import '../all_translations.dart';
import '../components/gradient_appbar.dart';
import '../utils/network_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/auth_utils.dart';

class ConfirmPending extends StatefulWidget {
  const ConfirmPending({
    Key key,
    @required this.order
  }) : super(key: key);

  final dynamic order;

  @override
  _ConfirmPendingState createState() => _ConfirmPendingState();
}

class Zone {
  int id;
  String name;
 
  Zone(this.id, this.name);
}

class _ConfirmPendingState extends State<ConfirmPending> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
	SharedPreferences _sharedPreferences;
  bool isClickLeftButton = false;
  bool isClickRightButton = false;
  bool isOtherReason = false;
  String failedReason = '';
  String _newAddress = '';
  bool isChangeZone = false;
  dynamic _selectedZone;
  List<DropdownMenuItem> _zoneItems;
  var _otherReasonController = new TextEditingController();
  var _newAddressController = new TextEditingController();

  @override
	void initState() {
    _getZones();
		super.initState();
	}

  _handleChangeFailedReason(value) {
    if(value == allTranslations.text('other')) {
      setState(() {
        failedReason = _otherReasonController.text;
        isOtherReason = true;
        isChangeZone = false;
      });
    } else if(value == allTranslations.text('change_zone')) {
      setState(() {
        failedReason = allTranslations.text('change_zone');
        isChangeZone = true;
        isOtherReason = false;
      });
    } else {
      setState(() {
        failedReason = value;
        isOtherReason = false;
        isChangeZone = false;
      });
    }
    
  }

  onChangeDropdownItem(dynamic selectedZone) {
    setState(() {
      _selectedZone = selectedZone;
    });
  }

  Future _pendingOrder(context) async {
    _sharedPreferences = await _prefs;
		String authToken = AuthUtils.getToken(_sharedPreferences);
    var responseJson = await NetworkUtils.postWithBody(authToken, '/api/Orders/${widget.order['id']}/pending', !isChangeZone ? {
      'pendingReason': failedReason
    } : {
      'pendingReason': failedReason,
      'newAddress': _newAddress,
      'newZone': _selectedZone
    });
    if(responseJson == null) {
      NetworkUtils.showSnackBar(_scaffoldKey, allTranslations.text('something_went_wrong'));
    } else if(responseJson == 'NetworkError') {
      NetworkUtils.showSnackBar(_scaffoldKey, null);
    } else if(responseJson['error'] != null) {
      // print(responseJson['error']);
      NetworkUtils.logoutUser(_scaffoldKey.currentContext, _sharedPreferences);
    } else {
      Navigator.pushReplacementNamed(_scaffoldKey.currentContext, '/main');
    }
  }

  _getZones() async {
    List<DropdownMenuItem<dynamic>> _items = new List();
    dynamic zones = await NetworkUtils.fetchWithoutAuthorization('/api/Zones');
    for(var i = 0; i < zones.length; i++) {
      _items.add(new DropdownMenuItem(
        value: zones[i],
        child: Text(zones[i]['name'].toString())
      ));
    }
    if(mounted) {
      setState(() {
        _zoneItems = _items;
        _selectedZone = zones[0];
      });
    } else {
      _zoneItems = _items;
      _selectedZone = zones[0];
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomPadding: true,
        resizeToAvoidBottomInset: false,
        body: Column(
          children: <Widget>[
            GradientAppBar(title: widget.order['shop']['fullName'],hasBackIcon: true),
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.only(top: 24, left: 16, right: 16),
                child: Column(
                  children: <Widget>[
                    Text(allTranslations.text('why_does_it_pending'), style: TextStyle(color: HexColor('#FF9933'), fontWeight: FontWeight.bold, fontSize: 18.0),),
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
                          Flexible(
                            child:
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
                        _handleChangeFailedReason(allTranslations.text('change_zone'));
                      },
                      child: Row(
                        children: <Widget>[
                          Radio(
                            groupValue: failedReason,
                            value: allTranslations.text('change_zone'),
                            onChanged: _handleChangeFailedReason
                          ),
                          Text(allTranslations.text('change_zone'), style: TextStyle(color: HexColor('#455A64')),)
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
                            controller: _otherReasonController,
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
                    ),
                    isChangeZone == true ? Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.only(left: 16, top: 12),
                          alignment: Alignment.centerLeft,
                          child: Text(allTranslations.text('select_new_zone'), style: TextStyle(color: HexColor('#B0BEC5'), fontSize: 12),),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: DropdownButton(
                            items: _zoneItems,
                            value: _selectedZone,
                            onChanged: onChangeDropdownItem,
                          )
                        ),
                        Container(
                          padding: const EdgeInsets.only(left: 16, top: 12),
                          alignment: Alignment.centerLeft,
                          child: Text(allTranslations.text('enter_new_address'), style: TextStyle(color: HexColor('#B0BEC5'), fontSize: 12),),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextField(
                            controller: _newAddressController,
                            onChanged: (String value) {
                              setState(() {
                                _newAddress = value;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: allTranslations.text('enter_new_address')
                            ),
                          ),
                        )
                      ],
                    ) : IgnorePointer(
                      ignoring: true,
                      child: Opacity(opacity: 0.0,),
                    )
                  ],
                ),
              )
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: RaisedButton(
                onPressed: (failedReason == '' || (isChangeZone && _newAddress == ''))? null : () {
                  _pendingOrder(context);
                },
                color: Color.fromRGBO(253, 134, 39, 1),
                textColor: Colors.white,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10))
                  ),
                  child: Center(
                    child: Text(allTranslations.text('confirm').toUpperCase(), style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            )
          ],
        )
    );
  }
}