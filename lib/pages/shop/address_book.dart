import 'package:farax/components/gradient_appbar.dart';
import 'package:farax/components/hex_color.dart';
import 'package:farax/utils/auth_utils.dart';
import 'package:farax/utils/network_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../all_translations.dart';
import 'add_address_detail.dart';

class AddressBook extends StatefulWidget {
  const AddressBook({
    Key key,
    this.isAddedSuccessfully = false,
  }) : super(key: key);

  final bool isAddedSuccessfully;
  @override
  _AddressBookState createState() => _AddressBookState();
}

class _AddressBookState extends State<AddressBook> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
	Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences _sharedPreferences;

  var _stores, _customers;
  var _defaultStore;
	
  @override
	void initState() {
		super.initState();
		_fetchSessionAndNavigate();
	}
  @override
  void dispose(){
    super.dispose();
  }

  _fetchSessionAndNavigate() async {
		_sharedPreferences = await _prefs;
		String authToken = AuthUtils.getToken(_sharedPreferences);
    
		if(authToken == null) {
			_logout();
		} else {
      List<dynamic> _storesResponse = await NetworkUtils.fetch(authToken, '/api/Members/stores');
      var _customersResponse = await NetworkUtils.fetch(authToken, '/api/Members/contacts');
      setState(() {
        _stores = _storesResponse.where((_store) {
          return _store['isPrimary'] == false;
        }).toList();
        _customers = _customersResponse.toList();
        if(_storesResponse.isNotEmpty) {
          _defaultStore = _storesResponse.where((_store) {
            return _store['isPrimary'] == true;
          }).toList();
        }
      });
    }
	}

  _logout() {
		NetworkUtils.logoutUser(_scaffoldKey.currentContext, _sharedPreferences);
	}
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, 
      child: Scaffold(
        body: Container(
          child: Column(
            children: <Widget>[
              GradientAppBar(title: allTranslations.text('address_book'), hasBackIcon: true, hasActions: true, plusIcon: true, backtoProfile: true,),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TabBar(
                  indicatorColor: Colors.orange,
                  labelColor: Color.fromRGBO(121, 141, 153, 1),
                  tabs: <Widget>[
                    Tab(text: allTranslations.text('shop')),
                    Tab(text: allTranslations.text('customer'))
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: TabBarView(
                  children: <Widget>[
                    SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: 24.0,),
                            _defaultStore != null ?  Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(0, 153, 204, 0.1),
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(4.0), topRight: Radius.circular(4.0))
                              ),
                              child: Text(allTranslations.text('default_address').toUpperCase(), style: TextStyle(color: HexColor('#0099CC'), fontWeight: FontWeight.bold, fontSize: 12.0, height: 14.0/12.0),),
                            ) : Container(),
                            _defaultStore != null && _defaultStore.isNotEmpty ? Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.06),
                                    spreadRadius: 2.0,
                                    blurRadius: 1.0,
                                    offset: Offset(0.2, 0.2)
                                  )
                                ],
                                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(4.0), bottomRight: Radius.circular(4.0))
                              ),
                              child: new AddressBookItem(title: _defaultStore[0]['name'], address: _defaultStore[0]['address'], phoneNumber: _defaultStore[0]['phoneNumber'],),
                            ) : Container(),
                            SizedBox(height: 16.0,),
                            _stores != null && _stores.isNotEmpty ? Container(
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height * 0.6,
                              padding: const EdgeInsets.only(top: 20.0, left: 10.0, right: 10.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.06),
                                    spreadRadius: 2.0,
                                    blurRadius: 1.0,
                                    offset: Offset(0.2, 0.2)
                                  )
                                ],
                                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(4.0), bottomRight: Radius.circular(4.0))
                              ),
                              child: ListView.builder(
                                itemCount: _stores.length,
                                itemBuilder: (context, position) {
                                  return Column(
                                    children: <Widget>[
                                      new AddressBookItem(title: _stores[position]['name'], address: _stores[position]['address'], phoneNumber: _stores[position]['phoneNumber'],),
                                      SizedBox(height: 20.0,),
                                      Divider(height: 1.0,),
                                      SizedBox(height: 20.0,),
                                    ],
                                  );
                                },
                              ),
                            ) : IgnorePointer(
                              ignoring: true,
                              child: Opacity(opacity: 0.0,),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _customers != null && _customers.isNotEmpty ? SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: 24.0,),Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(0, 153, 204, 0.1),
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(4.0), topRight: Radius.circular(4.0))
                              ),
                              child: Text(allTranslations.text('receiver_list').toUpperCase(), style: TextStyle(color: HexColor('#0099CC'), fontWeight: FontWeight.bold, fontSize: 12.0, height: 14.0/12.0),),
                            ),
                            Container(
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height * 0.8,
                              padding: const EdgeInsets.only(top: 20.0, left: 10.0, right: 10.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.06),
                                    spreadRadius: 2.0,
                                    blurRadius: 1.0,
                                    offset: Offset(0.2, 0.2)
                                  )
                                ],
                                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(4.0), bottomRight: Radius.circular(4.0))
                              ),
                              child: ListView.builder(
                                itemCount: _customers.length,
                                itemBuilder: (context, position) {
                                  return Column(
                                    children: <Widget>[
                                      new AddressBookItem(title: _customers[position]['fullName'], address: _customers[position]['address'], phoneNumber: _customers[position]['phoneNumber'],),
                                      SizedBox(height: 20.0,),
                                      Divider(height: 1.0,),
                                      SizedBox(height: 20.0,),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ) : Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Image.asset('icons/no-order.png'),
                          SizedBox(height: 16),
                          Text(allTranslations.text('no_customer_text'))
                        ]
                      ),
                    ),
                  ],
                )
              ),
            ],
          ),
        ),
      )
    ); 
  }
}

class AddressBookItem extends StatelessWidget {
  const AddressBookItem({
    Key key,
    this.title,
    this.address,
    this.phoneNumber
  }) : super(key: key);

  final String title;
  final String address;
  final String phoneNumber;

  @override
  Widget build(BuildContext context) {
    print(title);
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          new PageRouteBuilder(
            pageBuilder: (BuildContext context, _, __) {
              return AdressBookDetail(title: title, address: address,phoneNumber: phoneNumber,);
            },
          )
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Icon(Icons.location_on, color: HexColor('#0099CC'),),
          ),
          Expanded(
            flex: 9,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: TextStyle(color: HexColor('#263238'), fontWeight: FontWeight.bold, fontSize: 16.0, height: 19.0/16.0),),
                SizedBox(height: 11.0,),
                Text(address, style: TextStyle(color: HexColor('#455A64'), fontSize: 14.0, height: 20.0/14.0),),
                SizedBox(height: 10.0,),
                Text(phoneNumber, style: TextStyle(color: HexColor('#455A64'), fontSize: 14.0, height: 16.0/14.0),)
              ],
            ),
          )
        ],
      ),
    );
  }
}