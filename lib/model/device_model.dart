import 'package:flutter/foundation.dart';

// mode -> (opened, closed)
//status -> (online, offline)
class DeviceModel {
  final String id;
  final String name;
  final List<Map<String, dynamic>> assignedTo;
  final String status;
  final bool locked;
  final int lockUntil;
  final String mode;
  final String? lockedBy;
  final String? location;
  final DateTime? createdAt;

  DeviceModel({
    required this.id,
    required this.name,
    required this.assignedTo,
    required this.status,
    this.locked = false,
    this.lockUntil = 0,
    this.createdAt,
    this.location = '',
    this.lockedBy = '',
    required this.mode,
  });

  factory DeviceModel.fromMap(Map<String, dynamic> map) {
    return DeviceModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      assignedTo: (map['assignedTo'] as Map?)
              ?.entries
              .map((e) => {
                    'uid': e.key,
                    ...Map<String, dynamic>.from(e.value ?? {}),
                  })
              .toList() ??
          [],
      status: map['status'] ?? 'offline',
      mode: map['mode'] ?? 'closed',
      locked: map['locked'] ?? false,
      lockedBy: map['lockedBy'] ?? '',
      lockUntil: map['lockUntil'] ?? 0,
      location: map['location'] ?? '',
      createdAt:
          map['createdAt'] != null ? DateTime.tryParse(map['createdAt']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'assignedTo': assignedTo,
      'status': status,
      'mode': mode,
      'locked': locked,
      'lockUntil': lockUntil,
      'lockedBy': lockedBy,
      'location': location,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  DeviceModel copyWith({
    String? id,
    String? name,
    List<Map<String, dynamic>>? assignedTo,
    String? status,
    String? mode,
    bool? locked,
    int? lockUntil,
    String? lockedBy,
    String? location,
    DateTime? createdAt,
  }) {
    return DeviceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      assignedTo: assignedTo ?? this.assignedTo,
      status: status ?? this.status,
      mode: mode ?? this.mode,
      locked: locked ?? this.locked,
      lockUntil: lockUntil ?? this.lockUntil,
      lockedBy: lockedBy ?? this.lockedBy,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DeviceModel &&
        other.id == id &&
        other.name == name &&
        listEquals(other.assignedTo, assignedTo) &&
        other.status == status &&
        other.mode == mode &&
        other.locked == locked &&
        other.lockedBy == lockedBy &&
        other.lockUntil == lockUntil &&
        other.location == location &&
        other.createdAt == createdAt;
  }

  @override
  String toString() {
    return 'DeviceModel{id: $id, name: $name, assignedTo: $assignedTo, status: $status, mode: $mode, locked: $locked, lockUntil: $lockUntil, lockedBy: $lockedBy, location: $location, createdAt: $createdAt}';
  }

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      assignedTo.hashCode ^
      status.hashCode ^
      locked.hashCode ^
      lockUntil.hashCode ^
      lockedBy.hashCode ^
      mode.hashCode ^
      location.hashCode ^
      createdAt.hashCode;
}
