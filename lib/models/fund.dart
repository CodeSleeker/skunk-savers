import 'package:skunk_savers/models/loan.dart';
import 'package:skunk_savers/models/saving.dart';

class Fund {
  List<Saving>? savings;
  List<Loan>? loans;
  Fund({
    this.savings,
    this.loans,
  });
}
