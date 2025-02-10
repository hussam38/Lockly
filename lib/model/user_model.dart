class UserModel {
  String? image;
  String name;
  String email;
  String password;
  int? phone;
  int id;
  List<String> accessibleObjects;
  int? groupId;

  UserModel(
      {this.image,
      required this.name,
      required this.email,
      required this.password,
      this.phone,
      required this.id,
      required this.accessibleObjects,
      this.groupId});

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
        image: map['image'] as String?,
        name: map['name'] as String,
        email: map['email'] as String,
        password: map['password'] as String,
        phone: map['phone'] as int?,
        id: map['id'] as int,
        accessibleObjects: List<String>.from(map['accessibleObjects'] ?? []),
        groupId: map['groupId'] as int?);
  }

  Map<String, dynamic> toMap() {
    return {
      'image': image,
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'id': id,
      'accessibleObjects': accessibleObjects,
      'groupId': groupId
    };
  }

  UserModel copyWith(
      {String? image,
      String? name,
      String? email,
      String? password,
      int? phone,
      int? id,
      List<String>? accessibleObjects,
      int? groupId}) {
    return UserModel(
        image: image ?? this.image,
        name: name ?? this.name,
        email: email ?? this.email,
        password: password ?? this.password,
        phone: phone ?? this.phone,
        id: id ?? this.id,
        accessibleObjects: accessibleObjects ?? this.accessibleObjects,
        groupId: groupId ?? this.groupId);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.image == image &&
        other.name == name &&
        other.email == email &&
        other.password == password &&
        other.phone == phone &&
        other.id == id &&
        other.accessibleObjects == accessibleObjects &&
        other.groupId == groupId;
  }

  @override
  int get hashCode =>
      image.hashCode ^
      name.hashCode ^
      email.hashCode ^
      password.hashCode ^
      phone.hashCode ^
      id.hashCode ^
      accessibleObjects.hashCode ^
      groupId.hashCode;

  @override
  String toString() {
    return 'UserModel(image: $image, name: $name, email: $email, password: $password, phone: $phone, id: $id, accessibleObjects: $accessibleObjects, groupId: $groupId)';
  }
}
