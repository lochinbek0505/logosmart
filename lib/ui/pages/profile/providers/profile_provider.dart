import 'package:flutter/material.dart';
import 'package:logosmart/models/avatars_model.dart';
import 'package:logosmart/models/pay_link_response.dart';
import 'package:logosmart/models/plans_model.dart';
import 'package:logosmart/models/profile_response.dart';
import 'package:logosmart/models/promo_check_model.dart';
import 'package:logosmart/ui/pages/auth/login_page.dart';
import 'package:logosmart/ui/pages/profile/providers/notifications_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/network/api_service.dart';
import '../../../../core/storage/token_storage.dart';

class ProfileProvider with ChangeNotifier {
  /// Profil yuklanmoqda (profil sahifasidagi umumiy loader)
  bool isLoading = false;

  /// Obuna rejalari yuklanmoqda
  bool isPlansLoading = false;

  /// Tugma bilan boshlanadigan amal (faollashtirish, promokod, to'lov,
  /// saqlash) — har biri o'z tugmasini bloklaydi, profil loaderiga tegmaydi
  bool isActionLoading = false;
  TokenStorage _tokenStorage = TokenStorage();
  PayLinkResponse _payLinkResponse = PayLinkResponse();

  PayLinkResponse get payLinkResponse => _payLinkResponse;

  ProfileResponse _profileResponse = ProfileResponse();

  ProfileResponse get profileResponse => _profileResponse;

  PlansModel _plansModel = PlansModel();

  PlansModel get plansModel => _plansModel;

  AvatarsModel _avatarsModel = AvatarsModel();

  AvatarsModel get avatarsModel => _avatarsModel;

  /// [silent] = true bo'lsa loading ko'rsatilmaydi, ma'lumot orqa fonda yangilanadi.
  Future<void> init(context, {bool silent = false}) async {
    await _loadCachedProfile();
    if (!silent) {
      isLoading = true;
      notifyListeners();
    }
    try {
      final results = await Future.wait([
        ApiService().getProfile(context),
        ApiService().getAvatars(context),
      ]);
      final response = results[0] as ProfileResponse?;
      final avatarsResponse = results[1] as AvatarsModel?;
      if (avatarsResponse != null) {
        _avatarsModel = avatarsResponse;
      }
      if (response != null) {
        _profileResponse = response;
        await _tokenStorage.saveProfileData(response);
      }
    } catch (e) {
      debugPrint("Profilni yuklashda xato: $e");
    } finally {
      if (!silent) isLoading = false;
      notifyListeners();
    }
  }

  bool _cacheLoaded = false;

  /// Storage'dagi oxirgi profilni bir marta o'qib, API javobi kelguncha ko'rsatadi.
  Future<void> _loadCachedProfile() async {
    if (_cacheLoaded) return;
    _cacheLoaded = true;
    final cached = await _tokenStorage.getProfileData();
    if (cached != null) {
      _profileResponse = cached;
      notifyListeners();
    }
  }

  Future<void> initPlans(BuildContext context) async {
    try {
      isPlansLoading = true;
      notifyListeners();

      var response = await ApiService().getPlans(context);
      if (response != null) {
        _plansModel = response;
      }
    } catch (e) {
      debugPrint("Planlarni yuklashda xato: $e");
    } finally {
      isPlansLoading = false;
      notifyListeners();
    }
  }

  /// To'lov havolasini olib, Click ni ochadi.
  /// null — muvaffaqiyatli; aks holda foydalanuvchiga ko'rsatiladigan xato.
  /// (API xatolari ApiService da snackbar bilan ko'rsatiladi — ular uchun
  /// bo'sh qator qaytariladi.)
  Future<String?> createPayLink(BuildContext context, dynamic amount) async {
    try {
      isActionLoading = true;
      notifyListeners();

      var response = await ApiService().getPayLink(context, amount);
      if (response == null) return "";
      if (response.url == null || response.url!.isEmpty) {
        return "To'lov havolasini olib bo'lmadi";
      }
      final opened = await openMyLink(response.url!);
      return opened ? null : "To'lov sahifasini ochib bo'lmadi";
    } catch (e) {
      debugPrint("To'lov xatosi: $e");
      return "To'lovni boshlashda xatolik yuz berdi";
    } finally {
      isActionLoading = false;
      notifyListeners();
    }
  }

