

import 'package:shared_preferences/shared_preferences.dart';

class CacheService{
  SharedPreferences? cacheStorage;

  initPreference() async{
    cacheStorage ??= await SharedPreferences.getInstance();
  }

  setCacheString(String key, String value) async{
    await cacheStorage?.setString(key, value);
  }


  getCacheString(String key){
    return cacheStorage?.getString(key);
  }
}