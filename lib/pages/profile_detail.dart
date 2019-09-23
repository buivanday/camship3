import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../all_translations.dart';
import '../components/gradient_appbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/auth_utils.dart';
import '../utils/network_utils.dart';
import 'change_password.dart';

class ProfileDetail extends StatefulWidget {
  @override
  _ProfileDetailState createState() => _ProfileDetailState();
}

class _ProfileDetailState extends State<ProfileDetail> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
	Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences _sharedPreferences;
	var _authToken, _id, _name = "", _phoneNumber = "", _address = "";

  @override
	void initState() {
		super.initState();
		_fetchSessionAndNavigate();
	}

  _fetchSessionAndNavigate() async {
		_sharedPreferences = await _prefs;
		String authToken = AuthUtils.getToken(_sharedPreferences);
		var id = _sharedPreferences.getString(AuthUtils.userIdKey);
		var name = _sharedPreferences.getString(AuthUtils.nameKey);
    var phoneNumber = _sharedPreferences.getString(AuthUtils.phoneNumber);
    var address = _sharedPreferences.getString(AuthUtils.address);

		if(mounted) {
      setState(() {
        _authToken = authToken;
        _id = id;
        _name = name;
        _phoneNumber = phoneNumber;
        _address = address;
      });
    } else {
      _authToken = authToken;
        _id = id;
        _name = name;
        _phoneNumber = phoneNumber;
         _address = address;
    }

		if(_authToken == null) {
			_logout();
		}
	}

  _logout() {
		NetworkUtils.logoutUser(_scaffoldKey.currentContext, _sharedPreferences);
	}

  Future _getProfile() async {
    _sharedPreferences = await _prefs;
		String authToken = AuthUtils.getToken(_sharedPreferences);
    return NetworkUtils.fetch(authToken, '/api/Members/profile');
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: <Widget>[
          GradientAppBar(title: allTranslations.text('profile_detail'), hasActions: true, hasBackIcon: true, isEditProfile: true,),
          Expanded(
            flex: 1,
            child: FutureBuilder(
              future: _getProfile(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                    return Text(allTranslations.text('something_wrong'));
                  case ConnectionState.waiting:
                    return Center(child: CircularProgressIndicator(),);
                  case ConnectionState.active:
                    return Text('');
                  case ConnectionState.done:
                    if(snapshot.hasError) {
                      return Text('error');
                    } else {
                      String _avatar = snapshot.data['avatar'];
                      return Stack(
                    children: <Widget>[
                      Container(
                        color: Color.fromRGBO(245, 245, 245, 1)
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 55, 16, 16),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 80, left: 8, right: 8),
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(allTranslations.text('full_name')),
                                      Text(snapshot.data['fullName']),
                                    ],
                                  ),
                                  SizedBox(height: 15),
                                  Divider(height: 1,),
                                  SizedBox(height: 15),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(allTranslations.text('form_phone_number')),
                                      Text(snapshot.data['phoneNumber']),
                                    ],
                                  ),
                                  SizedBox(height: 15),
                                  Divider(height: 1,),
                                  SizedBox(height: 15),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(allTranslations.text('gender')),
                                      Text('Male'),
                                    ],
                                  ),
                                  SizedBox(height: 15),
                                  Divider(height: 1,),
                                  SizedBox(height: 15),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(allTranslations.text('address')),
                                      Flexible(
                                        child: Text(snapshot.data['address'], textAlign: TextAlign.right,),
                                      )
                                    ],
                                  ),
                                  SizedBox(height: 15),
                                  Divider(height: 1,),
                                  SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(allTranslations.text('email')),
                                      // Row(
                                      //   mainAxisAlignment: MainAxisAlignment.end,
                                      //   children: <Widget>[
                                      //     Text(allTranslations.text('set_now'), style: TextStyle(color: Color.fromRGBO(22, 170, 215, 1)), textAlign: TextAlign.right,),
                                      //     IconButton(
                                      //       icon: Icon(Icons.arrow_forward_ios, size: 14, color: Color.fromRGBO(22, 170, 215, 1)),
                                      //       onPressed: () {},
                                      //       padding: const EdgeInsets.all(1),
                                      //       alignment: Alignment.centerRight,
                                      //     )
                                      //   ],
                                      // )
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                  Divider(height: 1,),
                                  SizedBox(height: 10),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(
                                        builder: (context) => ChangePassword()
                                      ));
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(allTranslations.text('change_password'), style: TextStyle(color: Color.fromRGBO(22, 170, 215, 1))),
                                        IconButton(
                                          icon: Icon(Icons.arrow_forward_ios, size: 14, color: Color.fromRGBO(22, 170, 215, 1)),
                                          onPressed: () {
                                            Navigator.push(context, MaterialPageRoute(
                                              builder: (context) => ChangePassword()
                                            ));
                                          },
                                          padding: const EdgeInsets.all(0),
                                          alignment: Alignment.centerRight,
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              )
                            ),
                          ),
                        )
                      ),
                      Align(
                        alignment: Alignment.topCenter,
                        child: SizedBox(
                          width: 120,
                          height: 170,
                          child: Column(
                            children: <Widget>[
                              SizedBox(height: 20),
                              Container(
                                constraints: BoxConstraints(maxWidth: 120, maxHeight: 120),
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(Radius.circular(5)),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.all(Radius.circular(5)),
                                  child: CachedNetworkImage(
                                      imageUrl: "https://camships.com:3000/api/attachments/compressed/download/" + (_avatar == null ? 'logo.png' : _avatar),
                                      placeholder: (context, url) => new Center(child: CircularProgressIndicator(),),
                                      errorWidget: (context, url, error) => new Icon(Icons.error),
                                    )
                                )
                              ),
                            ],
                          )
                        ),
                      )
                    ]);
                  }
                }
              },
            )
          ),
          ],
        ),
      ),
    ); 
  }
}