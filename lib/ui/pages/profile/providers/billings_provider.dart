import 'package:flutter/material.dart';
import 'package:logosmart/models/billings_model.dart';

import '../../../../core/network/api_service.dart';

class BillingsProvider with ChangeNotifier{

  bool isLoading = false;
  BillingsModel _billingsModel = BillingsModel();

  BillingsModel get billingsModel => _billingsModel;

  Future<void> init(BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();

      var response = await ApiService().getBillings(context);
      if (response != null) {
        _billingsModel = response;
      }
    } catch (e) {
      debugPrint("Billing ma'lumotlarini yuklashda xato: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }


}