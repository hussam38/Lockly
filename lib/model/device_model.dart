import 'package:flutter/foundation.dart';

class DeviceModel {
  final String id;
  final String name;
  final List<String> assignedTo;
  final String status;
  final String mode;

  DeviceModel({
    required this.id,
    required this.name,
    required this.assignedTo,
    required this.status,
    required this.mode,
  });

  factory DeviceModel.fromMap(Map<String, dynamic> map) {
    return DeviceModel(
      id: map['id'],
      name: map['name'] ?? '',
      assignedTo: List<String>.from(map['assignedTo'] ?? []),
      status: map['status'] ?? 'idle',
      mode: map['mode'] ?? 'offline',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'assignedTo': assignedTo,
      'status': status,
      'mode': mode,
    };
  }

  DeviceModel copyWith({
    String? id,
    String? name,
    List<String>? assignedTo,
    String? status,
    String? mode,
  }) {
    return DeviceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      assignedTo: assignedTo ?? this.assignedTo,
      status: status ?? this.status,
      mode: mode ?? this.mode,
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
        other.mode == mode;
  }

  @override
  String toString() {
    return 'DeviceModel{id: $id, name: $name, assignedTo: $assignedTo, status: $status, mode: $mode}';
  }

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      assignedTo.hashCode ^
      status.hashCode ^
      mode.hashCode;
}
