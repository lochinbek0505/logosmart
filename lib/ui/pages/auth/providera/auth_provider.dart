import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logosmart/core/network/api_service.dart';
import 'package:logosmart/core/storage/token_storage.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Map<String, dynamic> payload = {};
  Map<String, dynamic> regions = {};
  List<Map<String, dynamic>> regionsList = [];
  List<Map<String, dynamic>> districts = [];

  ApiService apiService = ApiService();
  TokenStorage tokenStorage = TokenStorage();

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

  Future<bool> loginInit(context, phone, password) async {
    _isLoading = true;
    notifyListeners();
    try {
      var response = await apiService.login_init(context, {
        "phoneNumber": phone,
        "password": password,
      });
      _isLoading = false;
      notifyListeners();
      if (response) {
        return true;
      } else {
        return false;
      }
    } catch (er) {
      _isLoading = false;
      notifyListeners();

      debugPrint(er.toString());
      return false;
    }
  }

  Future<bool> loginVerify(context, phone, code) async {
    _isLoading = true;
    notifyListeners();
    try {
      var response = await apiService.login_verify(context, {
        "phoneNumber": phone,
        "code": code,
      });
      _isLoading = false;
      notifyListeners();
      if (response != null) {
        await tokenStorage.saveLoginData(response);
        return true;
      } else {
        return false;
      }
    } catch (er) {
      _isLoading = false;
      notifyListeners();

      debugPrint(er.toString());
      return false;
    }
  }

  Future<bool> registerInit(context) async {
    _isLoading = true;
    notifyListeners();
    try {
      var response = await apiService.register_init(context, payload);
      _isLoading = false;
      notifyListeners();
      if (response) {
        return true;
      } else {
        return false;
      }
    } catch (er) {
      _isLoading = false;
      notifyListeners();

      debugPrint(er.toString());
      return false;
    }
  }

  Future<bool> registerVerify(context, phone, code) async {
    _isLoading = true;
    notifyListeners();
    try {
      var response = await apiService.register_verify(context, {
        "phoneNumber": phone,
        "code": code,
      });
      _isLoading = false;
      notifyListeners();
      if (response != null) {
        await tokenStorage.saveLoginData(response);
        return true;
      } else {
        return false;
      }
    } catch (er) {
      _isLoading = false;
      notifyListeners();

      debugPrint(er.toString());
      return false;
    }
  }

  Future<bool> forgotInit(context, map) async {
    _isLoading = true;
    notifyListeners();
    try {
      var response = await apiService.forgot_init(context, map);
      _isLoading = false;
      notifyListeners();
      if (response) {
        return true;
      } else {
        return false;
      }
    } catch (er) {
      _isLoading = false;
      notifyListeners();

      debugPrint(er.toString());
      return false;
    }
  }

  Future<bool> forgetVerifyOtp(context, map) async {
    _isLoading = true;
    notifyListeners();
    try {
      var response = await apiService.forgot_verify_otp(context, map);
      _isLoading = false;
      notifyListeners();
      if (response) {
        return true;
      } else {
        return false;
      }
    } catch (er) {
      _isLoading = false;
      notifyListeners();

      debugPrint(er.toString());
      return false;
    }
  }

  Future<bool> resetPassword(context, map) async {
    _isLoading = true;
    notifyListeners();
    try {
      var response = await apiService.reset_password(context, map);
      _isLoading = false;
      notifyListeners();
      if (response) {
        return true;
      } else {
        return false;
      }
    } catch (er) {
      _isLoading = false;
      notifyListeners();

      debugPrint(er.toString());
      return false;
    }
  }

  Future<bool> checkLoginData() async {
    var data =await tokenStorage.getFullLoginData();
    if (data != null) {
      return true;
    } else {
      return false;
    }
  }
}
