import 'dart:convert';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import 'PreferencesKey.dart';

class AppPreference {
  static final AppPreference _appPreference = AppPreference._internal();

  factory AppPreference() {
    return _appPreference;
  }

  AppPreference._internal();

  SharedPreferences? _preferences;

  Future<void> initialAppPreference() async {
    _preferences = await SharedPreferences.getInstance();
  }

  Future setString(String key, String value) async {
    await _preferences?.setString(key, value);
  }

  String getString(String key, {String defValue = ''}) {
    return _preferences?.getString(key) != null
        ? (_preferences?.getString(key) ?? '')
        : defValue;
  }

  Future setInt(String key, int value) async {
    await _preferences?.setInt(key, value);
  }

  int getInt(String key, {int defValue = 0}) {
    return _preferences?.getInt(key) != null
        ? (_preferences?.getInt(key) ?? 0)
        : defValue;
  }

  Future setBool(String key, bool value) async {
    await _preferences?.setBool(key, value);
  }

  bool getBool(String key, {bool defValue = false}) {
    return _preferences?.getBool(key) ?? defValue;
  }

Future<void> clearSharedPreferences() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear(); // हेच पुरेसं आहे
  print("✅ SharedPreferences cleared");
}


  // String getStudentInfo() {
  //   log("-----dwdwdws  " +
  //       AppPreference().getString(PreferencesKey.studentData));
  //   Map<String, dynamic> userData =
  //       jsonDecode(AppPreference().getString(PreferencesKey.studentData));
  //   String classId = userData['data']['student']['st_class'] ?? "";
  //   print("Class ID: $classId");
  //   return classId;
  // }

  // bool get isLogin => getBool(PreferencesKey.isLoggedIn);
  // bool get isTeacherLogin => getBool(PreferencesKey.isTeacherLoggedIn);
  // bool get showIntro => getBool(PreferencesKey.introPage);
  // String get uType => getString(PreferencesKey.uType);
  String get uName => getString(PreferencesKey.token);

  // int get isLoginFirstTimeteacher =>

  // int  // getInt(PreferencesKey.isLoggedInFirstTimeT);get isLoginFirstTimestudent =>
  //     // getInt(PreferencesKey.isLoggedInFirstTimeSt);

  // /// Redirect user with local credentials
  // String get initRoute => isLogin
  //     ? (isTeacherLogin)
  //         ? (isLoginFirstTimeteacher == 1)
  //             ? RoutesConst.teacherHome
  //             : RoutesConst.editProfile
  //         : (isLoginFirstTimestudent == 1)
  //             ? RoutesConst.home
  //             : RoutesConst.editProfile
  //     // ? RoutesConst.teacherHome
  //     // : RoutesConst.home
  //     : showIntro
  //         ? RoutesConst.loginPage
  //         : RoutesConst.introPage;
}
