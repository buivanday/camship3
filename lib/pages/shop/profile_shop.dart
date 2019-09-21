import 'package:farax/all_translations.dart';
import 'package:farax/components/fab_bar.dart';
import 'package:farax/components/gradient_appbar.dart';
import 'package:farax/components/hex_color.dart';
import 'package:farax/utils/auth_utils.dart';
import 'package:farax/utils/network_utils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gradient_text/gradient_text.dart';

import '../settings.dart';
import 'cod_screen.dart';
import 'create_package.dart';
import 'home_shop.dart';
import 'notification_screen.dart';

class ProfileShop extends StatefulWidget {
  @override
  _ProfileShopState createState() => _ProfileShopState();
}

class _ProfileShopState extends State<ProfileShop> {
  int _selectedIndex = 3;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
	Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences _sharedPreferences;
	var _authToken, _id, _name = "", _phoneNumber = "", _language = "";

  @override
	void initState() {
		super.initState();
		_fetchSessionAndNavigate();
	}

  _fetchSessionAndNavigate() async {
		_sharedPreferences = await _prefs;
     _sharedPreferences.setBool('isPageThreeExist', false);
		String authToken = AuthUtils.getToken(_sharedPreferences);
		var id = _sharedPreferences.getString(AuthUtils.userIdKey);
		var name = _sharedPreferences.getString(AuthUtils.nameKey);
    var phoneNumber = _sharedPreferences.getString(AuthUtils.phoneNumber);
		var language = _sharedPreferences.getString('MyApplication_language');

		if(mounted) {
      setState(() {
        _authToken = authToken;
        _id = id;
        _name = name;
        _phoneNumber = phoneNumber;
        _language = language;
      });
    } else {
      _authToken = authToken;
        _id = id;
        _name = name;
        _phoneNumber = phoneNumber;
        _language = language;
    }

		if(_authToken == null) {
			_logout();
		}
	}

  Future _getProfile() async {
    _sharedPreferences = await _prefs;
		String authToken = AuthUtils.getToken(_sharedPreferences);
    return NetworkUtils.fetch(authToken, '/api/Members/profile');
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
              return HomeShop();
            },
          )
        );
        break;
      case 1:
        Navigator.of(context).pushReplacement(
          new PageRouteBuilder(
            pageBuilder: (BuildContext context, _, __) {
              return Cod();
            },
          )
        );
        break;
      case 2:
        Navigator.of(context).pushReplacement(
          new PageRouteBuilder(
            pageBuilder: (BuildContext context, _, __) {
              return NotificationScreen();
            },
          )
        );
        break;
      case 3:
        Navigator.of(context).pushReplacement(
          new PageRouteBuilder(
            pageBuilder: (BuildContext context, _, __) {
              return ProfileShop();
            },
          )
        );
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {},
      child: DefaultTabController(
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
                      Image avatar = _avatar != null && _avatar != '' ? Image.network('https://camships.com:3000/api/attachments/camship/download/${_avatar}?v=' + new DateTime.now().millisecondsSinceEpoch.toString(),fit: BoxFit.contain) : Image.asset('icons/logo.png', fit: BoxFit.contain);
                      return Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: Container(
                                    padding: const EdgeInsets.all(10.0),
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
                Expanded(
                  flex:1,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: <Widget>[
                          new ProfileItem(img: 'icons/fee.png', title: 'profile_fee_service_information', url: '/about-us'),
                          Divider(height: 1,),
                          new ProfileItem(img: 'icons/contact.png', title: 'address_book', url: '/address-book'),
                          Divider(height: 1,),
                          new ProfileItem(img: 'icons/add-card.png', title: 'manage_card', url: '/manage-card'),
                          Divider(height: 1,),
                          new ProfileItem(img: 'icons/info.png', title: 'about_us', url: '/about-us',),
                          Divider(height: 1,),
                          new ProfileItem(img: 'icons/setting.png', title: 'settings', url: '/settings', isSetting: true, language: _language),
                          Divider(height: 1,),
                        ],
                      ),
                    ),
                  )
                )
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(
                new PageRouteBuilder(
                  pageBuilder: (BuildContext context, _, __) {
                    return CreatePackage();
                  },
                )
              );
            },
            materialTapTargetSize: MaterialTapTargetSize.padded,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(Icons.add),
            ),
            foregroundColor: Colors.white,
            backgroundColor: Color.fromRGBO(23, 176, 219, 1),
            shape: _PolygonBorder(),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: FABBottomAppBar(
            color: HexColor('#B0BEC5'),
            selectedColor: HexColor('#0099CC'),
            onTabSelected: _onItemTapped,
            selectedIndex: _selectedIndex,
            // notchedShape: CircularNotchedRectangle(),
            items: [
              FABBottomAppBarItem(iconData: Icons.home, text: allTranslations.text('home_tab')),
              FABBottomAppBarItem(iconData: Icons.account_balance_wallet, text: allTranslations.text('cod_tab')),
              FABBottomAppBarItem(iconData: Icons.notifications, text: allTranslations.text('notification_tab'), count: 2),
              FABBottomAppBarItem(iconData: Icons.more_horiz, text: allTranslations.text('more_tab')),
            ],
          ),
        )
      ),
    );
  }
}

class ProfileItem extends StatelessWidget {
  const ProfileItem({
    Key key,
    this.img,
    this.title,
    this.url,
    this.isSetting = false,
    this.language = ''
  }) : super(key: key);

  final String img;
  final String title;
  final String url;
  final bool isSetting;
  final String language;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: ()async{
           if(!isSetting) {
                  Navigator.pushNamed(context, url);
                } else {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => Settings()
                  ));
                }
        },
        child: Row(
        children: <Widget>[
          Image.asset(img),
          SizedBox(width: 8,),
          Text(allTranslations.text(title)),
          Expanded(
            flex: 1,
            child: IconButton(
              onPressed: () async {
               if(!isSetting) {
                  Navigator.pushNamed(context, url);
                } else {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => Settings()
                  ));
                }
                
              },
              icon: Icon(Icons.arrow_forward_ios, size: 14, color: Color.fromRGBO(22, 170, 215, 1)),
              alignment: Alignment.centerRight,
            )
          )
        ],
      ),
      ),
    );
  }
}

class _PolygonBorder extends ShapeBorder {
  const _PolygonBorder();

  @override
  EdgeInsetsGeometry get dimensions {
    return const EdgeInsets.only();
  }

  @override
  Path getInnerPath(Rect rect, { TextDirection textDirection }) {
    return getOuterPath(rect, textDirection: textDirection);
  }

  @override
  Path getOuterPath(Rect rect, { TextDirection textDirection }) {
    return Path()
      ..moveTo(rect.left + rect.width / 2.0, rect.top)
      ..lineTo(rect.width, rect.height * 0.25)
      ..lineTo(rect.width, rect.height * 0.75)
      ..lineTo(rect.width  / 2.0, rect.bottom)
      ..lineTo(0, rect.height * 0.75)
      ..lineTo(0, rect.height * 0.25)
      ..close();
  }

  @override
  void paint(Canvas canvas, Rect rect, { TextDirection textDirection }) {}

  // This border doesn't support scaling.
  @override
  ShapeBorder scale(double t) {
    return null;
  }
}