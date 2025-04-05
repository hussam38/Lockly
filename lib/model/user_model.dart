class UserModel {
  String? image;
  String name;
  String email;
  String? phone;
  String uid;
  List<String> accessibleObjects;
  int? groupId;
  String? role;

  UserModel(
      {this.image,
      required this.name,
      required this.email,
      this.phone,
      required this.uid,
      required this.accessibleObjects,
      required this.role,
      this.groupId});

  factory UserModel.fromMap(Map<String, dynamic> map) {
  return UserModel(
    image: map['image'] as String?,
    name: map['name'] as String? ?? 'Unknown',
    email: map['email'] as String? ?? '',
    phone: map['phone'] as String?,
    uid: map['id'] as String? ?? '',
    role: map['role'] as String? ?? 'user',
    accessibleObjects: (map['accessibleObjects'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList() ?? [], 
    groupId: map['groupId'] as int?,
  );
}

  Map<String, dynamic> toMap() {
    return {
      'image': image,
      'name': name,
      'email': email,
      'phone': phone,
      'id': uid,
      'role': role,
      'accessibleObjects': accessibleObjects,
      'groupId': groupId
    };
  }

  UserModel copyWith(
      {String? image,
      String? name,
      String? email,
      String? password,
      String? phone,
      String? uid,
      String? role,
      List<String>? accessibleObjects,
      int? groupId}) {
    return UserModel(
        image: image ?? this.image,
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        uid: uid ?? this.uid,
        role: role ?? this.role,
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
        other.phone == phone &&
        other.uid == uid &&
        other.role == role &&
        other.accessibleObjects == accessibleObjects &&
        other.groupId == groupId;
  }

  @override
  int get hashCode =>
      image.hashCode ^
      name.hashCode ^
      email.hashCode ^
      phone.hashCode ^
      uid.hashCode ^
      role.hashCode ^
      accessibleObjects.hashCode ^
      groupId.hashCode;

  @override
  String toString() {
    return 'UserModel(image: $image, name: $name, email: $email, phone: $phone, uid: $uid, accessibleObjects: $accessibleObjects, groupId: $groupId, role: $role)';
  }
}
