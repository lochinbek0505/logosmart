import 'package:flutter/cupertino.dart';
import 'package:logosmart/models/pay_link_response.dart';
import 'package:logosmart/models/profile_response.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/network/api_service.dart';

class ProfileProvider with ChangeNotifier {
  bool loading = false;

  PayLinkResponse _payLinkResponse = PayLinkResponse();

  PayLinkResponse get payLinkResponse => _payLinkResponse;

  ProfileResponse _profileResponse = ProfileResponse();

  ProfileResponse get profileResponse => _profileResponse;

  Future<void> init(context) async {
    loading = true;
    notifyListeners();
    var response = await ApiService().getProfile(context);
    if (response != null) {
      _profileResponse = response;
    }
    loading = false;
    notifyListeners();
  }

  Future<void> createPayLink(context, num amount) async {
    loading = true;
    notifyListeners();
    var response = await ApiService().getPayLink(context, {"amount": amount});
    if (response != null) {
      print(response.toJson());
      await openMyLink(response!.url!);
    }
    loading = false;
    notifyListeners();
  }

  Future<void> openMyLink(String urlString) async {
    final Uri url = Uri.parse(urlString);

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      print("Havolani ochib bo'lmadi: $urlString");
    }
  }
}
