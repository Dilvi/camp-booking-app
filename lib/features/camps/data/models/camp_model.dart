class CampModel {
  final int id;
  final String title;
  final String location;
  final int pricePerDay;
  final int bookedCount;
  final String description;
  final int shiftDurationDays;
  final int ageMin;
  final int ageMax;
  final String campType;
  final String foodType;
  final String? imageUrl;

  bool isFavorite;

  CampModel({
    required this.id,
    required this.title,
    required this.location,
    required this.pricePerDay,
    required this.bookedCount,
    required this.description,
    required this.shiftDurationDays,
    required this.ageMin,
    required this.ageMax,
    required this.campType,
    required this.foodType,
    required this.imageUrl,
    this.isFavorite = false,
  });

  factory CampModel.fromJson(Map<String, dynamic> json) {
    return CampModel(
      id: json['id'] as int,
      title: (json['title'] ?? '').toString(),
      location: (json['location'] ?? '').toString(),
      pricePerDay: (json['price_per_day'] ?? 0) as int,
      bookedCount: (json['booked_count'] ?? 0) as int,
      description: (json['description'] ?? '').toString(),
      shiftDurationDays: (json['shift_duration_days'] ?? 0) as int,
      ageMin: (json['age_min'] ?? 0) as int,
      ageMax: (json['age_max'] ?? 0) as int,
      campType: (json['camp_type'] ?? '').toString(),
      foodType: (json['food_type'] ?? '').toString(),
      imageUrl: json['image_url']?.toString(),
      isFavorite: (json['is_favorite'] ?? false) as bool,
    );
  }
}