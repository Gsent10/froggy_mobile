import 'package:shared_preferences/shared_preferences.dart';

class UserSimplePreferences {
  static SharedPreferences? _preferences;

  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();

  static Future setLaunched(bool launched) async =>
      await _preferences?.setBool('launched', launched);

  static bool? getLaunched() => _preferences?.getBool('launched');

  static Future setToken(String token) async =>
      await _preferences?.setString('token', token);

  static String? getToken() => _preferences?.getString('token');
}
