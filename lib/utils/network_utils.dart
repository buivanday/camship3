import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'auth_utils.dart';
import '../all_translations.dart';

class NetworkUtils {
	static final String host = 'https://camships.com:3000';
  //AIzaSyARcYGPWEpcRSKw8sAuCWTztTQfTio70g8
  //AIzaSyC8V6p9SdM7cTPTnrJHdGr3oYVQ4Wvi9rc

  //AIzaSyD-SBeYjgsC0QA4zu5Nk7QPRPLS8li9cgc
	static dynamic authenticateUser(String email, String password) async {
		var uri = host + AuthUtils.endPoint;

		try {
			final response = await http.post(
				uri,
				body: {
					'username': email,
					'password': password
				}
			);

			final responseJson = json.decode(response.body);
			return responseJson;

		} catch (exception) {
			if(exception.toString().contains('SocketException')) {
				return 'NetworkError';
			} else {
				return null;
			}
		}
	}

	static logoutUser(BuildContext context, SharedPreferences prefs) async {
    String authToken = AuthUtils.getToken(prefs);
    var uri = host + AuthUtils.logoutUrl + '?access_token=' + authToken;
		try {
      await http.post(uri);
			prefs.setString(AuthUtils.authTokenKey, null);
      prefs.setString(AuthUtils.userIdKey, null);
      prefs.setString(AuthUtils.nameKey, null);
      prefs.setString(AuthUtils.phoneNumber, null);
      prefs.setString(AuthUtils.address, null);
      // Navigator.of(context).pushReplacementNamed('/login');
      Navigator.pushNamedAndRemoveUntil(context, '/login', ModalRoute.withName('/login'));

		} catch (exception) {
			if(exception.toString().contains('SocketException')) {
				return 'NetworkError';
			} else {
				prefs.setString(AuthUtils.authTokenKey, null);
        prefs.setString(AuthUtils.userIdKey, null);
        prefs.setString(AuthUtils.nameKey, null);
        prefs.setString(AuthUtils.phoneNumber, null);
        prefs.setString(AuthUtils.address, null);
        // Navigator.of(context).pushReplacementNamed('/login');
        Navigator.pushNamedAndRemoveUntil(context, '/login', ModalRoute.withName('/login'));
			}
		}
	}

	static showSnackBar(GlobalKey<ScaffoldState> scaffoldKey, String message) {
		scaffoldKey.currentState.showSnackBar(
			new SnackBar(
				content: new Text(message ?? allTranslations.text('you_are_offline')),
			)
		);
	}

  static httpGetAddress(String address) async {
    try {
			final response = await http.get(
				"https://maps.googleapis.com/maps/api/place/autocomplete/json?input="+ Uri.encodeFull(address)+"&inputtype=textquery&fields=address_component,adr_address,alt_id,formatted_address,geometry,icon,id,name,permanently_closed,photo,place_id,plus_code,scope,type,url,utc_offset,vicinity&components=country:kh&types=geocode|establishment&key=AIzaSyD-SBeYjgsC0QA4zu5Nk7QPRPLS8li9cgc",
			);

			final responseJson = json.decode(response.body);
			return responseJson;
		} catch (exception) {
			if(exception.toString().contains('SocketException')) {
				return 'NetworkError';
			} else {
				return null;
			}
		}
  }

  static httpGetAddressDetail(String placeId) async {
    try {
			final response = await http.get(
				"https://maps.googleapis.com/maps/api/place/details/json?placeid="+placeId+"&key=AIzaSyD-SBeYjgsC0QA4zu5Nk7QPRPLS8li9cgc",
			);

			final responseJson = json.decode(response.body);
			return responseJson;
		} catch (exception) {
			if(exception.toString().contains('SocketException')) {
				return 'NetworkError';
			} else {
				return null;
			}
		}
  }

  static httpGetDetailFromLatLng(String lat, String lng) async {
    try {
			final response = await http.get(
				"https://maps.googleapis.com/maps/api/geocode/json?latlng="+lat.toString()+","+lng.toString()+"&result_type=sublocality|establishment|route&key=AIzaSyD-SBeYjgsC0QA4zu5Nk7QPRPLS8li9cgc",
			);

			final responseJson = json.decode(response.body);
			return responseJson;
		} catch (exception) {
			if(exception.toString().contains('SocketException')) {
				return 'NetworkError';
			} else {
				return null;
			}
		}
  }

  static fetchWithoutAuthorization(var endPoint) async {
		var uri = host + endPoint;

		try {
			final response = await http.get(
				uri,
			);

			final responseJson = json.decode(response.body);
			return responseJson;

		} catch (exception) {
			if(exception.toString().contains('SocketException')) {
				return 'NetworkError';
			} else {
				return null;
			}
		}
	}

	static fetch(var authToken, var endPoint) async {
		var uri = host + endPoint;

		try {
			final response = await http.get(
				uri,
				headers: {
					'Authorization': authToken
				},
			);

			final responseJson = json.decode(response.body);
			return responseJson;

		} catch (exception) {
			if(exception.toString().contains('SocketException')) {
				return 'NetworkError';
			} else {
				return null;
			}
		}
	}

  static post(var authToken, var endPoint) async {
		var uri = host + endPoint + '?access_token=' + authToken;

		try {
			final response = await http.post(
				uri,
			);

			final responseJson = json.decode(response.body);
			return responseJson;

		} catch (exception) {
			print(exception);
			if(exception.toString().contains('SocketException')) {
				return 'NetworkError';
			} else {
				return null;
			}
		}
	}

  static postWithBody(var authToken, var endPoint, dynamic body) async {
		var uri = host + endPoint + '?access_token=' + authToken;

		try {
			final response = await http.post(
				uri,
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
			);

			final responseJson = json.decode(response.body);
			return responseJson;

		} catch (exception) {
			print(exception);
			if(exception.toString().contains('SocketException')) {
				return 'NetworkError';
			} else {
				return null;
			}
		}
	}

  static postWithBodyWithoutAuth(var endPoint, dynamic body) async {
		var uri = host + endPoint;

		try {
      // http.post(uri, )
			final response = await http.post(
				uri,
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
			);

			final responseJson = json.decode(response.body);
			return responseJson;

		} catch (exception) {
			// print(exception);
			if(exception.toString().contains('SocketException')) {
				return 'NetworkError';
			} else {
				return null;
			}
		}
	}

  static putWithBody(var authToken, var endPoint, dynamic body) async {
		var uri = host + endPoint + '?access_token=' + authToken;

		try {
			final response = await http.put(
				uri,
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
			);

			final responseJson = json.decode(response.body);
			return responseJson;

		} catch (exception) {
			print(exception);
			if(exception.toString().contains('SocketException')) {
				return 'NetworkError';
			} else {
				return null;
			}
		}
	}

  static patch(var authToken, var endPoint, dynamic body) async {
		var uri = host + endPoint + '?access_token=' + authToken;

		try {
			final response = await http.patch(
				uri,
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
			);

			final responseJson = json.decode(response.body);
			return responseJson;

		} catch (exception) {
			print(exception);
			if(exception.toString().contains('SocketException')) {
				return 'NetworkError';
			} else {
				return null;
			}
		}
	}
}
