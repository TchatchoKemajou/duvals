import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageChangeProvider with ChangeNotifier{
  SharedPreferences? languageStorage;
  Locale? _currentLocale;
  String _currentLocaleName = "";
  bool _doneLoading = false;

  Locale? get currentLocale => _currentLocale;
  String get currentLocaleName => _currentLocaleName;

  bool get doneLoading => _doneLoading;

  set doneLoading(bool value) {
    _doneLoading = value;
    notifyListeners();
  }

  LanguageChangeProvider(){
    loadLanguage();
  }
  changeLocaleName(String value) {
    _currentLocaleName = value;
    notifyListeners();
  }

  initPreference() async{
    if(languageStorage == null){
      languageStorage = await SharedPreferences.getInstance();
    }else{
    }
  }

  loadLanguage() async {
    await initPreference();
    _currentLocale = languageStorage!.getString('lang') == null || languageStorage!.getString('lang') ==  "" ?  const Locale("fr")  : Locale(languageStorage!.getString('lang')!);
    _currentLocaleName = languageStorage!.getString('langName') ?? "Français";
    notifyListeners();
  }

  setLanguage(String lang, String langName) async {
    await initPreference();
    languageStorage?.setString('lang', lang);
    languageStorage?.setString('langName', langName);
    notifyListeners();
  }

  changeLocale(String locale, String localeName){
    _currentLocale = Locale(locale);
    _currentLocaleName = localeName;
    notifyListeners();
    setLanguage(locale, localeName);
  }

}