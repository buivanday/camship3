import 'package:farax/pages/history.dart';
import 'package:farax/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/auth_utils.dart';
import '../utils/network_utils.dart';
import 'package:gradient_text/gradient_text.dart';
import '../all_translations.dart';
import '../components/gradient_appbar.dart';
import '../pages/shipper/income_screen.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  int _selectedIndex = 3;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
	Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences _sharedPreferences;
	var _authToken, _id, _name = "", _phoneNumber = "";

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

		setState(() {
			_authToken = authToken;
			_id = id;
			_name = name;
      _phoneNumber = phoneNumber;
		});

		if(_authToken == null) {
			_logout();
		}
	}

  _logout() {
		NetworkUtils.logoutUser(_scaffoldKey.currentContext, _sharedPreferences);
	}

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacement(
          new PageRouteBuilder(
            pageBuilder: (BuildContext context, _, __) {
              return History();
            },
          )
        );
        break;
      case 1:
        Navigator.of(context).pushReplacement(
          new PageRouteBuilder(
            pageBuilder: (BuildContext context, _, __) {
              return Home();
            },
          )
        );
        break;
      case 2:
        Navigator.of(context).pushReplacement(
          new PageRouteBuilder(
            pageBuilder: (BuildContext context, _, __) {
              return Income();
            },
          )
        );
        break;
      case 3:
        Navigator.of(context).pushReplacement(
          new PageRouteBuilder(
            pageBuilder: (BuildContext context, _, __) {
              return Profile();
            },
          )
        );
        break;
      default:
    }
  }

  Future _getProfile() async {
    _sharedPreferences = await _prefs;
		String authToken = AuthUtils.getToken(_sharedPreferences);
    return NetworkUtils.fetch(authToken, '/api/Members/profile');
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        key: _scaffoldKey,
        body: Container(
          child: Column(
            children: <Widget>[
              GradientAppBar(title: allTranslations.text('profile_title')),
              FutureBuilder(
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
                      Image avatar = _avatar != null && _avatar != '' ? Image.network('https://camships.com:3000/api/attachments/compressed/download/${_avatar}?v=' + new DateTime.now().millisecondsSinceEpoch.toString(),fit: BoxFit.contain) : Image.asset('icons/logo.png', fit: BoxFit.contain);
                      return InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, '/profile-detail');
                        },
                        child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: Container(
                                    // padding: const EdgeInsets.all(0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(Radius.circular(10)),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.all(Radius.circular(10)),
                                      child: avatar
                                    )
                                  ),
                                ),
                                SizedBox(width: 16),
                                ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.5),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(snapshot.data['fullName'] != null ? snapshot.data['fullName'] : '', style: TextStyle(
                                        color: Color.fromRGBO(22, 170, 215, 1),
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold
                                      ),),
                                      Text(snapshot.data['phoneNumber'] != null ? snapshot.data['phoneNumber'] : '', style: TextStyle(

                                      ))
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: IconButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/profile-detail');
                                  },
                                  icon: Icon(Icons.arrow_forward_ios, size: 14, color: Color.fromRGBO(22, 170, 215, 1)),
                                  alignment: Alignment.centerRight,
                                ),
                                )
                              ],
                            ),

                          ],
                        ),
                      ),
                      );
                    }
                }
              }
              ),
              Container(
                height: 16,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(242, 242, 242, 1)
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: <Widget>[
                          Image.asset('icons/fee.png'),
                          SizedBox(width: 8,),
                          Text(allTranslations.text('profile_fee_service_information')),
                          Expanded(
                            flex: 1,
                            child: IconButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/fee-service');
                              },
                              icon: Icon(Icons.arrow_forward_ios, size: 14, color: Color.fromRGBO(22, 170, 215, 1)),
                              alignment: Alignment.centerRight,
                            )
                          )
                        ],
                      ),
                    ),
                    Divider(height: 1,),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: <Widget>[
                          Image.asset('icons/info.png'),
                          SizedBox(width: 8,),
                          Text(allTranslations.text('about_us')),
                          Expanded(
                            flex: 1,
                            child: IconButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/about-us');
                              },
                              icon: Icon(Icons.arrow_forward_ios, size: 14, color: Color.fromRGBO(22, 170, 215, 1)),
                              alignment: Alignment.centerRight,
                            )
                          )
                        ],
                      ),
                    ),
                    Divider(height: 1,),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: <Widget>[
                          Image.asset('icons/setting.png'),
                          SizedBox(width: 8,),
                          Text(allTranslations.text('settings')),
                          Expanded(
                            flex: 1,
                            child: IconButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/settings');
                              },
                              icon: Icon(Icons.arrow_forward_ios, size: 14, color: Color.fromRGBO(22, 170, 215, 1)),
                              alignment: Alignment.centerRight,
                            )
                          )
                        ],
                      ),
                    ),
                    Divider(height: 1,),
                  ],
                ),
              )
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today), 
                title: _selectedIndex == 0 ? GradientText(
                  allTranslations.text('history_tab'),
                  gradient: LinearGradient(
                    colors: [Color.fromRGBO(0, 201, 232, 1),
                      Color.fromRGBO(0, 153, 204, 1)]),
                  textAlign: TextAlign.center) : Text(allTranslations.text('history_tab'),)
              ),
              BottomNavigationBarItem(icon: Icon(Icons.home), 
                title: _selectedIndex == 1 ? GradientText(
                  allTranslations.text('home_tab'),
                  gradient: LinearGradient(
                    colors: [Color.fromRGBO(0, 201, 232, 1),
                      Color.fromRGBO(0, 153, 204, 1)]),
                  textAlign: TextAlign.center) : Text(allTranslations.text('home_tab'))
              ),
              BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), 
                title: _selectedIndex == 2 ? GradientText("Income",
                  //allTranslations.text('income_tab'),
                  gradient: LinearGradient(
                    colors: [Color.fromRGBO(0, 201, 232, 1),
                      Color.fromRGBO(0, 153, 204, 1)]),
                  textAlign: TextAlign.center) : Text("Income"//allTranslations.text('income_tab')
                  )
              ),
              BottomNavigationBarItem(icon: Icon(Icons.more_horiz), 
                title: _selectedIndex == 3 ? GradientText(
                  allTranslations.text('more_tab'),
                  gradient: LinearGradient(
                    colors: [Color.fromRGBO(0, 201, 232, 1),
                      Color.fromRGBO(0, 153, 204, 1)]),
                  textAlign: TextAlign.center) : Text(allTranslations.text('more_tab'))
              ),
            ],
            //fixedColor: Color.fromRGBO(0, 153, 204, 1),
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: Color.fromRGBO(0, 153, 204, 1),
            unselectedItemColor: Colors.grey[600],
            selectedFontSize: 12.0,
            unselectedFontSize: 12,
            selectedLabelStyle: TextStyle(fontSize:12 ),
            unselectedLabelStyle: TextStyle(fontSize:12 ),
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
          ), 
      )
    );  
  }
}