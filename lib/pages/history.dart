import 'package:farax/pages/failed_screen.dart';
import 'package:farax/pages/profile.dart';
import 'package:flutter/material.dart';
import 'package:gradient_text/gradient_text.dart';
import '../all_translations.dart';
import '../components/gradient_appbar.dart';
import 'completed_screen.dart';
import 'warehouse_screen.dart';
import 'home.dart';
import '../pages/shipper/income_screen.dart';

class History extends StatefulWidget {
  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  int _selectedIndex = 0;

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


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Container(
          child: Column(
            children: <Widget>[
              GradientAppBar(title: allTranslations.text('history_title')),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: TabBar(
                  indicatorColor: Colors.orange,
                  labelColor: Color.fromRGBO(121, 141, 153, 1),
                  tabs: <Widget>[
                    Tab(child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.check, color: Colors.green),
                        SizedBox(width: 8,),
                        Text(allTranslations.text('completed'))
                      ],
                    ),),
                    Tab(child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.block, color: Color.fromRGBO(160, 176, 185, 1)),
                        SizedBox(width: 8,),
                        Text(allTranslations.text('failed'))
                      ],
                    ),),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: <Widget>[
                    CompletedScreen(),
                    FailedScreen(),
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