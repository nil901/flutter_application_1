
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Screens/auth/login_screen.dart';
import 'package:flutter_application_1/Screens/dashboard_screen.dart';
import 'package:flutter_application_1/Screens/langauage_select_screen.dart';
import 'package:flutter_application_1/prefs/PreferencesKey.dart';
import 'package:flutter_application_1/prefs/app_preference.dart';
import 'package:shared_preferences/shared_preferences.dart';


// class SplashServices {
//   void checkAuthentication(BuildContext context) async {
//     Future.delayed(const Duration(seconds: 1), () {
//       if (AppPreference().getString(PreferencesKey.token).isEmpty ||
//           AppPreference().getString(PreferencesKey.token) == "") {
//         //Get.to(LangvangeSelection());
        
//         Navigator.pushReplacement( 
//           context,
//           MaterialPageRoute(builder: (context) => LoginPage()),
//         );
//       } else {
//        Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => StackDashboard()),
//           );
      
//       }
//       // Navigator.popAndPushNamed(context, RoutesName.loginscreen);
//     });
//   }
// }
class SplashServices {
  void checkAuthentication(BuildContext context) async {
    // final prefs = await SharedPreferences.getInstance();
    final selectedLang =AppPreference().getString(
                                  PreferencesKey.selected_language,
                                  
                                );  

    Future.delayed(const Duration(seconds: 1), () {
     
      if (selectedLang.isEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LanguageSelectionScreen()),
        );
        return;
      }

      // token check
      final token = AppPreference().getString(PreferencesKey.token);
      if (token.isEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => StackDashboard()),
        );
      }
    });
  }
}
