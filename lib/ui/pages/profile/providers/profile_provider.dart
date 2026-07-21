import 'package:flutter/material.dart';
import 'package:logosmart/models/avatars_model.dart';
import 'package:logosmart/models/pay_link_response.dart';
import 'package:logosmart/models/plans_model.dart';
import 'package:logosmart/models/profile_response.dart';
import 'package:logosmart/models/promo_check_model.dart';
import 'package:logosmart/ui/pages/auth/login_page.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/network/api_service.dart';
import '../../../../core/storage/token_storage.dart';

class ProfileProvider with ChangeNotifier {
  bool isLoading = false;
  TokenStorage _tokenStorage = TokenStorage();
  PayLinkResponse _payLinkResponse = PayLinkResponse();

  PayLinkResponse get payLinkResponse => _payLinkResponse;

  ProfileResponse _profileResponse = ProfileResponse();

  ProfileResponse get profileResponse => _profileResponse;

  PlansModel _plansModel = PlansModel();

  PlansModel get plansModel => _plansModel;

  AvatarsModel _avatarsModel = AvatarsModel();

  AvatarsModel get avatarsModel => _avatarsModel;

  Future<void> init(context) async {
    isLoading = true;
    notifyListeners();
    var response = await ApiService().getProfile(context);
    var avatarsResponse = await ApiService().getAvatars(context);
    if (avatarsResponse != null) {
      _avatarsModel = avatarsResponse;
    }
    if (response != null) {
      _profileResponse = response;
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> initPlans(BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();

      var response = await ApiService().getPlans(context);
      if (response != null) {
        _plansModel = response;
      }
    } catch (e) {
      debugPrint("Planlarni yuklashda xato: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createPayLink(BuildContext context, dynamic amount) async {
    try {
      isLoading = true;
      notifyListeners();

      var response = await ApiService().getPayLink(context, amount);
      if (response != null && response.url != null) {
        await openMyLink(response.url!);
      }
    } catch (e) {
      debugPrint("To'lov xatosi: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> openMyLink(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        debugPrint("Havolani ochib bo'lmadi: $urlString");
      }
    } catch (e) {
      debugPrint("URL ochishda xato: $e");
    }
  }

  Future<bool> activatePlan(
    BuildContext context,
    String planCode,
    String promoCode,
  ) async {
    try {
      isLoading = true;
      notifyListeners();
      var req = {"planCode": planCode, "promoCode": promoCode};
      var response = await ApiService().activatePlan(context, req);
      if (response != null && response.activePaid!) {
        await init(context);
        return true;
      }
    } catch (e) {
      debugPrint("Rejani faollashtirishda xato: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
    return false;
  }

  Future<PromoCheckModel> checkPromoCode(
    BuildContext context,
    String promoCode,
  ) async {
    try {
      isLoading = true;
      notifyListeners();
      var response = await ApiService().checkPromo(context, promoCode);
      if (response != null) {
        return response;
      }
    } catch (e) {
      debugPrint("Promo kodni tekshirishda xato: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
    return PromoCheckModel();
  }

  Future<ProfileResponse> updateProfile(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    try {
      isLoading = true;
      notifyListeners();
      var response = await ApiService().updateProfile(context, data);
      if (response != null) {
        init(context);
        return response;
      }
    } catch (e) {
      debugPrint("Promo kodni tekshirishda xato: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
    return ProfileResponse();
  }

  Future<void> logout(BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();

      bool response = await ApiService().logout(context);

      if (response) {
        await _tokenStorage.clearAll();

        if (!context.mounted) return; // Context mavjudligini tekshirish

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (builder) => const LoginPage()),
        );
      }
    } catch (e) {
      debugPrint("Tizimdan chiqishda xato: $e"); // Matn to'g'irlandi
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAccount(BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();

      bool response = await ApiService().deleteAccount(context);

      if (response) {
        await _tokenStorage.clearAll();

        if (!context.mounted) return; // Context mavjudligini tekshirish

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (builder) => const LoginPage()),
        );
      }
    } catch (e) {
      debugPrint("Akkauntni o'chirishda xato: $e"); // Matn to'g'irlandi
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
