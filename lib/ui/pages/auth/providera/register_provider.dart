import 'package:flutter/material.dart';

class RegisterProvider with ChangeNotifier {
  bool _isLoading = false;

  get isLoading => _isLoading;

  Map<String,dynamic> payload={};

}
