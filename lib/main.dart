import 'dart:convert';

import 'package:farax/pages/about_us.dart';
import 'package:farax/pages/fee_service.dart';
import 'package:farax/pages/profile_detail.dart';
import 'package:farax/pages/profile_edit.dart';
import 'package:farax/pages/settings.dart';
import 'package:farax/pages/shop/address_book.dart';
import 'package:farax/pages/shop/create_package.dart';
import 'package:farax/pages/shop/create_package_information.dart';
import 'package:farax/pages/shop/create_package_services.dart';
import 'package:farax/pages/shop/home_shop.dart';
import 'package:farax/pages/shop/manage_card.dart';
import 'package:farax/services/connectivity.dart';
import 'package:farax/utils/auth_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'all_translations.dart';
import 'models/scoped_models.dart';
import 'pages/home.dart';
import 'pages/login.dart';
import 'pages/forgot_password.dart';
import 'pages/history.dart';
import 'pages/profile.dart';
import 'dart:io';
import 'dart:async';
import "package:firebase_messaging/firebase_messaging.dart";
import 'package:provider/provider.dart';
import 'services/connectivity.dart';
// import 'package:web_socket_channel/io.dart';

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp,DeviceOrientation.portraitDown])
  .then((_)async{
    await allTranslations.init();
      runApp(MyApp(), );
  });

}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences _sharedPreferences;
  var platform = MethodChannel('crossingthestreams.io/resourceResolver');
  String _imageUrl = 'https://flutter.io/images/catalog-widget-placeholder.png';

  @override
  void initState(){

    super.initState();
    firebaseCloudMessagingListeners();
  }

  void firebaseCloudMessagingListeners() async {
    _sharedPreferences = await _prefs;
    if (Platform.isIOS) iOSPermission();
    _firebaseMessaging.getToken().then((token){
      print("token: "+token);
      _sharedPreferences.setString('registrationToken', token);
    });
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');

      },

      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
      },
    );
  }

  void iOSPermission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true)
    );
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings)
    {
      print("Settings registered: $settings");
    });
  }

  _onLocaleChanged() async {
      // do anything you need to do if the language changes
      print('Language has been changed to: ${allTranslations.currentLanguage}');
  }
Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) {
  if (message.containsKey('data')) {
    // Handle data message
    final dynamic data = message['data'];
  }

  if (message.containsKey('notification')) {
    // Handle notification message
    final dynamic notification = message['notification'];
  }

  // Or do other work.
}
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final MainModel _model = MainModel();

    return ScopedModel<MainModel>(
      model: _model,
      child: MultiProvider(
        providers: [
          StreamProvider<ConnectionStatus>.value(
            value: ConnectivityService().connectivityController.stream,
          ),
        ],
        child: MaterialApp(
          title: 'Farax',
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: allTranslations.supportedLocales(),
          home: LoadingScreen(),
          routes: {
            '/login': (context) => Login(),
            '/main': (context) => Home(),
            '/history': (context) => History(),
            '/profile': (context) => Profile(),
            '/profile-detail': (context) => ProfileDetail(),
            '/profile-edit': (context) => ProfileEdit(),
            '/forgot-password': (context) => ForgotPassword(),
            '/settings': (context) => Settings(),
            '/about-us': (context) => AboutUs(),
            '/fee-service': (context) => FeeService(),
            '/main-shop': (context) => HomeShop(),
            '/manage-card': (context) => ManageCard(),
            '/address-book': (context) => AddressBook(),
            '/create-package': (context) => CreatePackage(),
            '/create-package-infomation' : (context) =>CreatePackageInformation(),
            '/create-package-services' : (context)=> CreatePackageServices()
          },
          debugShowCheckedModeBanner: false,
        )
      ),
    );
  }
}

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
	Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
	SharedPreferences _sharedPreferences;

  Future _isLoggedIn() async {
    _sharedPreferences = await _prefs;
		String authToken = AuthUtils.getToken(_sharedPreferences);
    int roleId = await _sharedPreferences.getInt('role');
    return {
      'isLoggedIn': authToken != null,
      'isShop': roleId == 4
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _isLoggedIn(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if(snapshot.hasData) {
          if(snapshot.data['isLoggedIn']) {
            if(snapshot.data['isShop']) {
              return HomeShop();
            } else {
              return Home();
            }
          } else {
            return Login();
          }
        } else {
          return Login();
        }
      },
    );
  }
}
//
// var channel = IOWebSocketChannel.connect("wss://camships.com:3000");

    // channel.stream.listen((message) {
    //   // channel.sink.add("received!");
    //   print(message);
    // });
     // FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    // var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    // var initializationSettingsIOS = IOSInitializationSettings();
    // var initializationSettings = InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);
    // flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
    //     'location_update', 'Location Updates', 'You will receive location updates here',
    //     importance: Importance.Max, priority: Priority.High);
    // var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    // var platformChannelSpecifics = new NotificationDetails(
    //     androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    // await flutterLocalNotificationsPlugin.show(
    //     0, 'New Location Received !', "Test", platformChannelSpecifics);
