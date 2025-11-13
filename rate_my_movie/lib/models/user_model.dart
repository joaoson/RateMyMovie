class UserModel {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String? profileImagePath;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    this.profileImagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'profileImagePath': profileImagePath,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
      profileImagePath: map['profileImagePath'],
    );
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    String? profileImagePath,
    bool clearProfileImagePath = false,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      profileImagePath: clearProfileImagePath ? null : (profileImagePath ?? this.profileImagePath),
    );
  }
}