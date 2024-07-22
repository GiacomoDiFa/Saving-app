class Label {
  final String id;
  final String userId;
  final String label;
  final String field;
  final DateTime createdAt;
  final DateTime updatedAt;

  Label({
    required this.id,
    required this.userId,
    required this.label,
    required this.field,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Label.fromJson(Map<String, dynamic> json) {
    return Label(
      id: json['_id'],
      userId: json['userId'],
      label: json['label'],
      field: json['field'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
