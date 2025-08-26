import 'dart:async';


import 'package:flutter/material.dart';
import 'package:flutter_application_1/Screens/auth/login_screen.dart';
import 'package:flutter_application_1/color/colors.dart';
import 'package:flutter_application_1/prefs/PreferencesKey.dart';
import 'package:flutter_application_1/prefs/app_preference.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageSelectionScreen extends StatefulWidget {
  @override
  _LanguageSelectionScreenState createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen>
    with TickerProviderStateMixin {
  String selectedLanguage = 'en';
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();

    // 5 animated items: Title, subtitle, and 3 language tiles
    _controllers = List.generate(
      5,
      (index) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 500),
      ),
    );

    _animations = _controllers
        .map((controller) =>
            CurvedAnimation(parent: controller, curve: Curves.easeIn))
        .toList();

    _startAnimations();
  }

  void _startAnimations() async {
    for (int i = 0; i < _controllers.length; i++) {
      await Future.delayed(Duration(milliseconds: 300));
      _controllers[i].forward();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _changeLanguage(String code) async {
   // final prefs = await SharedPreferences.getInstance();
        await AppPreference().setString(
                                  PreferencesKey.selected_language,
                                  code,
                                ); 
    Get.updateLocale(Locale(code));
    Get.off(LoginPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 100),
                FadeTransition(
                  opacity: _animations[0],
                  child: Text(
                    "language_title".tr,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                FadeTransition(
                  opacity: _animations[1],
                  child: Text(
                    "language_subtitle".tr,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 40),
                FadeTransition(
                  opacity: _animations[2],
                  child: buildLanguageTile(
                    'en',
                    'English',
                    'अंग्रेजी',
                    'assets/images/eng.png',
                  ),
                ),
                SizedBox(height: 12),
                FadeTransition(
                  opacity: _animations[3],
                  child: buildLanguageTile(
                    'hn',
                    'Hindi',
                    'हिंदी',
                    'assets/images/hindi.png',
                  ),
                ),
                SizedBox(height: 12),
                FadeTransition(
                  opacity: _animations[4],
                  child: buildLanguageTile(
                    'mr',
                    'Marathi',
                    'मराठी',
                    'assets/images/marathi_icon.png',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildLanguageTile(
  String code,
  String title,
  String subtitle,
  String flagPath,
) {
  final bool isSelected = selectedLanguage == code;

  return GestureDetector(
    onTap: () {
      setState(() {
        selectedLanguage = code;
      });
      _changeLanguage(code); 
    },
    child: Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isSelected ? Color(0xFFFFF3E0) : Colors.white,
        border: Border.all(
          color: isSelected ? Colors.orange : Colors.grey.shade300,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Image.asset(flagPath, height: 24, width: 24),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "$title / $subtitle",
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
          Icon(
            isSelected ? Icons.check_circle : Icons.radio_button_off,
            color: isSelected ? Colors.orange : Colors.grey,
          ),
        ],
      ),
    ),
  );
}
    }