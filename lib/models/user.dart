class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? profileImagePath; // Local file path for profile image
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String? bio;
  final List<String> favoriteDestinations;
  final List<String> travelPreferences;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Computed property for full name
  String get name => '$firstName $lastName'.trim();

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.profileImagePath,
    this.phoneNumber,
    this.dateOfBirth,
    this.bio,
    this.favoriteDestinations = const [],
    this.travelPreferences = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? json['name']?.split(' ')[0] ?? '',
      lastName: json['lastName'] ?? (json['name']?.split(' ').length > 1 ? json['name'].split(' ').sublist(1).join(' ') : ''),
      profileImagePath: json['profileImagePath'],
      phoneNumber: json['phoneNumber'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      bio: json['bio'],
      favoriteDestinations:
          List<String>.from(json['favoriteDestinations'] ?? []),
      travelPreferences: List<String>.from(json['travelPreferences'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'profileImagePath': profileImagePath,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'bio': bio,
      'favoriteDestinations': favoriteDestinations,
      'travelPreferences': travelPreferences,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? profileImagePath,
    bool clearProfileImage = false,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? bio,
    List<String>? favoriteDestinations,
    List<String>? travelPreferences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profileImagePath: clearProfileImage ? null : (profileImagePath ?? this.profileImagePath),
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      bio: bio ?? this.bio,
      favoriteDestinations: favoriteDestinations ?? this.favoriteDestinations,
      travelPreferences: travelPreferences ?? this.travelPreferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}