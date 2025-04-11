import 'package:cloud_firestore/cloud_firestore.dart';

class LogEntry {
  final String id;
  final DateTime timestamp;
  final String action;
  final String status;
  final String details;
  final String userName;

  const LogEntry({
    required this.id,
    required this.timestamp,
    required this.action,
    required this.status,
    required this.details,
    required this.userName,
  });

  factory LogEntry.fromMap(Map<String, dynamic> map) {
    return LogEntry(
      id: map['id'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(), // Convert Firestore Timestamp to DateTime
      action: map['action'] ?? '',
      status: map['status'] ?? '',
      details: map['details'] ?? '',
      userName: map['userName'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': Timestamp.fromDate(timestamp), // Convert DateTime to Firestore Timestamp
      'action': action,
      'status': status,
      'details': details,
      'userName': userName,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LogEntry &&
        other.timestamp == timestamp &&
        other.id == id &&
        other.action == action &&
        other.status == status &&
        other.details == details &&
        other.userName == userName;
  }

  @override
  int get hashCode {
    return timestamp.hashCode ^
        action.hashCode ^
        status.hashCode ^
        id.hashCode ^
        details.hashCode ^
        userName.hashCode ;
  }

  LogEntry copyWith({
    String? id,
    DateTime? timestamp,
    String? action,
    String? status,
    String? details,
    String? userName,
  }) {
    return LogEntry(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      action: action ?? this.action,
      status: status ?? this.status,
      details: details ?? this.details,
      userName: userName ?? this.userName,
    );
  }
}
