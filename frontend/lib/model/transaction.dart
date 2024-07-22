class Transaction {
  final String id;
  final String labelId;
  final String transactionType;
  final num amount;
  final String description;
  final String date;

  Transaction({
    required this.id,
    required this.labelId,
    required this.transactionType,
    required this.amount,
    required this.description,
    required this.date,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['_id'],
      labelId: json['labelId'],
      transactionType: json['transactionType'],
      amount: json['amount'].toDouble(),
      description: json['description'],
      date: json['date'],
    );
  }
}
