class User {
  final int id;
  final String phoneNumber;
  final String fullName;
  final String? email;
  final bool isVerified;
  final DateTime dateJoined;

  User({
    required this.id,
    required this.phoneNumber,
    required this.fullName,
    this.email,
    required this.isVerified,
    required this.dateJoined,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      phoneNumber: json['phone_number'],
      fullName: json['full_name'],
      email: json['email'],
      isVerified: json['is_verified'] ?? false,
      dateJoined: DateTime.parse(json['date_joined']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone_number': phoneNumber,
      'full_name': fullName,
      'email': email,
      'is_verified': isVerified,
      'date_joined': dateJoined.toIso8601String(),
    };
  }
}