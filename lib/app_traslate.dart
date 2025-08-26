import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AppTranslations extends Translations {
  final Map<String, Map<String, String>> translations;

  AppTranslations(this.translations);

  static Future<Map<String, Map<String, String>>> loadJsonTranslations() async {
    final enJson = await rootBundle.loadString('assets/en.json');
    final mrJson = await rootBundle.loadString('assets/mr.json');
    final hnJson = await rootBundle.loadString('assets/hn.json');

    final Map<String, dynamic> enMap = json.decode(enJson);
    final Map<String, dynamic> mrMap = json.decode(mrJson);
    final Map<String, dynamic> hnMap = json.decode(hnJson);

    return {
      'en': enMap.map((key, value) => MapEntry(key, value.toString())),
      'mr': mrMap.map((key, value) => MapEntry(key, value.toString())),
      'hn': hnMap.map((key, value) => MapEntry(key, value.toString())),
    };
  }

  @override
  Map<String, Map<String, String>> get keys => translations;
}
