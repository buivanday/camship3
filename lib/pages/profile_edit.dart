import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:farax/components/hex_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../all_translations.dart';
import '../components/gradient_appbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/auth_utils.dart';
import '../utils/network_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';

class ProfileEdit extends StatefulWidget {
  @override
  _ProfileEditState createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
	Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences _sharedPreferences;
  bool _genderBool = false;
  TextEditingController _fullNameController, _phoneNumberController, _addressController;
  File _avatar;
  Future getProfile;

  @override
	void initState() {
		super.initState();
    _fullNameController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _addressController = TextEditingController();
    getProfile = _getProfile();
	}

  Future getImage(context) async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
  // ImagePicker.pickImage(source: ImageSu)
    setState(() {
      _avatar = image;
      Navigator.pop(context);
    });
  }

  Future getImageFromGallery(context) async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _avatar = image;
      Navigator.pop(context);
    }); 
  }

  void _settingModalBottomSheet(context){
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc){
          return Container(
            child: new Wrap(
            children: <Widget>[
              new ListTile(
                leading: new Icon(Icons.image),
                title: new Text('Gallery'),
                onTap: () {
                  getImageFromGallery(context);
                }     
              ),
              new ListTile(
                leading: new Icon(Icons.camera),
                title: new Text('Camera'),
                onTap: () {
                  getImage(context);
                },          
              ),
              new ListTile(
                leading: new Icon(Icons.cancel),
                title: new Text('Cancel'),
                onTap: () {
                  Navigator.pop(context);
                },          
              ),
            ],
          ),
          );
      }
    );
}

