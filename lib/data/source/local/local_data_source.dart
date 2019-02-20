import 'package:shared_preferences/shared_preferences.dart';

class LocalDataSource {
  static final LocalDataSource singleton = LocalDataSource.internal();

  factory LocalDataSource() {
    return singleton;
  }

  LocalDataSource.internal();

  Future<String> getString(String key) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(key);
  }

  Future<bool> setString(String key, String value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return await sharedPreferences.setString(key, value);
  }

  Future<bool> getBool(String key) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getBool(key);
  }

  Future<bool> setBool(String key, bool value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return await sharedPreferences.setBool(key, value);
  }
}
