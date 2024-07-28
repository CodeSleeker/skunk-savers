class SSCAccount {
  double? cashOnHand;
  double? loans;
  double? profits;
  double? savings;

  SSCAccount({
    this.cashOnHand = 0,
    this.loans = 0,
    this.profits = 0,
    this.savings = 0,
  });

  SSCAccount.fromJson(Map<String, dynamic> json) {
    cashOnHand = double.parse(json['cash_on_hand']);
    loans = double.parse(json['loans']);
    profits = double.parse(json['profits']);
    savings = double.parse(json['savings']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cash_on_hand'] = cashOnHand.toString();
    data['loans'] = loans.toString();
    data['profits'] = profits.toString();
    data['savings'] = savings.toString();
    return data;
  }
}