Future _uploadAvatar() async {
  try {
    var dio = Dio();
    _sharedPreferences = await _prefs;
    String name = _sharedPreferences.getString('name').replaceAll(' ', '_');
    if(_avatar != null) {
      FormData formData = FormData.from({
        "file": UploadFileInfo(_avatar, "avatar_${name}.jpg")
      });

      var response = await dio.post('https://camships.com:3000/api/attachments/camship/upload', data: formData);
      if(response.data != null && response.data['result'] != null && response.data['result']['files'] != null) {
        var avatar = response.data['result']['files']['file'][0]['name'];
        String authToken = AuthUtils.getToken(_sharedPreferences);
        var res = await NetworkUtils.putWithBody(authToken, '/api/Members/profile', {
          'avatar': avatar,
          'fullName': _fullNameController.text,
          'phoneNumber': _phoneNumberController.text,
          'address': _addressController.text
        });

        Fluttertoast.showToast(
          msg: allTranslations.text('update_profile_successfully'),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0
        );
        AuthUtils.updateDetails(_sharedPreferences, res);
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pushNamed(context, '/profile-detail');
      }
    } else {
      String authToken = AuthUtils.getToken(_sharedPreferences);
      var res = await NetworkUtils.putWithBody(authToken, '/api/Members/profile', {
          'fullName': _fullNameController.text,
          'phoneNumber': _phoneNumberController.text,
          'address': _addressController.text
        });

        print(res);

        Fluttertoast.showToast(
          msg: allTranslations.text('update_profile_successfully'),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0
        );

        AuthUtils.updateDetails(_sharedPreferences, res);
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pushNamed(context, '/profile-detail');
    }
    
  } catch(err) {
    print(err);
  }
}

  Future _getProfile() async {
    _sharedPreferences = await _prefs;
		var name = _sharedPreferences.getString(AuthUtils.nameKey);
    var phoneNumber = _sharedPreferences.getString(AuthUtils.phoneNumber);
    var address = _sharedPreferences.getString(AuthUtils.address);
    _fullNameController.text =  name;
    _phoneNumberController.text = phoneNumber;
    _addressController.text = address;
		String authToken = AuthUtils.getToken(_sharedPreferences);
    return NetworkUtils.fetch(authToken, '/api/Members/profile');
  }

  _logout() {
		NetworkUtils.logoutUser(_scaffoldKey.currentContext, _sharedPreferences);
	}
  
  @override
  Widget build(BuildContext context) {
    print('build');
    return Scaffold(
      body: Container(
        child: Column(
          children: <Widget>[
          GradientAppBar(title: allTranslations.text('edit'), hasBackIcon: true,closeIcon: true),
          Expanded(
            flex: 1,
            child: FutureBuilder(
              future: getProfile,
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
                      String _av = snapshot.data['avatar'];
                      return Stack(
                      children: <Widget>[
                        Container(
                          color: Color.fromRGBO(245, 245, 245, 1)
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            FocusScope.of(context).requestFocus(new FocusNode());
                          },
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 115, 16, 16),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(Radius.circular(4.0))
                                ),
                                child: Container(
                                  padding: const EdgeInsets.only(top: 80, left: 8, right: 8, bottom: 90),
                                  child: Column(
                                    children: <Widget>[
                                      TextFormField(
                                          decoration: InputDecoration(
                                            labelText: allTranslations.text('full_name'),
                                            labelStyle: TextStyle(color: HexColor('#B0BEC5'), fontSize: 14.0),
                                          ),
                                          textCapitalization: TextCapitalization.sentences,
                                          controller: _fullNameController,
                                          onFieldSubmitted: (String value) {
                                            _fullNameController.text = value;
                                          },
                                          style: TextStyle(color: HexColor('#455A64')),
                                        ),
                                      SizedBox(height: 25),
                                      TextFormField(
                                        decoration: InputDecoration(
                                          labelText: allTranslations.text('form_phone_number'),
                                          labelStyle: TextStyle(color: HexColor('#B0BEC5'), fontSize: 14),
                                        ),
                                        keyboardType: TextInputType.number,
                                        controller: _phoneNumberController,
                                        style: TextStyle(color: HexColor('#455A64')),
                                      ),
                                      SizedBox(height: 25),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(color: HexColor('#DFE4EA')),
                                            borderRadius: BorderRadius.all(Radius.circular(60.0))
                                          ),
                                          width: 172.0,
                                          height: 40.0,
                                          child: Row(
                                            children: <Widget>[
                                              Expanded(
                                                flex: 1,
                                                child: InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      _genderBool = false;
                                                    });
                                                  },
                                                  child: Container(
                                                    decoration: _genderBool == false ? BoxDecoration(
                                                      borderRadius: BorderRadius.all(Radius.circular(60.0)),
                                                      gradient: LinearGradient(
                                                        begin: Alignment.topCenter,
                                                        end: Alignment.bottomCenter,
                                                        stops: [0.11, 0.75],
                                                        colors: [HexColor('#00C9E8'), HexColor('#0099CC')]
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Color.fromRGBO(0, 0, 0, 0.12),
                                                          blurRadius: 8.0,
                                                          spreadRadius: 2.0
                                                        )
                                                      ]
                                                    ) : BoxDecoration(),
                                                    child: Center(
                                                      child: Text('Male', style: TextStyle(color: _genderBool == false ? Colors.white : HexColor('#78909C'), fontSize: 14.0),),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      _genderBool = true;
                                                    });
                                                  },
                                                  child: Container(
                                                    decoration: _genderBool == true ? BoxDecoration(
                                                      borderRadius: BorderRadius.all(Radius.circular(60.0)),
                                                      gradient: LinearGradient(
                                                        begin: Alignment.topCenter,
                                                        end: Alignment.bottomCenter,
                                                        stops: [0.11, 0.75],
                                                        colors: [HexColor('#00C9E8'), HexColor('#0099CC')]
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Color.fromRGBO(0, 0, 0, 0.12),
                                                          blurRadius: 8.0,
                                                          spreadRadius: 2.0
                                                        )
                                                      ]
                                                    ) : BoxDecoration(),
                                                    child: Center(
                                                      child: Text('Female', style: TextStyle(color: _genderBool == true ? Colors.white : HexColor('#78909C'), fontSize: 14.0),),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 25.0,),
                                      Theme(
                                        data: new ThemeData(
                                          hintColor: HexColor('#DFE4EA')
                                        ),
                                        child: TextFormField(
                                          decoration: InputDecoration(
                                            labelText: allTranslations.text('address'),
                                            labelStyle: TextStyle(color: HexColor('#B0BEC5'), fontSize: 14),
                                            suffixIcon: InkWell(
                                              onTap: () {},
                                              child: Transform.rotate(
                                                angle: 0.75,
                                                child: Icon(Icons.navigation, color: Color.fromRGBO(21, 166, 212, 1), size: 24.0,),
                                              ),
                                            ),
                                          ),
                                          controller: _addressController,
                                          style: TextStyle(color: HexColor('#455A64')),
                                        ),
                                      ),
                                    ],
                                  )
                                ),
                              ),
                            )
                          ),
                        ),
                        Align(
                          alignment: Alignment.topCenter,
                          child: SizedBox(
                            width: 120,
                            height: 170,
                            child: Column(
                              children: <Widget>[
                                SizedBox(height: 50),
                                Container(
                                  constraints: BoxConstraints(maxWidth: 120, maxHeight: 120),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(Radius.circular(5)),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.all(Radius.circular(5)),
                                    child: InkWell(
                                      onTap: () {
                                        _settingModalBottomSheet(context);
                                      },
                                      child: _avatar == null ? CachedNetworkImage(
                                        imageUrl: "https://camships.com:3000/api/attachments/compressed/download/" + (_av == null ? 'logo.png' : _av),
                                        placeholder: (context, url) => new Center(child: CircularProgressIndicator(),),
                                        errorWidget: (context, url, error) => new Icon(Icons.error),
                                      ) : Image.file(_avatar, fit: BoxFit.fitWidth,),
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
              })
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: RaisedButton(
                onPressed: () {
                  _uploadAvatar();
                },
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
      ),
    ); 
  }
}