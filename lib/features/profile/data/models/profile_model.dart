class ProfileModel {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? avatarUrl;

  const ProfileModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.avatarUrl,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      firstName: (json['first_name'] ?? '').toString(),
      lastName: (json['last_name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      avatarUrl: json['avatar_url']?.toString(),
    );
  }
}