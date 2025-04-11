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

  DeviceModel({
    required this.id,
    required this.name,
    required this.assignedTo,
    required this.status,
    this.locked = false,
    this.lockUntil = 0,
    required this.mode,
  });

  factory DeviceModel.fromMap(Map<String, dynamic> map) {
    return DeviceModel(
      id: map['id'],
      name: map['name'] ?? '',
      assignedTo: List<Map<String, dynamic>>.from(map['assignedTo'] ?? []),
      status: map['status'] ?? 'offline',
      mode: map['mode'] ?? 'closed',
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
  }) {
    return DeviceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      assignedTo: assignedTo ?? this.assignedTo,
      status: status ?? this.status,
      mode: mode ?? this.mode,
      locked: locked ?? this.locked,
      lockUntil: lockUntil ?? this.lockUntil,
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
        other.lockUntil == lockUntil;
  }

  @override
  String toString() {
    return 'DeviceModel{id: $id, name: $name, assignedTo: $assignedTo, status: $status, mode: $mode, locked: $locked, lockUntil: $lockUntil}';
  }

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      assignedTo.hashCode ^
      status.hashCode ^
      locked.hashCode ^
      lockUntil.hashCode ^
      mode.hashCode;
}