  Future<bool> openMyLink(String urlString) async {
    final Uri? url = Uri.tryParse(urlString);
    if (url == null) return false;
    try {
      return await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint("URL ochishda xato: $e");
      return false;
    }
  }

  /// true — obuna faollashtirildi (balansdan yechildi). Backend xato
  /// qaytarsa uning matni ApiService da snackbar bilan ko'rsatiladi.
  Future<bool> activatePlan(
    BuildContext context,
    String planCode,
    String promoCode,
  ) async {
    try {
      isActionLoading = true;
      notifyListeners();
      var req = {"planCode": planCode, "promoCode": promoCode};
      var response = await ApiService().activatePlan(context, req);
      // 200 javob — obuna yozildi; activePaid faqat muddatli rejalarda true
      if (response != null) {
        if (context.mounted) await init(context, silent: true);
        return true;
      }
    } catch (e) {
      debugPrint("Rejani faollashtirishda xato: $e");
    } finally {
      isActionLoading = false;
      notifyListeners();
    }
    return false;
  }

  Future<PromoCheckModel> checkPromoCode(
    BuildContext context,
    String promoCode,
  ) async {
    try {
      isActionLoading = true;
      notifyListeners();
      var response = await ApiService().checkPromo(context, promoCode);
      if (response != null) {
        return response;
      }
    } catch (e) {
      debugPrint("Promo kodni tekshirishda xato: $e");
    } finally {
      isActionLoading = false;
      notifyListeners();
    }
    return PromoCheckModel(
      valid: false,
      message: "Promo kodni tekshirib bo'lmadi",
    );
  }

  /// Yangilangan profil yoki xato bo'lsa null.
  Future<ProfileResponse?> updateProfile(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    try {
      isActionLoading = true;
      notifyListeners();
      var response = await ApiService().updateProfile(context, data);
      if (response != null) {
        if (context.mounted) await init(context, silent: true);
        return response;
      }
    } catch (e) {
      debugPrint("Profilni saqlashda xato: $e");
    } finally {
      isActionLoading = false;
      notifyListeners();
    }
    return null;
  }

  /// Profil rasmini olib tashlaydi (PUT /profile/me to'liq yozadi, shuning
  /// uchun qolgan maydonlar ham yuboriladi).
  Future<bool> removeProfileImage(BuildContext context) async {
    final p = _profileResponse;
    final result = await updateProfile(context, {
      "fullName": p.fullName,
      "age": p.age,
      "profileImage": null,
      "region": p.region,
      "district": p.district,
    });
    return result != null;
  }

  Future<void> logout(BuildContext context) async {
    try {
      isActionLoading = true;
      notifyListeners();
      // Server javob bermasa ham (internet yo'q) qurilmadan chiqariladi —
      // aks holda foydalanuvchi tizimdan chiqa olmay qolardi
      await ApiService().logout(context);
    } catch (e) {
      debugPrint("Tizimdan chiqishda xato: $e");
    } finally {
      isActionLoading = false;
    }
    if (!context.mounted) return;
    await _signOutLocally(context);
  }

  Future<void> deleteAccount(BuildContext context) async {
    try {
      isActionLoading = true;
      notifyListeners();

      bool response = await ApiService().deleteAccount(context);

      // Akkaunt serverda o'chmasa qurilmadan chiqarilmaydi — xato
      // ApiService da ko'rsatiladi
      if (response && context.mounted) {
        await _signOutLocally(context);
      }
    } catch (e) {
      debugPrint("Akkauntni o'chirishda xato: $e");
    } finally {
      isActionLoading = false;
      notifyListeners();
    }
  }

  Future<void> _signOutLocally(BuildContext context) async {
    await _tokenStorage.clearAll();
    _profileResponse = ProfileResponse();
    _cacheLoaded = false;
    NotificationsProvider().clear();
    notifyListeners();

    if (!context.mounted) return;
    // pushReplacement faqat tepadagi sahifani almashtirardi — orqaga bosilsa
    // profil sahifalariga qaytish mumkin edi
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (builder) => const LoginPage()),
      (route) => false,
    );
  }
}
