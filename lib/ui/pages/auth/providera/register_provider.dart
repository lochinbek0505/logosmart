import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegisterProvider with ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Map<String, dynamic> payload = {};
  Map<String, dynamic> regions = {};
  List<Map<String, dynamic>> regionsList = [];
  List<Map<String, dynamic>> districts = [];

  Future<void> initRegions() async {
    try {
      var regionJson = await rootBundle.loadString('assets/jsons/regions.json');
      regions = json.decode(regionJson);

      if (regions['regions'] != null) {
        regionsList = List<Map<String, dynamic>>.from(regions['regions']);
      }
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void getDistricts(int regionId) {
    if (regions['districts'] != null) {
      var allDistricts = List<Map<String, dynamic>>.from(regions['districts']);
      districts = allDistricts
          .where((element) => element['region_id'] == regionId)
          .toList();
      notifyListeners();
    }
  }
}