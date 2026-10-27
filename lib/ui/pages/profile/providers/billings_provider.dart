import 'package:flutter/material.dart';
import 'package:logosmart/models/billings_model.dart';

import '../../../../core/network/api_service.dart';

class BillingsProvider with ChangeNotifier {
  bool isLoading = false;

  /// Oxirgi so'rov muvaffaqiyatsiz — bo'sh ro'yxat "to'lov yo'q" degani emas
  bool hasError = false;
  BillingsModel _billingsModel = BillingsModel();

  BillingsModel get billingsModel => _billingsModel;

  Future<void> init(BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();

      var response = await ApiService().getBillings(context);
      hasError = response == null;
      if (response != null) {
        _billingsModel = response;
      }
    } catch (e) {
      hasError = true;
      debugPrint("Billing ma'lumotlarini yuklashda xato: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
