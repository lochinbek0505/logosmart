/// POST subscriptions/checkout javobi.
/// paid = true — obuna balansdan darhol faollashdi; aks holda [url] — yetmagan
/// [amount] uchun Click havolasi (pul tushishi bilan obuna serverda faollashadi).
class PlanCheckoutResponse {
  bool paid;
  String? url;
  num? amount;

  PlanCheckoutResponse({this.paid = false, this.url, this.amount});

  PlanCheckoutResponse.fromJson(dynamic json)
    : paid = json["paid"] == true,
      url = json["url"],
      amount = json["amount"];
}
