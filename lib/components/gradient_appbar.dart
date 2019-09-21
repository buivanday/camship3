import 'package:farax/pages/profile_edit.dart';
import 'package:farax/pages/shop/add_address_book.dart';
import 'package:farax/pages/shop/address_book.dart';
import 'package:flutter/material.dart';
import '../all_translations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../pages/shop/create_package.dart';
import '../pages/shop/create_package_information.dart';

class GradientAppBar extends StatelessWidget {
  GradientAppBar({
    Key key,
    this.title = '',
    this.hasActions = false, 
    this.hasBackIcon = false,
    this.backToHome = false,
    this.isEditProfile = false,
    this.closeIcon = false,
    this.plusIcon = false,
    this.hasDone = false,
    this.actionDone,
    this.backtoShopHome = false,
    this.backToAddresses = false,
    this.backtoProfile = false,
    this.backToCreatePackage = false,
    this.backToCreatePackageInfo = false,
    this.actionCreatePackage
  }) : super(key: key);
  final String title;
  final bool hasActions;
  final bool hasBackIcon;
  final bool backtoProfile;
  final bool backToHome;
  final bool isEditProfile;
  final bool closeIcon;
  final bool plusIcon;
  final bool hasDone;
  final bool backToAddresses;
  final double barHeight = 66.0;
  final bool backtoShopHome;
  final Function actionDone;
  final VoidCallback actionCreatePackage;
  
  final bool backToCreatePackageInfo;
  final bool backToCreatePackage;
  
  
  @override
  Widget build(BuildContext context) {
     Future<String> _getJsonDataPageOne() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('dataPageOne') ?? '';
  }
    pageCreatePackage(bool type){
    if(type){  
      Navigator.of(context).push(new PageRouteBuilder(
        pageBuilder: (BuildContext context, _,__ ){
          return CreatePackage(     
              );
            }
          ));
    }else{
       Navigator.of(context).pushReplacement(new PageRouteBuilder(
        pageBuilder: (BuildContext context, _,__ ){
          return CreatePackage(     
              );
            }
          ));
    }
    
  }
  pageCreatePackageInfo(bool type)async{
    var dataPage2 = await _getJsonDataPageOne();
         // print(dataPage2);
    var obj = jsonDecode(dataPage2);
    if(type){
      Navigator.of(context).push(new PageRouteBuilder(
        pageBuilder: (BuildContext context, _, __) {
          return CreatePackageInformation(
            zoneInformation: obj['zoneInformation'],
              );
            },
          ));
    } 
    else{
      Navigator.of(context).pushReplacement(new PageRouteBuilder(
        pageBuilder: (BuildContext context, _, __) {
          return CreatePackageInformation(
            zoneInformation: obj['zoneInformation'],
              );
            },
          ));
    }
  }
    return PreferredSize(
      child: new Container(
        padding: new EdgeInsets.only(
          top: MediaQuery.of(context).padding.top
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: hasBackIcon ? IconButton(
                icon: Icon(closeIcon ? Icons.close : Icons.arrow_back),
                color: Colors.white,
                alignment: Alignment.centerLeft,
                onPressed: () { 
                  if(backToHome == true) {
                    Navigator.of(context)
                      .pushNamedAndRemoveUntil('/main', (Route<dynamic> route) => false);
                  } else if(backtoShopHome == true) {
                    Navigator.of(context)
                      .pushNamedAndRemoveUntil('/main-shop', (Route<dynamic> route) => false);
                  } else if(backToAddresses == true) {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => AddressBook()
                    ));
                  }else if(backToCreatePackageInfo==true){
                    //actionCreatePackage();
                    pageCreatePackageInfo(true);
                  } else if(backToCreatePackage==true){ 
                   
                  }else {
                    Navigator.pop(context);
                  }
                },
              ) : SizedBox(width: 0, height: 0),
              flex: 1,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Align(
                  child: Text(title, style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 18.0
                  ))
                ),
              ),
              flex: 2,
            ),
            Expanded(
              child: hasActions ? Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: InkWell(
                    onTap: () {
                        Navigator.pushNamed(context, '/profile-edit');
                    },
                    child: plusIcon == false ? hasDone == true ? InkWell(
                      onTap: () {
                        actionDone();
                      },
                      child: Text(allTranslations.text('done').toUpperCase(), style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 18.0
                    )),
                    ) : Text(allTranslations.text(isEditProfile ? 'edit' : 'home_pickout').toUpperCase(), style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 18.0
                    )) : InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          new PageRouteBuilder(
                            pageBuilder: (BuildContext context, _, __) {
                              return AddAddressBook();
                            },
                          )
                        );
                      },
                      child: Icon(Icons.add, color: Colors.white,),
                    ),
                  ),
                )
              ) : SizedBox(height: 0,width: 0,),
              flex: 1,
            )
          ],
        ),
        decoration: new BoxDecoration(
          gradient: new LinearGradient(
            colors: [
              Color.fromRGBO(0, 201, 232, 1),
              Color.fromRGBO(0, 153, 204, 1)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter
          ),
          boxShadow: [
            new BoxShadow(
              color: Colors.grey[500],
              blurRadius: 20.0,
              spreadRadius: 1.0,
            )
          ]
        ),
      ),
      preferredSize: new Size(
        MediaQuery.of(context).size.width,
        66.0
      ),
    );
  }
}