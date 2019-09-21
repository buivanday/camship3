import 'package:flutter/material.dart';

import '../all_translations.dart';
////
class OfflineNotification extends StatelessWidget {
  _containerOffline(){
    return  Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              decoration: BoxDecoration(
                color: Colors.blueGrey
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(allTranslations.text('you_are_offline'), style: TextStyle(color: Colors.white),), 
                ],
              )
            ),
            Expanded(
              child: Container(
                child: Center(
                  child: CircularProgressIndicator(strokeWidth: 2.0,), 
                ),
              ),
            )
          ],
        );
    }
  @override
  Widget build(BuildContext context) {
    return _containerOffline();
  }
}