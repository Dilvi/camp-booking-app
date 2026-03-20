class ChildModel {
  final int id;
  final String? photoUrl;
  final String firstName;
  final String lastName;
  final String birthDate;
  final String gender;
  final String hobby;
  final String allergy;

  const ChildModel({
    required this.id,
    required this.photoUrl,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.gender,
    required this.hobby,
    required this.allergy,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory ChildModel.fromJson(Map<String, dynamic> json) {
    return ChildModel(
      id: (json['id'] ?? 0) as int,
      photoUrl: json['photo_url']?.toString(),
      firstName: (json['first_name'] ?? '').toString(),
      lastName: (json['last_name'] ?? '').toString(),
      birthDate: (json['birth_date'] ?? '').toString(),
      gender: (json['gender'] ?? '').toString(),
      hobby: (json['hobby'] ?? '').toString(),
      allergy: (json['allergy'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toRequestJson() {
    return {
      'photo_url': photoUrl ?? '',
      'first_name': firstName,
      'last_name': lastName,
      'birth_date': birthDate,
      'gender': gender,
      'hobby': hobby,
      'allergy': allergy,
    };
  }

  ChildModel copyWith({
    int? id,
    String? photoUrl,
    String? firstName,
    String? lastName,
    String? birthDate,
    String? gender,
    String? hobby,
    String? allergy,
  }) {
    return ChildModel(
      id: id ?? this.id,
      photoUrl: photoUrl ?? this.photoUrl,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      hobby: hobby ?? this.hobby,
      allergy: allergy ?? this.allergy,
    );
  }
}