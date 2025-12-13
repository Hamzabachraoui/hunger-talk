class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Gérer les UUID qui peuvent être des String ou des objets
    String id;
    if (json['id'] is String) {
      id = json['id'] as String;
    } else {
      id = json['id'].toString();
    }

    // Gérer created_at qui peut être absent
    DateTime createdAt;
    if (json['created_at'] != null) {
      if (json['created_at'] is String) {
        createdAt = DateTime.parse(json['created_at'] as String);
      } else if (json['created_at'] is DateTime) {
        createdAt = json['created_at'] as DateTime;
      } else {
        createdAt = DateTime.now();
      }
    } else {
      createdAt = DateTime.now();
    }

    return UserModel(
      id: id,
      email: json['email'] as String,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get fullName => '$firstName $lastName';
}

