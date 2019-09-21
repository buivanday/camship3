import 'package:shared_preferences/shared_preferences.dart';

class AuthUtils {

	static final String endPoint = '/api/Members/login?include=user';
  static final String logoutUrl = '/api/Members/log-out';

	// Keys to store and fetch data from SharedPreferences
	static final String authTokenKey = 'auth_token';
	static final String userIdKey = 'user_id';
	static final String nameKey = 'name';
	static final String roleKey = 'role';
  static final String phoneNumber = 'phone_number';
  static final String gender = 'gender';
  static final String address = 'address';

	static String getToken(SharedPreferences prefs) {
		return prefs.getString(authTokenKey);
	}

	static insertDetails(SharedPreferences prefs, var response) {
		prefs.setString(authTokenKey, response['id']);
		var user = response['user'];
		prefs.setString(userIdKey, user['id']);
		prefs.setString(nameKey, user['fullName']);
		prefs.setString(phoneNumber, user['phoneNumber']);
		prefs.setString(address, user['address']);
    prefs.setInt(roleKey, user['roleId']);
	}

  static updateDetails(SharedPreferences prefs, var response) {
    var user = response;
    prefs.setString(userIdKey, user['id']);
		prefs.setString(nameKey, user['fullName']);
		prefs.setString(phoneNumber, user['phoneNumber']);
		prefs.setString(address, user['address']);
    prefs.setInt(roleKey, user['roleId']);
  }
	
}