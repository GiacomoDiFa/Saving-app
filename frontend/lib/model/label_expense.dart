class LabelExpense {
  final num totalAmount;
  final String label;

  LabelExpense({required this.totalAmount, required this.label});

  factory LabelExpense.fromJson(Map<String, dynamic> json) {
    return LabelExpense(
        totalAmount: json['totalAmount'].toDouble(), label: json['label']);
  }
}
