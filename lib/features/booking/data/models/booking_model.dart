class BookingModel {
  final int id;
  final int childId;
  final int campId;
  final String status;
  final String createdAt;
  final String updatedAt;

  const BookingModel({
    required this.id,
    required this.childId,
    required this.campId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: _asInt(json['id']),
      childId: _asInt(json['child_id']),
      campId: _asInt(json['camp_id']),
      status: (json['status'] ?? '').toString(),
      createdAt: (json['created_at'] ?? '').toString(),
      updatedAt: (json['updated_at'] ?? '').toString(),
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
