import 'package:farax/all_translations.dart';
import 'package:farax/components/hex_color.dart';
import 'package:flutter/material.dart';

class Congratulation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.asset('icons/Group_2.1.png'),
          SizedBox(height: 24,),
          Text(allTranslations.text('congratulation'), style: TextStyle(color: HexColor('#FF9933'), fontWeight: FontWeight.bold, fontSize: 18.0),),
          SizedBox(height: 16,),
          Text(allTranslations.text('congratulation_text'), style: TextStyle(color: HexColor('#455A64')),),
          SizedBox(height: 36,),
          RaisedButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/main');
            },
            color: HexColor('#FF9933'),
            textColor: Colors.white,
            child: Text(allTranslations.text('back_to_home').toUpperCase(), ),
          )
        ],
      ),
    ),
    );
  }
}