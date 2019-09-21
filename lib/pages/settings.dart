import 'package:farax/components/hex_color.dart';
import 'package:farax/components/language_switch.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/network_utils.dart';
import '../all_translations.dart';
import '../components/gradient_appbar.dart';
import 'package:material_switch/material_switch.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  List<String> switchOptions = ["EN", "CAM"];
  String selectedSwitchOption = "EN";
  bool isSwitched = false;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  SharedPreferences _sharedPreferences;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
	void initState() {
		super.initState();
    _fetchSessionAndNavigate();
	}

  _fetchSessionAndNavigate() async {
		_sharedPreferences = await _prefs;
		if(mounted) {
      setState(() {
        selectedSwitchOption = _sharedPreferences.getString('MyApplication_language') != null ? _sharedPreferences.getString('MyApplication_language').toUpperCase() : null;
      });
    }
  }

  _logout() async {
    _sharedPreferences = await _prefs;
		NetworkUtils.logoutUser(_scaffoldKey.currentContext, _sharedPreferences);
	}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        child: Column(
          children: <Widget>[
            GradientAppBar(title: allTranslations.text('settings_title'), hasBackIcon: true),
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(allTranslations.text('language'), style: TextStyle(color: HexColor('#455A64')),),
                        Container(
                          alignment: Alignment.centerRight,
                          width: 100,
                          child: Column(
                            children: <Widget>[
                              new LanguageSwitch(
                                padding: const EdgeInsets.all(5.0),
                                margin: const EdgeInsets.all(5.0),
                                selectedOption: selectedSwitchOption,
                                options: switchOptions,
                                selectedBackgroundColor: HexColor('#0099CC'),
                                selectedTextColor: Colors.white,
                                onSelect: (String selectedOption) {
                                  setState(() {
                                    selectedSwitchOption = selectedOption;
                                  });
                                  allTranslations.setNewLanguage(selectedOption.toLowerCase(), true);
                                },
                              ),
                            ],
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
                        Text(allTranslations.text('logout'),  style: TextStyle(color: HexColor('#455A64'))),
                        Expanded(
                          flex: 1,
                          child: IconButton(
                            onPressed: () {_logout();},
                            icon: Icon(Icons.exit_to_app, size: 24, color: Color.fromRGBO(22, 170, 215, 1)),
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
    );
  }
}