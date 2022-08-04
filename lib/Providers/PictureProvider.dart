
import 'package:duvalsx/Services/CacheService.dart';
import 'package:flutter/material.dart';

class PictureProvider with ChangeNotifier{
  CacheService cacheService = CacheService();
  static const pathKey = "path";
  static const extractKey = "extract";
  String? _path;
  String? _extract;

  String? get extract => _extract;
  String? get path => _path;

  setLastExtract(String path, String extract) async{
    await cacheService.initPreference();
    await cacheService.setCacheString(pathKey, path);
    await cacheService.setCacheString(extractKey, extract);
  }

  getLastExtract(){
    _path = cacheService.getCacheString(pathKey);
    _extract = cacheService.getCacheString(extractKey) ?? "";
    notifyListeners();
  }
}