import 'dart:math';

class SSCSettings {
  int? depositDate;
  int? rate;
  List<int>? terms;
  double? minSavings;
  int? currentSequence;
  int? savingPeriod;
  SSCSettings({
    this.depositDate,
    this.rate,
    this.terms,
    this.currentSequence,
    this.savingPeriod,
  });
  Map<String, dynamic> toJson() {
    return {
      'deposit_date': depositDate,
      'rate': rate,
      'terms': terms,
      'minimum_savings': minSavings.toString(),
      'current_sequence': currentSequence,
      'saving_period': savingPeriod,
    };
  }

  // factory SSCSettings.fromJson(Map<String, dynamic> settingsJson) => SSCSettings(
  //       depositDate: settingsJson['deposit_date'],
  //       rate: settingsJson['rate'],
  //       terms: settingsJson['terms'] as List<int>?,
  //     );

  SSCSettings.fromJson(Map<String, dynamic> json) {
    depositDate = json['deposit_date'];
    rate = json['rate'];
    terms = List<int>.from(json['terms']);
    minSavings = double.parse(json['minimum_savings']);
    currentSequence = json['current_sequence'];
    savingPeriod = json['saving_period'];
  }
}
