class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String role;
  final DateTime createdAt;
  final String? pinHash; // Hashed PIN for authentication
  final String? specialty; // For clinicians
  final String? workplace; // For clinicians - facility/hospital name
  final String? email; // For admin users

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.role,
    required this.createdAt,
    this.pinHash,
    this.specialty,
    this.workplace,
    this.email,
  });

  // Create from Firestore document
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? json['uid'] as String? ?? '',
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phoneNumber: json['phoneNumber'] as String,
      role: json['role'] as String,
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'] as String)
          : (json['createdAt'] as DateTime? ?? DateTime.now()),
      pinHash: json['pinHash'] as String?,
      specialty: json['specialty'] as String?,
      workplace: json['workplace'] as String?,
      email: json['email'] as String?,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': id, // Keep both for compatibility
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      if (pinHash != null) 'pinHash': pinHash,
      if (specialty != null) 'specialty': specialty,
      if (workplace != null) 'workplace': workplace,
      if (email != null) 'email': email,
    };
  }

  String get fullName => '$firstName $lastName';

  // Role checks
  bool get isVHT => role == 'VHT';
  bool get isAmbulanceDriver => role == 'Ambulance Driver';
  bool get isClinicStaff => role == 'Clinic Staff';
  bool get isAdmin => role == 'Admin';
}
