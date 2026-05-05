class PayLinkResponse {
  String? url;
  String? transactionParam;
  String? amount;

  PayLinkResponse({
    this.url, this.transactionParam, this.amount
  });

  PayLinkResponse copyWith({
    String? url, String? transactionParam, String? amount
  }) =>
      PayLinkResponse(url: url ?? this.url,
          transactionParam: transactionParam ?? this.transactionParam,
          amount: amount ?? this.amount);

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
    };
    map["url"] = url;
    map["transactionParam"] = transactionParam;
    map["amount"] = amount;
    return map;
  }

  PayLinkResponse.fromJson(dynamic json) {
    url = json["url"];
    transactionParam = json["transactionParam"];
    amount = json["amount"];
  }
}