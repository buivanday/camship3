import 'package:farax/pages/history.dart';
import 'package:farax/pages/profile.dart';
import 'package:farax/pages/shipper/income_screen.dart';
import 'package:flutter/material.dart';
import 'package:gradient_text/gradient_text.dart';
import '../all_translations.dart';
import '../components/gradient_appbar.dart';
import 'shop_screen.dart';
import 'warehouse_screen.dart';
import 'pending_screen.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 1;
  String shopQuantity = '';
  String warehouseQuantity = '';
  String pendingQuantity = '';

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

  setShopQuantity(int newQuantity) {
    if(mounted) {
      setState(() {
        shopQuantity = newQuantity > 0 ? '(${newQuantity.toString()})' : '';
      });
    }
  }

  setWarehouseQuantity(int newQuantity) {
    if(mounted) {
      setState(() {
        warehouseQuantity = newQuantity > 0 ? '(${newQuantity.toString()})' : '';
      });
    }
  }

  setPendingQuantity(int newQuantity) {
    if(mounted) {
      setState(() {
        pendingQuantity = newQuantity > 0 ? '(${newQuantity.toString()})' : '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {},
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          body: Container(
            color: Color.fromRGBO(242, 242, 242, 1),
            child: Column(
              children: <Widget>[
                GradientAppBar(title: allTranslations.text('home_title')),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TabBar(
                    indicatorColor: Colors.orange,
                    labelColor: Color.fromRGBO(121, 141, 153, 1),
                    tabs: <Widget>[
                      Tab(text: allTranslations.text('shop_title') + shopQuantity),
                      Tab(text: allTranslations.text('warehouse_title') + warehouseQuantity),
                      Tab(text: allTranslations.text('pending_title') + pendingQuantity)
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: <Widget>[
                      ShopScreen(setShopQuantity),
                      WarehouseScreen(setWarehouseQuantity),
                      PendingScreen(setPendingQuantity)
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
      ),
    ); 
  }
}