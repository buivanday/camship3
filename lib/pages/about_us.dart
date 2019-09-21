import 'package:farax/components/gradient_appbar.dart';
import 'package:farax/components/hex_color.dart';
import 'package:flutter/material.dart';
import '../all_translations.dart';

class AboutUs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Column(
        children: <Widget>[
          GradientAppBar(title: allTranslations.text('about_us'),hasBackIcon:true),
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(allTranslations.text('about_farax_general'), style: TextStyle(color: HexColor('#455A64')),),
                  SizedBox(height: 20,),
                  Text(allTranslations.text('about_farax_our_vision_title'), style: TextStyle(color: HexColor('#FF9933'), fontWeight: FontWeight.bold),),
                  SizedBox(height: 8,),
                  Text(allTranslations.text('about_farax_our_vision_text'), style: TextStyle(color: HexColor('#455A64'))),
                  SizedBox(height: 20,),
                  Text(allTranslations.text('about_farax_our_mission_title'), style: TextStyle(color: HexColor('#FF9933'), fontWeight: FontWeight.bold),),
                  SizedBox(height: 8,),
                  Text(allTranslations.text('about_farax_our_mission_text'), style: TextStyle(color: HexColor('#455A64'))),
                  SizedBox(height: 20,),
                  Text(allTranslations.text('about_farax_our_history_title'), style: TextStyle(color: HexColor('#FF9933'), fontWeight: FontWeight.bold),),
                  SizedBox(height: 8,),
                  Text(allTranslations.text('about_farax_our_history_text'), style: TextStyle(color: HexColor('#455A64'))),
                  SizedBox(height: 20,),
                  Text(allTranslations.text('about_farax_our_core_value_title'), style: TextStyle(color: HexColor('#FF9933'), fontWeight: FontWeight.bold),),
                  SizedBox(height: 8,),
                  RichText(
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(text: allTranslations.text('about_farax_our_core_value_fastest_title') + ': ', style:TextStyle(color: HexColor('#364851'), fontWeight: FontWeight.bold)),
                        TextSpan(text: allTranslations.text('about_farax_our_core_value_fastest'), style: TextStyle(color: HexColor('#455A64'))),
                      ]
                    ),
                  ),
                  SizedBox(height: 8,),
                  RichText(
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(text: allTranslations.text('about_farax_our_core_value_accountability_title') + ': ', style:TextStyle(color: HexColor('#364851'), fontWeight: FontWeight.bold)),
                        TextSpan(text: allTranslations.text('about_farax_our_core_value_accountability'), style: TextStyle(color: HexColor('#455A64'))),
                      ]
                    ),
                  ),
                  SizedBox(height: 8,),
                  RichText(
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(text: allTranslations.text('about_farax_our_core_value_responsibility_title') + ': ', style:TextStyle(color: HexColor('#364851'), fontWeight: FontWeight.bold)),
                        TextSpan(text: allTranslations.text('about_farax_our_core_value_responsibility'), style: TextStyle(color: HexColor('#455A64'))),
                      ]
                    ),
                  ),
                  SizedBox(height: 8,),
                  RichText(
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(text: allTranslations.text('about_farax_our_core_value_adaptability_title') + ': ', style:TextStyle(color: HexColor('#364851'), fontWeight: FontWeight.bold)),
                        TextSpan(text: allTranslations.text('about_farax_our_core_value_adaptability'), style: TextStyle(color: HexColor('#455A64'))),
                      ]
                    ),
                  ),
                  SizedBox(height: 8,),
                  RichText(
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(text: allTranslations.text('about_farax_our_core_value_exactness_title') + ': ', style:TextStyle(color: HexColor('#364851'), fontWeight: FontWeight.bold)),
                        TextSpan(text: allTranslations.text('about_farax_our_core_value_exactness'), style: TextStyle(color: HexColor('#455A64'))),
                      ]
                    ),
                  ),
                ],
              ),
              )
            ),
          )
        ],
      ),
    );
  }
}