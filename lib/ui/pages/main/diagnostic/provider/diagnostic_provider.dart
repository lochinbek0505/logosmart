import 'package:flutter/material.dart';
import 'package:logosmart/models/diagnostic_group_model.dart';

import '../../../../../core/network/api_service.dart';

class DiagnosticProvider with ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  DiagnosticGroupModel _diagnosticGroupModel = DiagnosticGroupModel();

  DiagnosticGroupModel get diagnosticGroupModel => _diagnosticGroupModel;

  Future<void> init(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();

      var response = await ApiService().getDiagnosticGroup(context);
      if (response != null) {
        _diagnosticGroupModel = response;
      }
    } catch (e) {
      debugPrint("Diagnostic ma'lumotlarini yuklashda xato: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
